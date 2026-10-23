/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.thermal

import android.app.ActivityTaskManager
import android.app.TaskStackListener
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.database.ContentObserver
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Handler
import android.os.HandlerThread
import android.provider.Settings
import android.util.Log
import java.io.File

/**
 * Picks the mi_thermald scene. On stock, PowerKeeper switches it by what the phone is doing,
 * and without it mi_thermald stays on the default scene, which steps the big cores down from
 * 32°C whatever runs and holds the charging current back.
 *
 * The first state that applies wins, each with its Settings.Global key and default scene:
 * - A voice call (audio mode IN_CALL): onyx_call_thermal_scene, 5 (phone). The big cores stay at
 *   1.5GHz, which a call never needs more than.
 * - A VoIP or video call (audio mode IN_COMMUNICATION): onyx_voip_thermal_scene, 14 (video chat).
 * - A camera in use: onyx_camera_thermal_scene, 15 (camera). The big cores keep up to 2.96GHz
 *   until 37°C for capture and processing.
 * - A game on top (ApplicationInfo.CATEGORY_GAME): onyx_game_thermal_scene, 19 (balanced
 *   gaming). The big cores hold their clocks up to 42.5°C.
 * - Charging: onyx_charging_thermal_scene, 9 (AR/VR). Its charging table keeps the full current
 *   up to 35°C and 5-8A up to ~41°C, where the default scene already drops to 2.5-5A at 39°C.
 * - A video app on top (CATEGORY_VIDEO): onyx_video_thermal_scene, 11 (video). It caps the big
 *   cores harder than the default from 32°C, which playback doesn't notice.
 * - A maps app on top (CATEGORY_MAPS): onyx_navigation_thermal_scene, 10 (navigation). It keeps
 *   the big cores at 2.07GHz for long sessions.
 * - Otherwise the scene mi_thermald booted with.
 *
 * A negative value disables that state.
 */
object ThermalSceneController {

    private const val TAG = "ThermalSceneController"
    private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)

    private const val SCONFIG_PATH = "/sys/class/thermal/thermal_message/sconfig"

    private enum class State(val key: String, val defaultScene: Int) {
        CALL("onyx_call_thermal_scene", 5),
        VOIP("onyx_voip_thermal_scene", 14),
        CAMERA("onyx_camera_thermal_scene", 15),
        GAME("onyx_game_thermal_scene", 19),
        CHARGING("onyx_charging_thermal_scene", 9),
        VIDEO("onyx_video_thermal_scene", 11),
        NAVIGATION("onyx_navigation_thermal_scene", 10),
    }

    private val handler by lazy { Handler(HandlerThread(TAG).apply { start() }.looper) }

    private var defaultScene: String? = null
    private var charging = false
    private var audioMode = AudioManager.MODE_NORMAL
    private var topCategory = ApplicationInfo.CATEGORY_UNDEFINED
    private val openCameras = mutableSetOf<String>()

    fun init(context: Context) {
        defaultScene = readScene()

        context.registerReceiver(
            object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    when (intent.action) {
                        Intent.ACTION_POWER_CONNECTED -> charging = true
                        Intent.ACTION_POWER_DISCONNECTED -> charging = false
                    }
                    update(context)
                }
            },
            IntentFilter().apply {
                addAction(Intent.ACTION_POWER_CONNECTED)
                addAction(Intent.ACTION_POWER_DISCONNECTED)
            },
            null,
            handler,
        )

        val observer =
            object : ContentObserver(handler) {
                override fun onChange(selfChange: Boolean) = update(context)
            }
        State.values().forEach {
            context.contentResolver.registerContentObserver(
                Settings.Global.getUriFor(it.key),
                false,
                observer,
            )
        }

        runCatching {
                ActivityTaskManager.getService()
                    .registerTaskStackListener(
                        object : TaskStackListener() {
                            override fun onTaskStackChanged() {
                                handler.post { updateForegroundApp(context) }
                            }
                        }
                    )
            }
            .onFailure { e -> Log.e(TAG, "Failed to register the task stack listener", e) }

        val audioManager = context.getSystemService(AudioManager::class.java)
        audioManager.addOnModeChangedListener({ handler.post(it) }) { mode ->
            audioMode = mode
            update(context)
        }

        context
            .getSystemService(CameraManager::class.java)
            .registerAvailabilityCallback(
                object : CameraManager.AvailabilityCallback() {
                    override fun onCameraUnavailable(cameraId: String) {
                        if (openCameras.add(cameraId)) update(context)
                    }

                    override fun onCameraAvailable(cameraId: String) {
                        if (openCameras.remove(cameraId)) update(context)
                    }
                },
                handler,
            )

        handler.post {
            val battery =
                context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            charging = battery?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) != 0
            audioMode = audioManager.mode
            updateForegroundApp(context)
            update(context)
        }
    }

    private fun updateForegroundApp(context: Context) {
        val packageName =
            runCatching {
                    ActivityTaskManager.getService().focusedRootTaskInfo?.topActivity?.packageName
                }
                .getOrNull()
        val category =
            packageName?.let {
                runCatching { context.packageManager.getApplicationInfo(it, 0).category }
                    .getOrNull()
            } ?: ApplicationInfo.CATEGORY_UNDEFINED
        if (category == topCategory) return
        if (DEBUG) Log.d(TAG, "top category=$category ($packageName)")
        topCategory = category
        update(context)
    }

    private fun activeStates(): List<State> = buildList {
        when (audioMode) {
            AudioManager.MODE_IN_CALL,
            AudioManager.MODE_CALL_SCREENING,
            AudioManager.MODE_CALL_REDIRECT -> add(State.CALL)
            AudioManager.MODE_IN_COMMUNICATION,
            AudioManager.MODE_COMMUNICATION_REDIRECT -> add(State.VOIP)
        }
        if (openCameras.isNotEmpty()) add(State.CAMERA)
        if (topCategory == ApplicationInfo.CATEGORY_GAME) add(State.GAME)
        if (charging) add(State.CHARGING)
        if (topCategory == ApplicationInfo.CATEGORY_VIDEO) add(State.VIDEO)
        if (topCategory == ApplicationInfo.CATEGORY_MAPS) add(State.NAVIGATION)
    }

    private fun update(context: Context) {
        val resolver = context.contentResolver
        // activeStates() is already in priority order, so the first enabled one wins.
        val scene =
            activeStates()
                .map { Settings.Global.getInt(resolver, it.key, it.defaultScene) }
                .firstOrNull { it >= 0 }
        if (DEBUG) {
            Log.d(
                TAG,
                "mode=$audioMode cameras=$openCameras category=$topCategory " +
                    "charging=$charging scene=$scene",
            )
        }
        (scene?.toString() ?: defaultScene)?.let { writeScene(it) }
    }

    private fun readScene(): String? =
        runCatching { File(SCONFIG_PATH).readText().trim() }
            .onFailure { e -> Log.e(TAG, "Failed to read $SCONFIG_PATH", e) }
            .getOrNull()

    private fun writeScene(scene: String) {
        if (readScene() == scene) return
        Log.i(TAG, "Switching mi_thermald to scene $scene")
        runCatching { File(SCONFIG_PATH).writeText(scene) }
            .onFailure { e -> Log.e(TAG, "Failed to write $SCONFIG_PATH", e) }
    }
}

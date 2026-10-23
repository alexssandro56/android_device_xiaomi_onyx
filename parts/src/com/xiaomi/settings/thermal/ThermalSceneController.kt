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
import android.os.BatteryManager
import android.os.Handler
import android.os.HandlerThread
import android.provider.Settings
import android.util.Log
import java.io.File

/**
 * Picks the mi_thermald scene. On stock, PowerKeeper switches it per app and on charge, and
 * without it mi_thermald stays on the default scene, which throttles games early and holds the
 * charging current back.
 *
 * - A game on top (ApplicationInfo.CATEGORY_GAME) uses [KEY_GAME_SCENE], default 19 (balanced
 *   gaming): its big cores hold their clocks up to 42.5°C, where the default scene already
 *   steps them down from 32°C.
 * - Otherwise, while charging, [KEY_CHARGING_SCENE], default 9 (AR/VR): its charging table keeps
 *   the full current up to 35°C and 5-8A up to ~41°C, where the default scene already drops to
 *   2.5-5A at 39°C.
 * - Otherwise the scene mi_thermald booted with.
 *
 * Both are Settings.Global ints; a negative value disables that scene.
 */
object ThermalSceneController {

    private const val TAG = "ThermalSceneController"
    private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)

    private const val SCONFIG_PATH = "/sys/class/thermal/thermal_message/sconfig"

    const val KEY_CHARGING_SCENE = "onyx_charging_thermal_scene"
    const val KEY_GAME_SCENE = "onyx_game_thermal_scene"
    private const val DEFAULT_CHARGING_SCENE = 9
    private const val DEFAULT_GAME_SCENE = 19

    private val handler by lazy { Handler(HandlerThread(TAG).apply { start() }.looper) }

    private var defaultScene: String? = null
    private var charging = false
    private var gameOnTop = false

    fun init(context: Context) {
        defaultScene = readScene()

        context.registerReceiver(
            object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    when (intent.action) {
                        Intent.ACTION_POWER_CONNECTED -> setCharging(context, true)
                        Intent.ACTION_POWER_DISCONNECTED -> setCharging(context, false)
                    }
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
        context.contentResolver.registerContentObserver(
            Settings.Global.getUriFor(KEY_CHARGING_SCENE),
            false,
            observer,
        )
        context.contentResolver.registerContentObserver(
            Settings.Global.getUriFor(KEY_GAME_SCENE),
            false,
            observer,
        )

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

        handler.post {
            val battery =
                context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            charging = battery?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) != 0
            updateForegroundApp(context)
            update(context)
        }
    }

    private fun setCharging(context: Context, charging: Boolean) {
        this.charging = charging
        update(context)
    }

    private fun updateForegroundApp(context: Context) {
        val packageName =
            runCatching {
                    ActivityTaskManager.getService().focusedRootTaskInfo?.topActivity?.packageName
                }
                .getOrNull()
        val isGame =
            packageName != null &&
                runCatching {
                        context.packageManager.getApplicationInfo(packageName, 0).category ==
                            ApplicationInfo.CATEGORY_GAME
                    }
                    .getOrDefault(false)
        if (isGame == gameOnTop) return
        if (DEBUG) Log.d(TAG, "gameOnTop=$isGame ($packageName)")
        gameOnTop = isGame
        update(context)
    }

    private fun update(context: Context) {
        val resolver = context.contentResolver
        val gameScene = Settings.Global.getInt(resolver, KEY_GAME_SCENE, DEFAULT_GAME_SCENE)
        val chargingScene =
            Settings.Global.getInt(resolver, KEY_CHARGING_SCENE, DEFAULT_CHARGING_SCENE)
        if (DEBUG) {
            Log.d(
                TAG,
                "gameOnTop=$gameOnTop charging=$charging game=$gameScene charge=$chargingScene",
            )
        }
        when {
            gameOnTop && gameScene >= 0 -> writeScene(gameScene.toString())
            charging && chargingScene >= 0 -> writeScene(chargingScene.toString())
            else -> defaultScene?.let { writeScene(it) }
        }
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

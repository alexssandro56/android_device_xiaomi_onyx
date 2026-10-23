/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.thermal

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import java.io.File

/**
 * Switches mi_thermald to a charging thermal scene while a charger is plugged in. On stock,
 * PowerKeeper picks the scene, and without it mi_thermald stays on the default scene, which
 * holds the charging current back.
 *
 * The default is the AR/VR scene (sconfig 9): its charging table keeps the full current up to
 * 35°C and 5-8A up to ~41°C, where the default scene already drops to 2.5-5A at 39°C. The scene
 * is read from Settings.Global [KEY_CHARGING_SCENE]; a negative value disables it.
 *
 * Unplugging goes back to [BASE_SCENE], the tgame scene init sets at boot, instead of the value
 * read when Parts starts, which can still be the kernel's 0 if init hasn't written it yet.
 */
object ChargingThermalController {

    private const val TAG = "ChargingThermalController"
    private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)

    private const val SCONFIG_PATH = "/sys/class/thermal/thermal_message/sconfig"

    const val KEY_CHARGING_SCENE = "onyx_charging_thermal_scene"
    private const val DEFAULT_CHARGING_SCENE = 9
    // Keep in sync with init.xiaomi.rc.
    private const val BASE_SCENE = "18"

    private var charging = false

    fun init(context: Context) {
        val receiver =
            object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    when (intent.action) {
                        Intent.ACTION_POWER_CONNECTED -> setCharging(context, true)
                        Intent.ACTION_POWER_DISCONNECTED -> setCharging(context, false)
                    }
                }
            }
        context.registerReceiver(
            receiver,
            IntentFilter().apply {
                addAction(Intent.ACTION_POWER_CONNECTED)
                addAction(Intent.ACTION_POWER_DISCONNECTED)
            },
        )

        context.contentResolver.registerContentObserver(
            Settings.Global.getUriFor(KEY_CHARGING_SCENE),
            false,
            object : ContentObserver(Handler(Looper.getMainLooper())) {
                override fun onChange(selfChange: Boolean) = update(context)
            },
        )

        val battery = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        setCharging(context, battery?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) != 0)
    }

    private fun setCharging(context: Context, charging: Boolean) {
        this.charging = charging
        update(context)
    }

    private fun update(context: Context) {
        val chargingScene =
            Settings.Global.getInt(
                context.contentResolver,
                KEY_CHARGING_SCENE,
                DEFAULT_CHARGING_SCENE,
            )
        if (DEBUG) Log.d(TAG, "charging=$charging chargingScene=$chargingScene")
        when {
            charging && chargingScene >= 0 -> writeScene(chargingScene.toString())
            else -> writeScene(BASE_SCENE)
        }
    }

    private fun readScene(): String? =
        runCatching { File(SCONFIG_PATH).readText().trim() }
            .onFailure { e -> Log.e(TAG, "Failed to read $SCONFIG_PATH", e) }
            .getOrNull()

    private fun writeScene(scene: String) {
        if (readScene() == scene) return
        if (DEBUG) Log.d(TAG, "Writing sconfig $scene")
        runCatching { File(SCONFIG_PATH).writeText(scene) }
            .onFailure { e -> Log.e(TAG, "Failed to write $SCONFIG_PATH", e) }
    }
}

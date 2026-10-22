/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.touch

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.ServiceManager
import android.os.UserHandle
import android.provider.Settings
import android.util.Log
import vendor.xiaomi.hw.touchfeature.ITouchFeature

/**
 * Keeps the touch IC's double tap gesture armed while the double tap setting is on. The
 * driver only applies gestures when the panel suspends, before doze registers the double
 * tap sensor, so the sensor can't arm it in time. The sensor only listens for the event.
 *
 * The mode is set again every time the screen turns on and when the touchfeature HAL
 * restarts, so a reset in the HAL or the driver can't leave it disarmed for the next
 * suspend.
 */
object DoubleTapController {

    private const val TAG = "DoubleTapController"
    private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)

    private const val TOUCH_ID_PRIMARY = 0
    private const val TOUCH_DOUBLETAP_MODE = 14
    private const val RETRY_DELAY_MS = 1000L

    @Volatile private var touchFeature: ITouchFeature? = null
    private lateinit var appContext: Context
    // getTouchFeature() blocks until the HAL is back after a restart, so keep it off the
    // main thread.
    private val handler by lazy { Handler(HandlerThread(TAG).apply { start() }.looper) }

    private val deathRecipient =
        IBinder.DeathRecipient {
            if (DEBUG) Log.d(TAG, "serviceDied")
            touchFeature = null
            handler.post { update(appContext) }
        }

    fun init(context: Context) {
        appContext = context
        val resolver = context.contentResolver
        val observer =
            object : ContentObserver(handler) {
                override fun onChange(selfChange: Boolean) = update(context)
            }
        resolver.registerContentObserver(
            Settings.Secure.getUriFor(Settings.Secure.DOZE_DOUBLE_TAP_GESTURE),
            false,
            observer,
            UserHandle.USER_ALL,
        )
        context.registerReceiver(
            object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) = update(context)
            },
            IntentFilter(Intent.ACTION_SCREEN_ON),
            null,
            handler,
        )
        handler.post { update(context) }
    }

    private fun update(context: Context, retry: Boolean = true) {
        // Unset means on (config_dozeDoubleTapGestureEnabled), so match it here or the
        // toggle shows as enabled while the gesture stays disarmed.
        val enabled =
            Settings.Secure.getIntForUser(
                context.contentResolver,
                Settings.Secure.DOZE_DOUBLE_TAP_GESTURE,
                1,
                UserHandle.USER_CURRENT,
            ) != 0
        if (DEBUG) Log.d(TAG, "double tap enabled=$enabled")
        val touchFeature = getTouchFeature() ?: return
        val value = if (enabled) 1 else 0
        runCatching {
            touchFeature.setModeValue(TOUCH_ID_PRIMARY, TOUCH_DOUBLETAP_MODE, value)
            touchFeature.getModeCurValue(TOUCH_ID_PRIMARY, TOUCH_DOUBLETAP_MODE)
        }
            .onSuccess { current ->
                Log.i(TAG, "Double tap mode set to $value, driver reports $current")
                // A HAL that just came up can drop the first write, so check it took and
                // try once more.
                if (current != value && retry) {
                    handler.postDelayed({ update(context, retry = false) }, RETRY_DELAY_MS)
                }
            }
            .onFailure { e -> Log.e(TAG, "setModeValue failed!", e) }
    }

    @Synchronized
    private fun getTouchFeature(): ITouchFeature? =
        touchFeature
            ?: runCatching {
                val binder = android.os.Binder.allowBlocking(
                    ServiceManager.waitForDeclaredService("${ITouchFeature.DESCRIPTOR}/default")
                )
                ITouchFeature.Stub.asInterface(binder).apply {
                    asBinder().linkToDeath(deathRecipient, 0)
                }
            }
            .onSuccess { touchFeature = it }
            .onFailure { e -> Log.e(TAG, "getTouchFeature failed!", e) }
            .getOrNull()
}

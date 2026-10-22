/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.touch

import android.content.Context
import android.database.ContentObserver
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.ServiceManager
import android.os.UserHandle
import android.provider.Settings
import android.util.Log
import vendor.xiaomi.hw.touchfeature.ITouchFeature

/**
 * Keeps the touch IC's double tap gesture armed while the double tap setting is on. The
 * driver only applies gestures when the panel suspends, before doze registers the double
 * tap sensor, so the sensor can't arm it in time. The sensor only listens for the event.
 */
object DoubleTapController {

    private const val TAG = "DoubleTapController"
    private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)

    private const val TOUCH_ID_PRIMARY = 0
    private const val TOUCH_DOUBLETAP_MODE = 14

    @Volatile private var touchFeature: ITouchFeature? = null

    private val deathRecipient =
        IBinder.DeathRecipient {
            if (DEBUG) Log.d(TAG, "serviceDied")
            touchFeature = null
        }

    fun init(context: Context) {
        val resolver = context.contentResolver
        val observer =
            object : ContentObserver(Handler(Looper.getMainLooper())) {
                override fun onChange(selfChange: Boolean) = update(context)
            }
        resolver.registerContentObserver(
            Settings.Secure.getUriFor(Settings.Secure.DOZE_DOUBLE_TAP_GESTURE),
            false,
            observer,
            UserHandle.USER_ALL,
        )
        update(context)
    }

    private fun update(context: Context) {
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
        runCatching {
            touchFeature.setModeValue(TOUCH_ID_PRIMARY, TOUCH_DOUBLETAP_MODE, if (enabled) 1 else 0)
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

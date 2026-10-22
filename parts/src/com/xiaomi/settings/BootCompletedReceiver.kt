/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.UserHandle
import android.provider.Settings
import android.util.Log
import com.xiaomi.settings.display.ColorService
import com.xiaomi.settings.touch.DoubleTapController

class BootCompletedReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (DEBUG) Log.d(TAG, "Received boot completed intent: ${intent.action}")
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> onBootCompleted(context)
            Intent.ACTION_LOCKED_BOOT_COMPLETED -> onLockedBootCompleted(context)
        }
    }

    private fun onBootCompleted(context: Context) {
    }

    private fun onLockedBootCompleted(context: Context) {
        // Display
        ColorService.startService(context)
        enforceMinRefreshRate(context)

        // Touch
        DoubleTapController.init(context.applicationContext)
    }

    /**
     * The panel flickers when surfaceflinger drops it from 120Hz to its 30Hz mode on idle.
     * Keep the render frame rate at 60Hz or above so the 30Hz mode is never picked.
     */
    private fun enforceMinRefreshRate(context: Context) {
        val minRefreshRate =
            Settings.System.getFloatForUser(
                context.contentResolver,
                Settings.System.MIN_REFRESH_RATE,
                0f,
                UserHandle.USER_CURRENT,
            )
        if (minRefreshRate >= MIN_REFRESH_RATE) return
        if (DEBUG) Log.d(TAG, "Raising min refresh rate from $minRefreshRate to $MIN_REFRESH_RATE")
        Settings.System.putFloatForUser(
            context.contentResolver,
            Settings.System.MIN_REFRESH_RATE,
            MIN_REFRESH_RATE,
            UserHandle.USER_CURRENT,
        )
    }

    companion object {
        private const val TAG = "BootReceiver"
        private val DEBUG = Log.isLoggable(TAG, Log.DEBUG)

        private const val MIN_REFRESH_RATE = 60f
    }
}

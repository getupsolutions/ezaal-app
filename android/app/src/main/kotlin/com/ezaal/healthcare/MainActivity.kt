package com.ezaal.healthcare

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onResume() {
        super.onResume()
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // FIX: Channel IDs now exactly match Flutter's kEhcChannels list.
        // Previously this used old IDs without _v2 suffix, so Android played
        // the wrong (or default) sound and Flutter's channel lookup failed.
        val channels = listOf(
            Triple("ehc_shift_approved_v2", "Shift Approved",   "approved"),
            Triple("ehc_shift_rejected_v2", "Shift Rejected",   "rejected"),
            Triple("ehc_new_shift_v2",      "New Shift",        "new_shift"),
            Triple("ehc_staff_signout_v2",  "Staff Signout",    "notification"),
            Triple("ehc_staff_accept_v2",   "Staff Shift Claim","notification"),
            Triple("ehc_default_v3",        "General",          "notification"),
        )

        for ((id, name, soundFile) in channels) {
            // Skip if already exists — never reset user's notification preferences
            if (nm.getNotificationChannel(id) != null) continue

            val soundUri = Uri.parse(
                "android.resource://${packageName}/raw/$soundFile"
            )
            val audioAttr = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            val channel = NotificationChannel(
                id,
                name,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "$name notifications"
                enableVibration(true)
                setSound(soundUri, audioAttr)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                // FIX: Enable lights so the notification LED works on devices that have it
                enableLights(true)
            }
            nm.createNotificationChannel(channel)
        }
    }
}
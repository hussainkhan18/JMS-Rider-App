package com.jal.rider

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    // 🔹 Create a custom FCM notification channel with local sound
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = Uri.parse("android.resource://" + packageName + "/" + R.raw.rider_water_notification)

            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()

            val channel = NotificationChannel(
                "rider_default_channel", // must match Manifest meta-data
                "Rider Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setSound(soundUri, attributes)
                enableLights(true)
                enableVibration(true)
                description = "Custom notification sound for JMS Rider app"
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}

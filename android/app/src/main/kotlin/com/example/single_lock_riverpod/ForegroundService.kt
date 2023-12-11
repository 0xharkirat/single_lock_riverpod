package com.example.single_lock_riverpod

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import java.util.*

class ForegroundService : Service() {
    val TAG = "HarkForeground"

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ECLAIR) {
            startForeground(NOTIFICATION_ID, createNotification())
        }
        startContinue()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setContentTitle("Foreground Service")
                .setContentText("Detecting YouTube launches...")
                .setContentIntent(pendingIntent)
                .build()
    }

    private fun startContinue() {
        val timer = object : CountDownTimer(Long.MAX_VALUE, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                printForegroundAppPackageName(this@ForegroundService)
            }

            override fun onFinish() {
                Log.d(TAG, "onFinish: called")
            }
        }

        timer.start()
    }

    private fun printForegroundAppPackageName(context: Context) {
        // Get the current foreground app package name using UsageStats
        val packageName = getActiveAppPackageName(context)
        Log.d("ForegroundService", "Foreground App Package: $packageName")
    }

    private fun getActiveAppPackageName(context: Context): String {
        var pkgName: String? = null
        val usageStatsManager = context
                .getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val timeTnterval = (1000 * 600).toLong()
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - timeTnterval
        val myUsageEvents: UsageEvents = usageStatsManager.queryEvents(beginTime, endTime)
        while (myUsageEvents.hasNextEvent()) {
            val myEvent: UsageEvents.Event = UsageEvents.Event()
            myUsageEvents.getNextEvent(myEvent)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                when (myEvent.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> pkgName = myEvent.packageName
                    UsageEvents.Event.ACTIVITY_PAUSED -> if (myEvent.packageName.equals(pkgName)) {
                        pkgName = null
                    }
                }
            } else {
                when (myEvent.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> pkgName = myEvent.packageName
                    UsageEvents.Event.ACTIVITY_RESUMED -> if (myEvent.packageName.equals(pkgName)) {
                        pkgName = null
                    }
                }
            }
        }
        if (pkgName == null){
            var currentApp = ""
            val usm = this.getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
            val time = System.currentTimeMillis()
            val appList =
                    usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000 * 1000, time)
            if (appList != null && appList.size > 0) {
                val mySortedMap: SortedMap<Long, UsageStats> = TreeMap()
                for (usageStats in appList) {
                    mySortedMap[usageStats.lastTimeUsed] = usageStats
                }
                if (mySortedMap != null && !mySortedMap.isEmpty()) {
                    currentApp = mySortedMap[mySortedMap.lastKey()]!!.packageName
                }
            }
            return currentApp
        }
        else{
            return  pkgName
        }

    }


    companion object {
        const val NOTIFICATION_ID = 1
        const val NOTIFICATION_CHANNEL_ID = "ForegroundServiceChannel"
    }
}

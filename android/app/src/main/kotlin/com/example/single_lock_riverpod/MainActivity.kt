package com.example.single_lock_riverpod

import android.app.AppOpsManager
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            // This method is invoked on the main thread.
            when {
                call.method.equals("checkOverlayPermission") -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                call.method.equals("askOverlayPermission") -> {
                    result.success(checkOverlayPermission())
                }
                call.method.equals("askUsageStatsPermission") -> {
                    if (!isAccessGranted()) {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        startActivity(intent)
                    }
                }
                call.method.equals("startForegroundService") -> {
                    startForegroundService();

                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkOverlayPermission():Boolean {
        if (!Settings.canDrawOverlays(this)) {
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(myIntent)
        }
        return Settings.canDrawOverlays(this)
    }

    private fun isAccessGranted(): Boolean {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(
                    packageName, 0
            )
            val appOpsManager: AppOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val mode = appOpsManager.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    applicationInfo.uid, applicationInfo.packageName
            )
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun startForegroundService() {
        val serviceIntent = Intent(this, ForegroundService::class.java)
        startService(serviceIntent)
    }

}

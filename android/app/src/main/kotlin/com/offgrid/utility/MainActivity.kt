package com.offgrid.utility

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.offgrid.utility/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryTemperature") {
                val temp = getBatteryTemperature()
                if (temp != null) {
                    result.success(temp)
                } else {
                    result.error("UNAVAILABLE", "Battery temperature not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryTemperature(): Double? {
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus: Intent? = context.registerReceiver(null, intentFilter)
        if (batteryStatus != null) {
            val tempInt = batteryStatus.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
            if (tempInt > 0) {
                // Battery temperature is returned in tenths of a degree Centigrade
                return tempInt / 10.0
            }
        }
        return null
    }
}

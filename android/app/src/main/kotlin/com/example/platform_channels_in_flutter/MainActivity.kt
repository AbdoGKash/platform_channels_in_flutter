package com.example.platform_channels_in_flutter

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var sensorManager: SensorManager? = null
    private var accelSensor: Sensor? = null
    private var lastAccel = FloatArray(3)
    private var lastTimestamp: Long = 0
    private var lastShakeTimestamp: Long = 0

    private val SHAKE_THRESHOLD = 14.0f 
    private val SHAKE_SLOP_MS = 700L 

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.shake/event")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startListening()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    stopListening()
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.shake/method")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        startListening()
                        result.success(null)
                    }
                    "stop" -> {
                        stopListening()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private val sensorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent?) {
            if (event == null) return
            val now = SystemClock.elapsedRealtime()

            if (lastTimestamp == 0L) {
                lastTimestamp = now
                lastAccel[0] = event.values[0]
                lastAccel[1] = event.values[1]
                lastAccel[2] = event.values[2]
                return
            }

            val dx = event.values[0] - lastAccel[0]
            val dy = event.values[1] - lastAccel[1]
            val dz = event.values[2] - lastAccel[2]
            val delta = Math.sqrt((dx*dx + dy*dy + dz*dz).toDouble()).toFloat()

            lastAccel[0] = event.values[0]
            lastAccel[1] = event.values[1]
            lastAccel[2] = event.values[2]
            lastTimestamp = now

            if (delta > SHAKE_THRESHOLD) {
                if (now - lastShakeTimestamp > SHAKE_SLOP_MS) {
                    lastShakeTimestamp = now
                    eventSink?.success(mapOf("type" to "shake", "ts" to now))
                }
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    private fun startListening() {
        accelSensor?.let {
            sensorManager?.registerListener(sensorListener, it, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    private fun stopListening() {
        sensorManager?.unregisterListener(sensorListener)
    }

    override fun onResume() {
        super.onResume()
        eventSink?.let { startListening() }
    }

    override fun onPause() {
        super.onPause()
        stopListening()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopListening()
    }
}


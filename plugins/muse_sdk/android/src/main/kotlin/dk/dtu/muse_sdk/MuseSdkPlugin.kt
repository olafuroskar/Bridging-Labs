package dk.dtu.muse_sdk

import android.content.Context
import com.choosemuse.libmuse.MuseManagerAndroid
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** MuseSdkPlugin */
class MuseSdkPlugin : FlutterPlugin, MethodCallHandler {

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var controller: MuseSdkController

    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    private lateinit var dataEventChannel: EventChannel
    private var eventDataSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "muse_sdk")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        controller = MuseSdkController()

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "muse_sdk/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                controller.setEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                controller.setEventSink(null)
            }
        })

        dataEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "muse_sdk/data_events")
        dataEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventDataSink = events
                controller.setDataEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                eventDataSink = null
                controller.setDataEventSink(null)
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "initialize" -> {
                controller.initialize(context)
                result.success(null)
            }

            "isBluetoothEnabled" -> result.success(controller.isBluetoothEnabled())
            "refreshMuseList" -> {
                controller.refreshMuseList()
                result.success(null)
            }

            "connectToMuse" -> {
                val index = call.argument<Int>("index") ?: 0
                controller.connectToMuse(index)
                result.success(null)
            }

            "disconnectMuse" -> {
                controller.disconnectMuse()
                result.success(null)
            }

            "togglePause" -> {
                controller.togglePause()
                result.success(null)
            }

            "getLatestPpg" -> result.success(controller.getLatestPpg().toList())
            "getLatestEeg" -> result.success(controller.getLatestEeg().toList())
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

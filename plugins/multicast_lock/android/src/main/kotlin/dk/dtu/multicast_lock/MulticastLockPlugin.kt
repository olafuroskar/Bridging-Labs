package dk.dtu.multicast_lock

import android.content.Context
import android.net.wifi.WifiManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**  MulticastLockPlugin */
class MulticastLockPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var multicastLock: WifiManager.MulticastLock? = null
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "multicast_lock")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "acquireMulticastLock") {
            result.success(acquireMulticastLock())
        } else if (call.method == "releaseMulticastLock") {
            result.success(releaseMulticastLock())
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun acquireMulticastLock(): Boolean {
        return try {
            val wifiManager =
                context?.getSystemService(Context.WIFI_SERVICE) as WifiManager
            multicastLock = wifiManager.createMulticastLock("multicastLock")
            multicastLock?.setReferenceCounted(true)
            multicastLock?.acquire()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun releaseMulticastLock(): Boolean {
        return try {
            multicastLock?.let {
                if (it.isHeld) {
                    it.release()
                }
            }
            multicastLock = null
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}

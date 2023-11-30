package com.mrtnetwork.mrt_native_support

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.view.WindowManager
import com.mrtnetwork.mrt_native_support.connection.ConnectionBroadcast
import com.mrtnetwork.mrt_native_support.connection.NetworkEvent
import com.mrtnetwork.mrt_native_support.encryptions.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.util.PathUtils


/** Mrt_nPlugin */
class MrtNativeSupport : FlutterPlugin, MethodChannel.MethodCallHandler, MrtService() {
    override lateinit var methodChannel: MethodChannel
    override lateinit var applicationContext: Context

    override fun onNewIntent(intent: Intent): Boolean {
        TODO("Not yet implemented")
    }

    override var mainActivity: Activity? = null
    private val connectionManager: ConnectionBroadcast = ConnectionBroadcast()


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        this.applicationContext = flutterPluginBinding.applicationContext

        this.methodChannel = MethodChannel(
                flutterPluginBinding.binaryMessenger, "com.metnetwork.mrt_n.methodChannel"
        )
        this.methodChannel.setMethodCallHandler(this)
        EncryptionImpl.init(applicationContext)
        connectionManager.listenOnNetwork(applicationContext)


    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        connectionManager.cancelListen(applicationContext)

    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        @Suppress("UNCHECKED_CAST") val args: Map<String, Any?> =
                call.arguments as Map<String, Any?>
        when (call.method) {
            "logging" -> {
                // MrtCore.logging("logging event: $args")
            }

            "secureFlag" -> {
                try {
                    val secure = args["secure"] as Boolean
                    val isSecure = secureApplication(secure)
                    result.success(isSecure)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, "")
                }
            }

            "path" -> result.success(getPath())
            "info" -> result.success(deviceInfo())
            "lunch_uri" -> result.success(lunchUrl(args["uri"] as String?))
            "network" -> {
                val event: NetworkEvent = connectionManager.connectivity.networkType
                result.success(event.toJson())
            }

            else -> super.onMethodCall(call, result)

        }

    }


    private fun secureApplication(secure: Boolean): Boolean {
        if (secure) {
            mainActivity?.window?.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE
            )

        } else {
            mainActivity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        return secure
    }


    private fun lunchUrl(uri: String?): Boolean {
        try {

            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(uri))
            mainActivity!!.startActivity(browserIntent)
            return true
        } catch (e: Exception) {
            return false
        }
    }

    @Suppress("DEPRECATION")
    private fun appVersion(): String {
        val packageManager = applicationContext.packageManager
        val appInfo = packageManager.getPackageInfo(applicationContext.packageName, 0)
        return appInfo.versionName
    }

    private fun deviceInfo(): HashMap<String, Any?> {

        val info = HashMap<String, Any?>()
        info["brand"] = Build.BRAND
        info["device"] = Build.DEVICE
        info["display"] = Build.DISPLAY
        info["id"] = Build.ID
        info["model"] = Build.MODEL
        info["product"] = Build.PRODUCT
        info["app_version"] = appVersion()
        info["sdk_version"] = Build.VERSION.SDK_INT
        return info
    }

    private fun getPath(): HashMap<String, Any?> {

        val info = HashMap<String, Any?>()
        info["document"] = PathUtils.getDataDirectory(applicationContext)
        info["cache"] = applicationContext.cacheDir.path
        info["support"] = PathUtils.getFilesDir(applicationContext)
        return info
    }


}

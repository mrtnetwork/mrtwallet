package com.mrtnetwork.mrt_native_support

import android.app.Activity
import android.content.Context
import androidx.lifecycle.MutableLiveData
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


abstract class AppEvent(val text: Any) {

    abstract fun toJson(): HashMap<String, Any?>
}


interface MrtCore {
    companion object {


        val liveData = MutableLiveData<Any>()

        fun updateLiveData(notification: Any) {
            liveData.postValue(notification)
        }

        fun logging(message: String, TAG: String? = null) {
//            if (TAG != "debug") return
//            return
            Log.e(TAG ?: "mrt_service", message)
        }

        const val REQUEST_CODE_SCAN = 49374;
        const val BARCODE_SUCCESS_TYPE = "success"
        const val BARCODE_SUCCESS_ERROR = "error"
        const val BARCODE_SUCCESS_CANCEL = "cancel"
        const val BARCODE_CHANNEL_RESPONSE_EVENT = "onBarcodeScanned"

        @Suppress("UNCHECKED_CAST")
        fun getMapArguments(call: MethodCall, result: MethodChannel.Result): Map<String, Any?>? {
            return try {
                call.arguments as? Map<String, Any?>
            } catch (e: Exception) {
                result.error(
                    "ARGUMENT_CAST_ERROR",
                    "Failed to cast arguments to Map<String, Any?>",
                    e.localizedMessage
                )
                null
            }
        }


    }


    fun onMethodCall(call: MethodCall, result: MethodChannel.Result)
    var methodChannel: MethodChannel
    var mainActivity: Activity?
    var applicationContext: Context
    var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding?

}



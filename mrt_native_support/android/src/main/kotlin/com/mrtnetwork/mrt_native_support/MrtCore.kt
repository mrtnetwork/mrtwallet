package com.mrtnetwork.mrt_native_support

import android.app.Activity
import android.content.Context
import androidx.lifecycle.MutableLiveData
import io.flutter.Log
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
            Log.e(TAG ?: "mrt_service", message)
        }
    }


    fun onMethodCall(call: MethodCall, result: MethodChannel.Result)
    var methodChannel: MethodChannel
    var mainActivity: Activity?
    var applicationContext: Context

}



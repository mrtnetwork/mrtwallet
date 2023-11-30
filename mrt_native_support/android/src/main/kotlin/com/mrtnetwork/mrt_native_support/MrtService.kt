package com.mrtnetwork.mrt_native_support

import android.os.Build
import androidx.annotation.RequiresApi
import com.mrtnetwork.mrt_native_support.connection.NetworkEvent
import com.mrtnetwork.mrt_native_support.encryptions.EncryptionImpl
import com.mrtnetwork.mrt_native_support.share.ShareImpl
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.service.ServiceAware
import io.flutter.embedding.engine.plugins.service.ServicePluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

abstract class MrtService : ActivityAware, EncryptionImpl, ShareImpl, PluginRegistry.NewIntentListener, ServiceAware {


    @RequiresApi(Build.VERSION_CODES.Q)
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mainActivity = binding.activity
        binding.addOnNewIntentListener(this)

        MrtCore.liveData.observeForever { handleObs(it) }

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "secureStorage" -> {
                super<EncryptionImpl>.onMethodCall(call, result)
            }

            "share" -> {
                super<ShareImpl>.onMethodCall(call, result)
            }
        }

    }

    override fun onDetachedFromActivityForConfigChanges() {
        mainActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        mainActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        mainActivity = null

    }

    override fun onAttachedToService(binding: ServicePluginBinding) {
    }


    override fun onDetachedFromService() {
    }

    private fun handleObs(update: Any) {
        when (update::class) {
            NetworkEvent::class -> {
                update as NetworkEvent
                methodChannel.invokeMethod(update.toString(), update.toJson())
            }
        }
    }

}


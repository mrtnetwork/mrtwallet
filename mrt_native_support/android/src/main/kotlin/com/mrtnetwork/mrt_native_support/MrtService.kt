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
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions
import com.google.mlkit.vision.barcode.common.Barcode


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
            "stopBarcodeScanner" ->{
                result.success(true);
            }
            "startBarcodeScanner" ->{
                barcodeScan(result);
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

    private fun barcodeScan(result: MethodChannel.Result){
        MrtCore.logging("started")
        val options = GmsBarcodeScannerOptions.Builder()
            .setBarcodeFormats( Barcode.FORMAT_ALL_FORMATS).enableAutoZoom()
            .build()
        val scanner = GmsBarcodeScanning.getClient(applicationContext)
        scanner.startScan()
            .addOnSuccessListener { barcode ->
                val rawValue: String? = barcode.rawValue
                // Task completed successfully

                if(rawValue!= null){
                    val message = HashMap<String, Any?>()
                    message["type"] = "success"
                    message["message"] = rawValue
                    methodChannel.invokeMethod("onBarcodeScanned",message)
                  
                }
            }
            .addOnCanceledListener {
                    val message = HashMap<String, Any?>()
                    message["type"] = "cancel"
                    methodChannel.invokeMethod("onBarcodeScanned",message)
            }
            .addOnFailureListener { e: Exception ->
                    val message = HashMap<String, Any?>()
                    message["type"] = "cancel"
                    message["message"] = e.message
                    methodChannel.invokeMethod("onBarcodeScanned",message)        
            }
      result.success(null);

    }

}


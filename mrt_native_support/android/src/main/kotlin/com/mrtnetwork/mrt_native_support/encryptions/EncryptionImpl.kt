package com.mrtnetwork.mrt_native_support.encryptions

import android.content.Context

import com.mrtnetwork.mrt_native_support.MrtCore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

interface EncryptionImpl : MrtCore {
    companion object {
        private lateinit var encryption: AppEncryption

        fun init(context: Context) {

            encryption = AppEncryption.init(context)
        }

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST") val args: Map<String, Any?> =
                call.arguments as Map<String, Any?>
        when (call.method) {
            "crypto" -> {
                try {

                    val encResult = encryption.handleEncryption(args)
                    result.success(encResult)
                } catch (e: Exception) {
                    result.error("-1", e.message, "")
                }
            }

            "secureStorage" -> {
                try {
                    val res = encryption.handleStorage(args)
                    result.success(res)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, "")
                }
            }
        }
    }

}
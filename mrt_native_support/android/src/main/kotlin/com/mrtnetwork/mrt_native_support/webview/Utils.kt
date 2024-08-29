package com.mrtnetwork.mrt_native_support.webview

import android.content.Context
import android.content.res.AssetManager
import android.graphics.Bitmap
import android.webkit.WebView
import java.io.ByteArrayOutputStream

interface WebViewUtils {
    companion object {
        fun String.decodeHex(): List<Int>? {
            if (length % 2 != 0) return null
            return chunked(2)
                .map { it.toInt(16) }
                .toList()
        }

        @ExperimentalUnsignedTypes // just to make it clear that the experimental unsigned types are used
        fun ByteArray.toHex() = asUByteArray().joinToString("") { it.toString(16).padStart(2, '0') }
        fun getFlutterAssetContent(context: Context, assetName: String): String? {
            val assetManager: AssetManager = context.assets
            val assetPath = "flutter_assets/$assetName"
            return try {
                assetManager.open(assetPath).bufferedReader().use { it.readText() }
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
        fun toJson(
            id: String,
            eventName: String,
            view: WebView? = null,
            message: String? = null,
            url: String? = null,
            favicon: String? = null,
            progress: Int? = null,
            request: WebViewRequest? = null
        ): WebViewData {
            return WebViewData(
                id,
                eventName,
                url ?: view?.url,
                favicon,
                view?.originalUrl,
                view?.title,
                message,
                progress,
                request
            )
        }
    }
}
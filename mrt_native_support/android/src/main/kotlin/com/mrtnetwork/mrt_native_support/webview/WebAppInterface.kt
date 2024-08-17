package com.mrtnetwork.mrt_native_support.webview

import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface
import android.webkit.WebView
import com.mrtnetwork.mrt_native_support.MrtCore
import com.mrtnetwork.mrt_native_support.webview.WebViewUtils.Companion.decodeHex
import io.flutter.plugin.common.MethodChannel


class WebAppInterface(private val channel: MethodChannel,  val viewType: String, private val webView: WebView) {


    @JavascriptInterface
    fun onMrtJsRequest(id: String, data: String, requestId: String,type:String) {
        val byteArray: List<Int> = data.decodeHex() ?: return
        val request = WebViewRequest(id, byteArray, requestId,type)
        Handler(Looper.getMainLooper()).post {
            val toJson = WebViewUtils.toJson(viewType, WebViewConst.request,webView, request = request)
            channel.invokeMethod(WebViewConst.webView, toJson.toJson())
            MrtCore.logging("send request to main ${toJson.toJson()}", "WebView")
        }
    }
    @JavascriptInterface
    fun scriptId(): String {
        return viewType
    }

}
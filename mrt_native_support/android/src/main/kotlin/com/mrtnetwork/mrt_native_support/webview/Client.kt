package com.mrtnetwork.mrt_native_support.webview

import android.graphics.Bitmap
import android.os.Build
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import com.mrtnetwork.mrt_native_support.MrtCore
import io.flutter.plugin.common.MethodChannel

class CustomWebViewClient(private val methodChannel: MethodChannel, val id: String) : WebViewClient() {

    override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        MrtCore.logging("onpage start","WEBVIEW: ") 
        view.evaluateJavascript(  "(function() {" +
                "var links = document.getElementsByTagName('link');" +
                "for (var i = 0; i < links.length; i++) {" +
                "    if (links[i].rel.includes('icon')) {" +
                "        return links[i].href;" +
                "    }" +
                "}" +
                "for (var i = 0; i < links.length; i++) {" +
                "    if (links[i].rel.includes('shortcut icon')) {" +
                "        return links[i].href;" +
                "    }" +
                "}" +
                "return null;" +
                "})()") { result ->
            if (result != null) {
                val data = WebViewUtils.toJson(id,WebViewConst.onPageStart,view, url = url, favicon = result)
                methodChannel.invokeMethod(WebViewConst.webView, data.toJson())
            } else {
                val data = WebViewUtils.toJson(id,WebViewConst.onPageStart,view, url = url)
                methodChannel.invokeMethod(WebViewConst.webView, data.toJson())
            }
        }
    }

    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        val data = WebViewUtils.toJson(id,WebViewConst.onPageFinished,view, url = url)
        methodChannel.invokeMethod(WebViewConst.webView, data.toJson())
        MrtCore.logging("onpage finish","WEBVIEW: ")
    }

    override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) {
        super.onReceivedError(view, request, error)
        val errorMessage = if (Build.VERSION.SDK_INT < 23) {
            error.toString()
        } else {
            error.description.toString()
        }
        val data = WebViewUtils.toJson(id,WebViewConst.onPageError,view, message = errorMessage)
        methodChannel.invokeMethod(WebViewConst.webView, data.toJson())
        MrtCore.logging("onpage erroriyoya","WEBVIEW: ")
    }

}

class CustomWebChromeClient(private val methodChannel: MethodChannel, val id: String) : WebChromeClient() {
    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        val data = WebViewUtils.toJson(id,WebViewConst.onPageProgress,view, progress = newProgress)
        methodChannel.invokeMethod(WebViewConst.webView, data.toJson())
        MrtCore.logging("onProgressChanged $newProgress","WebView")
    }

}
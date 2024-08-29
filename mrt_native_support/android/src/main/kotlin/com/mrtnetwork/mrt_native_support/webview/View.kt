package com.mrtnetwork.mrt_native_support.webview

import android.annotation.SuppressLint
import android.content.Context
import android.view.View
import android.webkit.WebView
import com.mrtnetwork.mrt_native_support.MrtCore
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

interface Callback<T> {
    fun onSuccess(data: T)
    fun onFailure(message: String)
}

@SuppressLint("SetJavaScriptEnabled")
class WebViewPlatformView(
    context: Context?,
    url: String?,
    jsInterface:String?,
   private val channel: MethodChannel,
    private val id: String
) :
    PlatformView {
    private val webView: WebView = WebView(context!!)

    init {
        webView.settings.javaScriptEnabled = true
        webView.webViewClient = CustomWebViewClient(channel, id)
        webView.webChromeClient = CustomWebChromeClient(channel, id)

        if (url != null) {
            webView.loadUrl(url)
        }

    }

    override fun getView(): View {
        return webView
    }

    override fun dispose() {
        WebViewHandlers.dispose(id)
        webView.destroy()
        MrtCore.logging("disppsed", "WebView")
    }
    fun addMrtJsInterface(name: String){
        webView.addJavascriptInterface(WebAppInterface(channel,id,webView), name)

    }
    fun removeMrtJsInterface(name:String){
        webView.removeJavascriptInterface(name)

    }
    fun injectJavaScript(jsCode: String, callback: Callback<String?>) {
        webView.evaluateJavascript(jsCode) { result ->
            if (result != null) {
                callback.onSuccess(result)
            } else {
                val errorMessage = "JavaScript evaluation failed"
                callback.onFailure(errorMessage)
            }
        }
    }
//    fun injectJavaScriptFile(jsCode: String, callback: Callback<String?>) {
//
//        webView.loadUrl()
//    }

    fun openPage(url: String) {
        webView.loadUrl(url)
    }

    fun canGoForward(): Boolean {
        return webView.canGoForward()
    }

    fun canGoBack(): Boolean {
        return webView.canGoBack()
    }

    fun goBack() {
        webView.goBack()
    }

    fun goForward() {
        webView.goForward()
    }

    fun reload() {
        webView.reload()
    }

}
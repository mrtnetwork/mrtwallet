package com.mrtnetwork.mrt_native_support.webview

import android.content.Context
import com.mrtnetwork.mrt_native_support.MrtCore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.concurrent.ConcurrentHashMap

class WebViewFactory(private val view: WebViewPlatformView) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, id: Int, args: Any?): PlatformView {
        return view
    }

    fun addMrtJsInterface(name: String) {
        view.addMrtJsInterface(name)

    }

    fun removeMrtJsInterface(name: String) {
        view.removeMrtJsInterface(name)
    }

    fun openPage(url: String) {
        view.openPage(url);
    }

    fun injectJavaScript(jsCode: String, callback: Callback<String?>) {
        view.injectJavaScript(jsCode, callback)
    }

    fun canGoForward(): Boolean {
        return view.canGoForward()
    }

    fun canGoBack(): Boolean {
        return view.canGoBack()
    }

    fun goBack() {
        view.goBack()
    }

    fun goForward() {
        view.goForward()
    }

    fun reload() {
        view.reload()
    }

}


class WebViewHandlers() {
    companion object {
        private val webViewFactories = ConcurrentHashMap<String, WebViewFactory>()
        fun getWebView(args: Map<String, Any?>): WebViewFactory? {
            val id: String = args["id"] as String? ?: return null
            return webViewFactories[id]
        }

        fun dispose(id: String) {
            webViewFactories.remove(id)
        }

        fun initFactory(
            args: Map<String, Any?>,
            channel: MethodChannel,
            context: Context?,
            binding: FlutterPlugin.FlutterPluginBinding?
        ): Boolean {
            val id: String = args["id"] as String? ?: return false
            if (webViewFactories.containsKey(id)) return false
            if (context == null || binding == null) return false
            val url: String? = args["url"] as String?
            val jsInterface: String? = args["jsInterface"] as String?
            val platformView = WebViewPlatformView(context, url, jsInterface, channel, id)
            val webViewFactory = WebViewFactory(platformView)
            binding.platformViewRegistry.registerViewFactory(id, webViewFactory)
            if(jsInterface!= null){
                platformView.addMrtJsInterface( jsInterface)
            }
            MrtCore.logging("addjs interface:${jsInterface} ")
            webViewFactories[id] = webViewFactory
            return true
        }
    }
}
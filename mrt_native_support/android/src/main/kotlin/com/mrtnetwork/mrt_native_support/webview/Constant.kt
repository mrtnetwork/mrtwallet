package com.mrtnetwork.mrt_native_support.webview

interface WebViewConst {
    companion object{

        const val onPageStart: String = "OnPageStart"
        const val onPageError: String = "onPageError"
        const val onPageFinished: String = "onPageFinished"
        const val onPageProgress: String = "onPageProgress"
        const val openPage: String = "openPage"
        const val addInterface: String = "addJsInterface"
        const val removeInterface: String = "removeJsInterface"
        const val createWebView: String = "createWebView"
        const val webView: String = "webView"
        const val injectJavaScript: String = "injectJavaScript"
        const val canGoForward: String = "canGoForward"
        const val canGoBack: String = "canGoBack"
        const val goBack: String = "goBack"
        const val goForward: String = "goForward"
        const val reload: String = "reload"
        const val request: String = "request"
        const val dispose: String = "dispose"

    }

}
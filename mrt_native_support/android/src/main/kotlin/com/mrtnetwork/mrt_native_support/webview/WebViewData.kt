package com.mrtnetwork.mrt_native_support.webview

data class WebViewData(
    val id: String, val eventName: String, val url: String? = null,
    val favicon: String? = null,
    val originalUrl: String? = null,
    val title: String? = null,
    val message: String? = null,
    val progress: Int? = null,
    val request: WebViewRequest? = null
) {
    fun toJson(): HashMap<String, Any?> {
        return hashMapOf(
            "id" to id,
            "eventName" to eventName,
            "url" to url,
            "favicon" to favicon,
            "originalUrl" to originalUrl,
            "title" to title,
            "message" to message,
            "progress" to progress,
            "request" to request?.toJson()

        )
    }
}

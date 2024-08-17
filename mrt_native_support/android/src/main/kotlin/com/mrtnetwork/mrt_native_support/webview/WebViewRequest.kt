package com.mrtnetwork.mrt_native_support.webview

data class WebViewRequest( val id: String,val data:List<Int>, val requestId:String,val type:String){
    fun toJson(): HashMap<String, Any?> {
        return hashMapOf(
            "client_id" to id,
            "data" to data,
            "request_id" to requestId,
            "type" to type
        )
    }


}

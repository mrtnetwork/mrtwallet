package com.mrtnetwork.mrt_native_support.connection

import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import com.mrtnetwork.mrt_native_support.AppEvent


class NetworkEvent(state: String) : AppEvent(state) {

    override fun toJson(): HashMap<String, Any?> {
        val map: HashMap<String, Any?> = HashMap()
        map["event"] = "Network"
        map["data"] = text
        return map
    }

    override fun toString(): String {
        return "Network"
    }

}

/** Reports connectivity related information such as connectivity type and wifi information.  */
class ConnectionManager(val connectivityManager: ConnectivityManager) {
    val networkType: NetworkEvent
        get() {
            return NetworkEvent(_networkType)
        }
    private val _networkType: String
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork
                val capabilities =
                    connectivityManager.getNetworkCapabilities(network) ?: return CONNECTIVITY_NONE
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    return CONNECTIVITY_WIFI
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    return CONNECTIVITY_ETHERNET
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                    return CONNECTIVITY_VPN
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                    return CONNECTIVITY_MOBILE
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) {
                    return CONNECTIVITY_BLUETOOTH
                }
            }
            return networkTypeLegacy
        }

    // handle type for Android versions less than Android 6
    @Suppress("DEPRECATION")
    private val networkTypeLegacy: String
        get() {
            // handle type for Android versions less than Android 6
            val info = connectivityManager.activeNetworkInfo
            if (info == null || !info.isConnected) {
                return CONNECTIVITY_NONE
            }
            val type = info.type
            return when (type) {
                ConnectivityManager.TYPE_BLUETOOTH -> CONNECTIVITY_BLUETOOTH
                ConnectivityManager.TYPE_ETHERNET -> CONNECTIVITY_ETHERNET
                ConnectivityManager.TYPE_WIFI, ConnectivityManager.TYPE_WIMAX -> CONNECTIVITY_WIFI
                ConnectivityManager.TYPE_VPN -> CONNECTIVITY_VPN
                ConnectivityManager.TYPE_MOBILE, ConnectivityManager.TYPE_MOBILE_DUN, ConnectivityManager.TYPE_MOBILE_HIPRI -> CONNECTIVITY_MOBILE
                else -> CONNECTIVITY_NONE
            }
        }

    companion object {
        const val CONNECTIVITY_NONE = "none"
        const val CONNECTIVITY_WIFI = "wifi"
        const val CONNECTIVITY_MOBILE = "mobile"
        const val CONNECTIVITY_ETHERNET = "ethernet"
        const val CONNECTIVITY_BLUETOOTH = "bluetooth"
        const val CONNECTIVITY_VPN = "vpn"
    }
}
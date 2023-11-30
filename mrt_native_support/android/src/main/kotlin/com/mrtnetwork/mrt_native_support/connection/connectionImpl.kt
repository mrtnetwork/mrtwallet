package com.mrtnetwork.mrt_native_support.connection

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.mrtnetwork.mrt_native_support.MrtCore

class ConnectionBroadcast() : BroadcastReceiver() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    lateinit var connectivity: ConnectionManager
    fun listenOnNetwork(context: Context) {
        val connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        connectivity = ConnectionManager(connectivityManager)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    sendEvent()
                }

                override fun onLost(network: Network) {
                    sendEvent(NetworkEvent(ConnectionManager.CONNECTIVITY_NONE))
                }
            }
            connectivity.connectivityManager.registerDefaultNetworkCallback(networkCallback!!)
        } else {
            context.registerReceiver(this, IntentFilter(CONNECTIVITY_ACTION))
        }
    }

    fun cancelListen(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (networkCallback != null) {
                connectivity.connectivityManager.unregisterNetworkCallback(networkCallback!!)
                networkCallback = null
            }
        } else {
            try {
                context.unregisterReceiver(this)
            } catch (e: Exception) {
                //listen never called, ignore the error
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        MrtCore.updateLiveData(connectivity.networkType)
    }


    private fun sendEvent(networkType: NetworkEvent? = null) {
        val runnable = Runnable { MrtCore.updateLiveData(networkType ?: connectivity.networkType) }
        mainHandler.post(runnable)
    }

    companion object {
        const val CONNECTIVITY_ACTION = "android.net.conn.CONNECTIVITY_CHANGE"
    }
}
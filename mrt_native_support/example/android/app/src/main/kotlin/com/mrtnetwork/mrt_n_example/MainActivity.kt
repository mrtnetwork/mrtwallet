package com.mrtnetwork.mrt

import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.ViewTreeObserver.OnWindowFocusChangeListener
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterFragmentActivity() {
    val TAG: String = "mrt_service"

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


    }

    override fun onResume() {
        super.onResume()
        Log.e("TAG", "OnResume")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("main_engin", flutterEngine)
    }


}
//    override fun



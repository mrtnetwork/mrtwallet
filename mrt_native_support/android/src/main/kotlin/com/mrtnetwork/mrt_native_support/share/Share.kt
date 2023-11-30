package com.mrtnetwork.mrt_native_support.share
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.mrtnetwork.mrt_native_support.MrtCore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

interface ShareImpl : MrtCore {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST") val args: Map<String, Any?> =
                call.arguments as Map<String, Any?>
        when (call.method) {
            "share" -> {
                try {
                    val text = args["text"] as String?
                    val subject = args["subject"] as String?
                    val path = args["path"] as String?
                    val mimetype = args["mimetype"] as String?
                    if (path != null && mimetype != null) {
                        shareFile(path, mimetype, text, subject)
                    } else if (text != null) {
                        shareText(text, subject)
                    } else {
                        result.success(false)
                        return
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("-1", e.message, "")
                }
            }
        }
    }

    private val shareCache: File
        get() {
            // Your custom logic here
            return File(applicationContext.cacheDir.path, "share")
        }

    private fun moveToSharePath(sourceFile: File): File {
        val shareFolder = shareCache
        if (!shareFolder.exists()) {
            shareFolder.mkdir()
        }
        val newFile = File(shareFolder, sourceFile.name)
        sourceFile.copyTo(newFile, true)
        return newFile

    }

    private fun cleanDirectory() {
        val cacheDir = shareCache
        if (!cacheDir.exists()) return
        val content = cacheDir.listFiles()
        if (content.isNullOrEmpty()) return
        content.forEach { it.delete() }
        cacheDir.delete()
    }

    private fun shareText(text: String, subject: String?) {
        val shareIntent = Intent(Intent.ACTION_SEND)
        shareIntent.type = "text/plain"
        shareIntent.putExtra(Intent.EXTRA_TEXT, text)
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject)
        mainActivity!!.startActivity(Intent.createChooser(shareIntent, null))
    }


    private fun shareFile(path: String, mimType: String, text: String?, subject: String?) {
        val file = File(path)
        if (!file.exists()) return
        cleanDirectory()
        val move = moveToSharePath(file)
        val uri: Uri = FileProvider.getUriForFile(
                applicationContext,
                "${mainActivity!!.packageName}.share",
                move
        )

        val shareIntent = Intent(Intent.ACTION_SEND)

        shareIntent.type = mimType

        shareIntent.putExtra(Intent.EXTRA_STREAM, uri)
        if (text != null) {
            shareIntent.putExtra(Intent.EXTRA_TEXT, text)
        }

        if (subject != null) {
            shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject)
        }
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        val chooser = Intent.createChooser(shareIntent, null)

        mainActivity!!.startActivity(chooser)
    }
}
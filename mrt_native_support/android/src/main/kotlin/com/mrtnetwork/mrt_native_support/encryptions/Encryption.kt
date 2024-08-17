package com.mrtnetwork.mrt_native_support.encryptions

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.util.Base64
import androidx.annotation.RequiresApi
import java.io.File
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets

class InvokeException(message: Exception) : Exception(message)
abstract class BaseEncryption(val sharedPreferences: SharedPreferences) {

    abstract fun write(key: String, value: String): Boolean
    abstract fun read(key: String): String?
    abstract fun remove(key: String): Boolean
    abstract fun readAll(): Map<String, String>
    abstract fun removeAll(): Boolean
    abstract fun containsKey(key: String): Boolean
    abstract fun deleteMultiple(key: ArrayList<String>): Boolean
    abstract fun readMultiple(key: ArrayList<String>): Map<String, String>
}


class OwnEncryption(
        private val charset: Charset, private val aes: SecureAesImpl, sharedPreferences: SharedPreferences
) : BaseEncryption(sharedPreferences) {
    companion object {
        private const val PEREFIX: String = "MRTSECURE_"
        private fun combineKeys(key: String): String {
            return "$PEREFIX${key}"
        }

        private fun isUserDataKey(key: String): Boolean {
            return key.startsWith(PEREFIX)
        }

        private fun toUserKey(key: String): String {
            return key.replaceFirst(PEREFIX, "")
        }
    }

    override fun containsKey(key: String): Boolean {
        val correctKey: String = combineKeys(key)
        return sharedPreferences.contains(correctKey)
    }

    override fun write(key: String, value: String): Boolean {
        val editor: SharedPreferences.Editor = sharedPreferences.edit()
        val result: ByteArray = aes.encrypt(value.toByteArray(charset))
        val correctKey: String = combineKeys(key)
        editor.putString(correctKey, Base64.encodeToString(result, 0))
        editor.apply()
        return true
    }

    override fun read(key: String): String? {
        val correctKey: String = combineKeys(key)
        val value: String? = sharedPreferences.getString(correctKey, null)
        return decrypt(value)
    }

    override fun remove(key: String): Boolean {
        val correctKey: String = combineKeys(key)
        val editor: SharedPreferences.Editor = sharedPreferences.edit()
        editor.remove(correctKey)
        editor.apply()
        return true
    }

    override fun readAll(): Map<String, String> {
        @Suppress("UNCHECKED_CAST") val encryptedData: HashMap<String, Any?> =
                sharedPreferences.all as HashMap<String, Any?>
        val decyptedData: HashMap<String, String> = HashMap()
        for ((key, value) in encryptedData) {
            if (value !is String) continue
            if (!isUserDataKey(key)) continue
            val decryptedValue: String = decrypt(value) ?: continue
            val currentKey: String = toUserKey(key)
            decyptedData[currentKey] = decryptedValue
        }
        return decyptedData
    }

    override fun deleteMultiple(key: ArrayList<String>): Boolean {
        val editor: SharedPreferences.Editor = sharedPreferences.edit()
        for (foo in key) {
            val correctKey: String = combineKeys(foo)
            editor.remove(correctKey)
        }
        editor.apply()
        return true
    }

    override fun readMultiple(key: ArrayList<String>): Map<String, String> {
        val stringData: HashMap<String, String> = HashMap()
        for (foo in key) {
            val correctKey: String = combineKeys(foo)
            val value: String = sharedPreferences.getString(correctKey, null) ?: continue
            val dec: String = decrypt(value) ?: continue
            stringData[foo] = dec
        }
        return stringData
    }


    override fun removeAll(): Boolean {
        val secureKey: String? =
                sharedPreferences.getString(SecureAesImpl.PEREF_KEY, null)
        val editor: SharedPreferences.Editor = sharedPreferences.edit()
        try {
            editor.clear()
            editor.apply()
            return true
        } finally {
            if (secureKey != null) {
                editor.putString(SecureAesImpl.PEREF_KEY, secureKey)
                editor.apply()
            }
        }
    }

    private fun decrypt(value: String?): String? {
        if (value == null) {
            return null
        }
        val data: ByteArray = Base64.decode(value, 0)
        val result: ByteArray = aes.decrypt(data)
        return result.toString(charset)
    }
}

class Encryption(private val baseEncryption: BaseEncryption) {

    fun write(key: String, value: String): Boolean {
        return baseEncryption.write(key, value)
    }

    fun read(key: String): String? {
        return baseEncryption.read(key)
    }

    fun remove(key: String): Boolean {
        return baseEncryption.remove(key)
    }

    fun readAll(): Map<String, String> {
        return baseEncryption.readAll()
    }

    fun readMultiple(key: ArrayList<String>): Map<String, String> {
        return baseEncryption.readMultiple(key)
    }

    fun removeMultiple(key: ArrayList<String>): Boolean {
        return baseEncryption.deleteMultiple(key)
    }

    fun removeAll(): Boolean {
        return baseEncryption.removeAll()
    }

    fun containsKey(key: String): Boolean {
        return baseEncryption.containsKey(key)
    }

    companion object {

        @RequiresApi(Build.VERSION_CODES.KITKAT)
        private fun getCurrentCharset(): Charset {
            return StandardCharsets.UTF_8
        }

        @RequiresApi(Build.VERSION_CODES.KITKAT)
        private fun getPreference(
                context: Context,
                prefKey: String,
                alias: String? = null
        ): BaseEncryption {
            val charset: Charset = getCurrentCharset()
            val pref: SharedPreferences = context.getSharedPreferences(
                    prefKey, Context.MODE_PRIVATE
            )
            val rsa: RSAImpl = RSAImpl.init(context, alias)
            val aes: SecureAesImpl = SecureAesImpl.init(
                    rsa, pref
            )

            return OwnEncryption(charset, aes, pref)
        }

        @RequiresApi(Build.VERSION_CODES.KITKAT)
        fun create(context: Context, prefKey: String, alias: String? = null) = object {
            @RequiresApi(Build.VERSION_CODES.KITKAT)
            val pref: BaseEncryption = getPreference(
                    context,
                    prefKey,
                    alias
            )
            @RequiresApi(Build.VERSION_CODES.KITKAT)
            val enc = Encryption(pref)

        }.enc
    }

}

class AppEncryption(private val enc: Encryption) {
    companion object {

        @RequiresApi(Build.VERSION_CODES.KITKAT)
        fun init(context: Context) = object {
            @RequiresApi(Build.VERSION_CODES.KITKAT)
            val enc: AppEncryption =
                    AppEncryption(
                            Encryption.create(
                                    context,
                                    "MRT_SECURE_PREF",
                                    "VGhpcyBpcyB0aGUga2V5IGZvciBhIHNlY3VyZSBzdG9yYWdlIEFFUyBLZXkK"
                            )
                    )
        }.enc
    }

    private fun encrypt(
            mode: String, padding: String, key: ByteArray, initVector: ByteArray?, value: ByteArray
    ): ByteArray {
        val aes: AES = createAES(mode, padding, key, initVector)
        try {
            return aes.encrypt(value)
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }

    private fun encryptFile(
            mode: String, padding: String, key: ByteArray, initVector: ByteArray?, path: String
    ): ArrayList<String> {
        val aes: AES = createAES(mode, padding, key, initVector)
        val file = File(path)
        try {
            val bytes: ByteArray = file.readBytes()
            return divideArray(aes.encrypt(bytes))
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }

    private fun aesEncrypFileBinery(
            mode: String, padding: String, key: ByteArray, initVector: ByteArray?, path: String
    ): ArrayList<ByteArray> {
        val aes: AES = createAES(mode, padding, key, initVector)
        val file = File(path)
        try {
            val bytes: ByteArray = file.readBytes()

            return divideBytesArray(aes.encrypt(bytes))
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }

    private fun decryptFile(
            mode: String,
            padding: String,
            key: ByteArray,
            initVector: ByteArray?,
            encryptPat: String,
            decryptPath: String
    ): Boolean {
        val aes: AES = createAES(mode, padding, key, initVector)
        val file = File(encryptPat)
        val decryptFile = File(decryptPath)
        try {
            var bytes: ByteArray = file.readBytes()
            bytes = aes.decrypt(bytes)
            decryptFile.writeBytes(bytes)
            return true
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }


    private fun aesEncryptEthFileBinary(
            mode: String,
            padding: String,
            key: ByteArray,
            initVector: ByteArray?,
            path: String,
            encryptPath: String,
            ethKeys: ByteArray,
            fullKey: ByteArray
    ): String {
        var aes: AES = createAES(mode, padding, key, initVector)
        val file = File(path)
        val encryptionsFile = File(encryptPath)
        try {
            var bytes: ByteArray = file.readBytes()
            bytes = aes.encrypt(bytes)

            val ethKey: ByteArray = ethKeys.copyOfRange(0, 32)
            val ethIV: ByteArray = ethKeys.copyOfRange(32, 48)
            aes = createAES(mode, padding, ethKey, ethIV)
            val keyEncrypt: ByteArray = aes.encrypt(fullKey)
            bytes = keyEncrypt + bytes
            encryptionsFile.writeBytes(bytes)
            return encryptPath
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }

    private fun encryptFileToFile(
            mode: String,
            padding: String,
            key: ByteArray,
            initVector: ByteArray?,
            path: String,
            encryptPath: String,
            firstPadding: ByteArray
    ): String {
        val aes: AES = createAES(mode, padding, key, initVector)
        val pathFile = File(path)
        val encryptPathFile = File(encryptPath)
        try {
            var bytes: ByteArray = pathFile.readBytes()
            bytes = aes.encrypt(bytes)
            bytes = firstPadding + bytes
            encryptPathFile.writeBytes(bytes)
            return encryptPath
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }


    private fun decrypt(
            mode: String, padding: String, key: ByteArray, initVector: ByteArray?, value: ByteArray
    ): ByteArray {
        val aes: AES = createAES(mode, padding, key, initVector)
        try {
            return aes.decrypt(value)
        } catch (e: Exception) {
            throw InvokeException(e)
        }
    }

    private fun createAES(
            mode: String, padding: String, key: ByteArray, initVector: ByteArray?
    ): AES {
        val aesMode: Mode = Mode.valueOf(mode)
        val aesPadding: Padding = Padding.valueOf(padding)
        return when (aesMode) {
            Mode.CBC -> AES.ofCBC(key, initVector!!, aesPadding)
            Mode.ECB -> AES.ofECB(key, aesPadding)
        }
    }

    private fun divideArray(source: ByteArray): ArrayList<String> {

        val result: ArrayList<String> = arrayListOf()
        var start = 0
        while (start < source.size) {
            val end: Int = source.size.coerceAtMost(start + 500000)
            result.add(
                    Base64.encodeToString(
                            source.copyOfRange(start, end), Base64.NO_WRAP
                    )
            )
            start += 500000
        }
        result.add(source.size.toString())

        return result
    }

    private fun divideBytesArray(source: ByteArray): ArrayList<ByteArray> {
        val result: ArrayList<ByteArray> = arrayListOf()
        var start = 0
        while (start < source.size) {
            val end: Int = source.size.coerceAtMost(start + 500000)
            result.add(source.copyOfRange(start, end))
            start += 500000
        }
        return result
    }


    fun handleStorage(arguments: Map<String, Any?>): Any? {
        val method: String = arguments["type"] as String
        val key: String? = arguments["key"] as String?
        val value: String? = arguments["value"] as String?
        val keys: ArrayList<String>? = arguments["keys"] as ArrayList<String>?
        return when (method) {
            "containsKey" -> enc.containsKey(key!!)
            "write" -> enc.write(key!!, value!!)
            "read" -> enc.read(key!!)
            "readAll" -> enc.readAll() as HashMap<String, String>
            "removeAll" -> enc.removeAll()
            "remove" -> enc.remove(key!!)
            "removeMultiple" -> enc.removeMultiple(keys!!)
            "readMultiple" -> enc.readMultiple(keys!!)
            else -> null
        }
    }

    fun handleEncryption(arguments: Map<String, Any?>): Any? {
        val method = arguments["type"] as String
        val mode = arguments["mode"] as String
        val padding = arguments["padding"] as String
        val key = arguments["key"] as ByteArray
        val iv = arguments["iv"] as ByteArray?
        val value = arguments["value"] as ByteArray?
        val path = arguments["path"] as String?
        val encryptPath = arguments["encryptPath"] as String?
        val ethKeys = arguments["ethKeys"] as ByteArray?
        val fullKey = arguments["fullKey"] as ByteArray?
        val encPath = arguments["encrypt_path"] as String?
        val decPath = arguments["decrypt_path"] as String?
        val firstPadding = arguments["first_padding"] as ByteArray?

        return when (method) {
            "aesEncrypt" -> encrypt(mode, padding, key, iv, value!!)
            "aesEncryptFile" -> encryptFile(mode, padding, key, iv, path!!)
            "aesEncryptFileBinary" -> aesEncrypFileBinery(mode, padding, key, iv, path!!)
            "aesEncryptEthFile" -> aesEncryptEthFileBinary(
                    mode, padding, key, iv, path!!, encryptPath!!, ethKeys!!, fullKey!!
            )

            "encryptFileToFile" -> encryptFileToFile(
                    mode,
                    padding,
                    key,
                    iv,
                    path!!,
                    encryptPath!!,
                    firstPadding!!
            )

            "aesDecryptFile" -> decryptFile(mode, padding, key, iv, encPath!!, decPath!!)
            "aesDecrypt" -> decrypt(mode, padding, key, iv, value!!)
            else -> null

        }
    }
}
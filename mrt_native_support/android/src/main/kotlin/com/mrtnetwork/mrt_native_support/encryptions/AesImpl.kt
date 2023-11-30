package com.mrtnetwork.mrt_native_support.encryptions

import android.content.SharedPreferences
import android.util.Base64
import java.security.Key
import java.security.SecureRandom
import java.security.spec.AlgorithmParameterSpec

import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

interface StorageCipher {

    fun encrypt(input: ByteArray): ByteArray

    fun decrypt(input: ByteArray): ByteArray

}

class SecureAesImpl(
    private val secureRandom: SecureRandom,
    private val cipher: Cipher,
    private val secretKey: Key,
) : StorageCipher {
    companion object {
        internal val keySize: Int = 16
        private val KEY_ALGORITHM: String = "AES"
        internal val PEREF_KEY: String = "VGhpcyBpcyB0aGUga2V5IGZvciBhIHNlY3VyZSBzdG9yYWdlIEFFUyBLZXkK"
        private fun initialize(
                rsa: RSAImpl,
                preferences: SharedPreferences
        ): SecureAesImpl {
            val secure = SecureRandom()

            val editor: SharedPreferences.Editor = preferences.edit()
            val aesKey: String? = preferences.getString(PEREF_KEY, null)
            val cipher: Cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
            if (aesKey != null) {
                try {
                    val encrypted: ByteArray = Base64.decode(aesKey, Base64.DEFAULT)
                    val secretKey: Key = rsa.unwrap(encrypted, KEY_ALGORITHM)
                    return SecureAesImpl(secure, cipher, secretKey)
                } catch (_: Exception) {
                }
            }
            val key: ByteArray = ByteArray(keySize)
            secure.nextBytes(key)
            val secretKey: Key = SecretKeySpec(key, KEY_ALGORITHM)
            val encryptedKey: ByteArray = rsa.wrap(secretKey)
            editor.putString(
                PEREF_KEY,
                Base64.encodeToString(encryptedKey, Base64.DEFAULT)
            )
            editor.apply()
            return SecureAesImpl(secure, cipher, secretKey)
        }

        private fun initializeRandom(
            secureRandom: SecureRandom,
            key: ByteArray
        ): SecureAesImpl {
//            val secure = SecureRandom()
            val cipher: Cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
//            val key: ByteArray = ByteArray(keySize)
//            secure.nextBytes(key)
            val secretKey: Key = SecretKeySpec(key, KEY_ALGORITHM)
            return SecureAesImpl(secureRandom, cipher, secretKey)
        }

        internal fun toB64(bytes: ByteArray): String {
            return Base64.encodeToString(bytes, Base64.DEFAULT)
        }

        fun init(rsa: RSAImpl, preferences: SharedPreferences) = object {
            val aes: SecureAesImpl = initialize(
                rsa,
                preferences
            )
        }.aes

        fun initRandom(secure: SecureRandom, key: ByteArray) = object {
            val aes: SecureAesImpl = initializeRandom(secure, key)
        }.aes
    }

    override fun encrypt(input: ByteArray): ByteArray {
        val iv = ByteArray(getIvSize())
        secureRandom.nextBytes(iv)

        val ivParameterSpec: AlgorithmParameterSpec = getParameterSpec(iv)

        cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivParameterSpec)

        val payload: ByteArray = cipher.doFinal(input)
        val combined: ByteArray = ByteArray(iv.size + payload.size)

        System.arraycopy(iv, 0, combined, 0, iv.size)
        System.arraycopy(payload, 0, combined, iv.size, payload.size)

        return combined
    }

    override fun decrypt(input: ByteArray): ByteArray {
        val iv: ByteArray = ByteArray(getIvSize())
        System.arraycopy(input, 0, iv, 0, iv.size)
        val ivParameterSpec: AlgorithmParameterSpec = getParameterSpec(iv)

        val payloadSize: Int = input.size - getIvSize()
        val payload: ByteArray = ByteArray(payloadSize)
        System.arraycopy(input, iv.size, payload, 0, payloadSize)

        cipher.init(Cipher.DECRYPT_MODE, secretKey, ivParameterSpec)

        return cipher.doFinal(payload)
    }

    private fun getIvSize(): Int {
        return 16
    }

    private fun getParameterSpec(iv: ByteArray): AlgorithmParameterSpec {
        return IvParameterSpec(iv)
    }


}

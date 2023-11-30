package com.mrtnetwork.mrt_native_support.encryptions

import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

enum class Mode {
    CBC,
    ECB
}

enum class Padding {
    NoPadding,
    PKCS5Padding
}

class AES(
        private val key: ByteArray,
        private val iv: ByteArray?,
        private val mode: Mode,
        private val padding: Padding
) {
    companion object {
        fun ofECB(key: ByteArray, padding: Padding): AES {
            return AES(key, null, Mode.ECB, padding)
        }

        fun ofCBC(key: ByteArray, iv: ByteArray, padding: Padding): AES {
            return AES(key, iv, Mode.CBC, padding)
        }
    }

    fun encrypt(value: ByteArray): ByteArray {
        return process(value, Cipher.ENCRYPT_MODE)
    }

    fun decrypt(value: ByteArray): ByteArray {
        return process(value, Cipher.DECRYPT_MODE)
    }

    private fun process(value: ByteArray, processMode: Int): ByteArray {
        val keySpec = SecretKeySpec(key, "AES")
        val cipher: Cipher = Cipher.getInstance(getAlgorithm())
        if (mode == Mode.ECB) // ECB mode cannot use IV
            cipher.init(processMode, keySpec)
        else
            cipher.init(processMode, keySpec, IvParameterSpec(iv))

        return cipher.doFinal(value)

    }

    private fun getAlgorithm(): String {
        return String.format("AES/%s/%s", mode.name, padding.name)
    }
}

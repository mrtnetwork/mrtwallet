package com.mrtnetwork.mrt_native_support.encryptions

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.annotation.RequiresApi
import java.math.BigInteger
import java.security.Key
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.PublicKey
import java.security.cert.Certificate
import java.security.spec.AlgorithmParameterSpec
import java.util.Calendar
import java.util.Locale

import javax.crypto.Cipher
import javax.security.auth.x500.X500Principal

interface KeyCipher {
    fun wrap(key: Key): ByteArray
    fun unwrap(wrappedKey: ByteArray, algorithm: String): Key
}

class RSAImpl(private val alias: String) : KeyCipher {

    companion object {
        private fun setLocale(context: Context, locale: Locale) {
            Locale.setDefault(locale)
            val config: Configuration = context.resources.configuration
            config.setLocale(locale)
            context.createConfigurationContext(config)
        }

        private fun createRSAKeysIfNeeded(context: Context, alias: String) {
            val ks: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID)
            ks.load(null)
            val privateKey: Key? = ks.getKey(alias, null)
            if (privateKey == null) {
                createKeys(context, alias)
            }
        }

        private fun createKeys(context: Context, alias: String) {
            val currentLocale: Locale = Locale.getDefault()
            try {
                setLocale(context, Locale.ENGLISH)
                val start: Calendar = Calendar.getInstance()
                val end: Calendar = Calendar.getInstance()
                end.add(Calendar.YEAR, 25)

                val kpGenerator: KeyPairGenerator = KeyPairGenerator.getInstance(
                    TYPE_RSA,
                    KEYSTORE_PROVIDER_ANDROID
                )

                val spec: AlgorithmParameterSpec = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                    makeAlgorithmParameterSpecLegacy(context, start, end, alias)
                } else {
                    makeAlgorithmParameterSpec(start, end, alias)
                }

                kpGenerator.initialize(spec)
                kpGenerator.generateKeyPair()
            } finally {
                setLocale(context, currentLocale)
            }
        }

        private fun createKeyAlias(context: Context, alias: String? = null): String {
            if (alias != null) return context.packageName + alias
            return (context.packageName + ".MRT_SECURE_STORAGE")
        }

        private const val KEYSTORE_PROVIDER_ANDROID: String = "AndroidKeyStore"
        private const val TYPE_RSA: String = "RSA"

        @Suppress("DEPRECATION")
        private fun makeAlgorithmParameterSpecLegacy(
            context: Context,
            start: Calendar,
            end: Calendar,
            alias: String
        ): AlgorithmParameterSpec {
            return android.security.KeyPairGeneratorSpec.Builder(context).setAlias(alias)
                .setSubject(
                    X500Principal(
                        "CN=$alias"
                    )
                ).setSerialNumber(BigInteger.valueOf(1)).setStartDate(start.time)
                .setEndDate(end.time).build()


        }

        @RequiresApi(Build.VERSION_CODES.M)
        private fun makeAlgorithmParameterSpec(
                start: Calendar,
                end: Calendar,
                alias: String
        ): AlgorithmParameterSpec {
            val builder: KeyGenParameterSpec.Builder =
                KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_DECRYPT)
                    .setCertificateSubject(X500Principal("CN=$alias"))
                    .setDigests(KeyProperties.DIGEST_SHA256)
                    .setBlockModes(KeyProperties.BLOCK_MODE_ECB)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
                    .setCertificateSerialNumber(BigInteger.valueOf(1))
                    .setCertificateNotBefore(start.time).setCertificateNotAfter(end.time)
            return builder.build()
        }

        private fun initialize(context: Context, key: String? = null): RSAImpl {
            val alias: String = createKeyAlias(context, key)
            createRSAKeysIfNeeded(context, alias)
            return RSAImpl(alias)
        }

        fun init(context: Context, key: String? = null) = object {

            val rsa: RSAImpl = initialize(context, key)
        }.rsa

    }

    override fun wrap(key: Key): ByteArray {
        val publicKey: PublicKey = getPublicKey()
        val cipher: Cipher = getRSACipher()
        cipher.init(Cipher.WRAP_MODE, publicKey, getAlgorithmParameterSpec())

        return cipher.wrap(key)
    }

    override fun unwrap(wrappedKey: ByteArray, algorithm: String): Key {
        val privateKey: PrivateKey = getPrivateKey()
        val cipher: Cipher = getRSACipher()
        cipher.init(Cipher.UNWRAP_MODE, privateKey, getAlgorithmParameterSpec())

        return cipher.unwrap(wrappedKey, algorithm, Cipher.SECRET_KEY)
    }

    private fun getPrivateKey(): PrivateKey {
        val ks: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID)
        ks.load(null)

        val key: Key = ks.getKey(alias, null) ?: throw Exception("No key found under alias: $alias")

        if (key !is PrivateKey) {
            throw Exception("Not an instance of a PrivateKey")
        }

        return key
    }

    private fun getPublicKey(): PublicKey {
        val ks: KeyStore = KeyStore.getInstance(KEYSTORE_PROVIDER_ANDROID)
        ks.load(null)

        val cert: Certificate = ks.getCertificate(alias)
                ?: throw Exception("No certificate found under alias: $alias")

        return cert.publicKey ?: throw Exception("No key found under alias: $alias")
    }

    private fun getRSACipher(): Cipher {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            Cipher.getInstance(
                    "RSA/ECB/PKCS1Padding",
                    "AndroidOpenSSL"
            ) // error in android 6: InvalidKeyException: Need RSA private or public key
        } else {
            Cipher.getInstance(
                    "RSA/ECB/PKCS1Padding",
                    "AndroidKeyStoreBCWorkaround"
            ) // error in android 5: NoSuchProviderException: Provider not available: AndroidKeyStoreBCWorkaround
        }
    }

    private fun getAlgorithmParameterSpec(): AlgorithmParameterSpec? {
        return null
    }

}

part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin WalletCryptoImpl {
  List<int> _toWalletPassword(String password, List<int> walletCheckSum) {
    final List<int> key = SHA3
        .hash(List.from([...StringUtils.encode(password), ...walletCheckSum]));
    return List<int>.unmodifiable(
        key.sublist(0, WalletProviderConst.encryptionKeyLength));
  }

  List<int> _toNonce(List<int> key) {
    return SHAKE128()
        .update(key)
        .digest(WalletProviderConst.encryptionNonceLength);
  }

  List<int>? _fromChacha(List<int> key, List<int> sealed) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      final nonce = _toNonce(key);
      final decrypt = chacha.decrypt(nonce, sealed);
      if (decrypt == null) return null;
      return decrypt;
    } finally {
      chacha.clean();
    }
  }

  List<int> _toChaCha(List<int> key, List<int> data) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      final List<int> nonce = _toNonce(key);
      final List<int> encrypt = chacha.encrypt(nonce, data);
      final toCbor = CborListValue.dynamicLength([
        const CborIntValue(WalletProviderConst.version),
        CborBytesValue(encrypt),
      ]);
      return toCbor.encode();
    } finally {
      chacha.clean();
    }
  }

  List<int> _toMemoryStorage(List<int> key, List<int> data) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      final List<int> nonce =
          QuickCrypto.generateRandom(WalletProviderConst.encryptionNonceLength);
      final List<int> encrypt = chacha.encrypt(nonce, data);
      final toCbor = CborListValue.dynamicLength([
        const CborIntValue(WalletProviderConst.version),
        CborBytesValue(nonce),
        CborBytesValue(encrypt),
      ]);
      return toCbor.encode();
    } finally {
      chacha.clean();
    }
  }

  WalletMasterKeys _fromMemoryStorage(
      List<int> key, EncryptedMasterKey masaterKey) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      final toCbor = masaterKey.toCbor();
      final nonce = toCbor.value[1].value as List<int>;
      final sealed = toCbor.value[2].value as List<int>;

      final decryptBytes = chacha.decrypt(nonce, sealed);
      return WalletMasterKeys.fromCborBytesOrObject(bytes: decryptBytes);
    } finally {
      chacha.clean();
    }
  }

  Future<String> _forStorage(
      WalletMasterKeys masterKey, List<int> password) async {
    final toCbor = _toChaCha(password, masterKey.toCbor().encode());
    return StringUtils.decode(toCbor, StringEncoding.base64);
  }

  Future<WalletMasterKeys> _fromStroage(String encrypted, List<int> key) async {
    try {
      final List<int> toCborBytes =
          StringUtils.encode(encrypted, StringEncoding.base64);
      final data = _validateStorageCbor(toCborBytes);

      if (data == null) {
        throw WalletExceptionConst.incorrectWalletData;
      }
      final decryptBytes = _fromChacha(key, data.$2);
      if (decryptBytes == null) {
        throw WalletExceptionConst.incorrectPassword;
      }
      final masterKey =
          WalletMasterKeys.fromCborBytesOrObject(bytes: decryptBytes);
      return masterKey;
    } catch (e) {
      throw WalletExceptionConst.incorrectPassword;
    }
  }

  (int, List<int>)? _validateStorageCbor(List<int> toCborBytes) {
    final toCborObject = CborObject.fromCbor(toCborBytes);

    if (toCborObject is! CborListValue) return null;
    try {
      final int version = toCborObject.value[0].value;
      final List<int> walletData = toCborObject.value[1].value;
      return (version, walletData);
    } catch (e) {
      return null;
    }
  }
}

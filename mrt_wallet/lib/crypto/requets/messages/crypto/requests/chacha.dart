import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/chacha.dart';

class CryptoRequestEncryptChacha
    extends CryptoRequest<CryptoEncryptChachaResponse, MessageArgsTwoBytes> {
  final List<int> message;
  final List<int> key;
  final int nonceLength;
  final List<int>? nonce;
  CryptoRequestEncryptChacha({
    required List<int> message,
    required List<int> key,
    List<int>? nonce,
    this.nonceLength = 12,
  })  : message = message.asImmutableBytes,
        key = key.asImmutableBytes,
        nonce = nonce?.asImmutableBytes;

  factory CryptoRequestEncryptChacha.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.encryptChacha.tag);
    return CryptoRequestEncryptChacha(
      message: values.elementAt(0),
      key: values.elementAt(1),
      nonce: values.elementAt(2),
      nonceLength: values.elementAt(3),
    );
  }

  static (List<int>, List<int>) encrypt(
      {required List<int> key,
      required int nonceLength,
      required List<int> message,
      List<int>? nonce}) {
    final chacha = ChaCha20Poly1305(key);
    nonce ??= QuickCrypto.generateRandom(nonceLength);
    final encrypt = chacha.encrypt(nonce, message);
    return (encrypt, nonce);
  }

  @override
  MessageArgsTwoBytes getResult() {
    final data = encrypt(
        key: key, nonceLength: nonceLength, message: message, nonce: nonce);
    return MessageArgsTwoBytes(keyOne: data.$1, keyTwo: data.$2);
  }

  @override
  CryptoEncryptChachaResponse parsResult(MessageArgsTwoBytes result) {
    return CryptoEncryptChachaResponse(
        encrypted: result.keyOne, nonce: result.keyTwo);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          CborBytesValue(key),
          nonce == null ? const CborNullValue() : CborBytesValue(nonce!),
          nonceLength
        ]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.encryptChacha;

  @override
  CryptoEncryptChachaResponse result() {
    final data = encrypt(
        key: key, nonceLength: nonceLength, message: message, nonce: nonce);
    return CryptoEncryptChachaResponse(encrypted: data.$1, nonce: data.$2);
  }
}

class CryptoRequestDecryptChacha
    extends CryptoRequest<CryptoDecryptChachaResponse, MessageArgsOneBytes> {
  final List<int> message;
  final List<int> key;
  final List<int> nonce;
  CryptoRequestDecryptChacha({
    required List<int> message,
    required List<int> key,
    required List<int> nonce,
  })  : message = message.asImmutableBytes,
        key = key.asImmutableBytes,
        nonce = nonce.asImmutableBytes;
  CryptoRequestDecryptChacha.fromHex({
    required String message,
    required String key,
    required String nonce,
  })  : message = BytesUtils.fromHexString(message).immutable,
        key = BytesUtils.fromHexString(key).immutable,
        nonce = BytesUtils.fromHexString(nonce).immutable;

  factory CryptoRequestDecryptChacha.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.decryptChacha.tag);
    return CryptoRequestDecryptChacha(
        message: values.elementAt(0),
        key: values.elementAt(1),
        nonce: values.elementAt(2));
  }

  static List<int> decrypt(
      {required List<int> key,
      required List<int> nonce,
      required List<int> message}) {
    final chacha = ChaCha20Poly1305(key);
    final decrypted = chacha.decrypt(nonce, message);
    if (decrypted == null) {
      throw WalletExceptionConst.decryptionFailed;
    }
    return decrypted;
  }

  @override
  MessageArgsOneBytes getResult() {
    final decryptData = decrypt(key: key, nonce: nonce, message: message);
    return MessageArgsOneBytes(keyOne: decryptData);
  }

  @override
  CryptoDecryptChachaResponse parsResult(MessageArgsOneBytes result) {
    return CryptoDecryptChachaResponse(result.keyOne);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          CborBytesValue(key),
          CborBytesValue(nonce)
        ]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.decryptChacha;

  @override
  CryptoDecryptChachaResponse result() {
    final decryptData = decrypt(key: key, nonce: nonce, message: message);
    return CryptoDecryptChachaResponse(decryptData);
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/crypto/requests/hash.dart';

class NoneEncryptedRequestHashing
    extends NoneEncryptedCryptoRequest<List<int>, MessageArgsOneBytes> {
  final CryptoRequestHashingType hashingType;
  final String? dataHex;
  final List<int>? dataBytes;
  NoneEncryptedRequestHashing._(
      {required this.hashingType, this.dataHex, List<int>? dataBytes})
      : dataBytes = BytesUtils.tryToBytes(dataBytes, unmodifiable: true);
  factory NoneEncryptedRequestHashing.string(
      {required CryptoRequestHashingType type, required String data}) {
    return NoneEncryptedRequestHashing._(
        hashingType: type, dataBytes: StringUtils.encode(data));
  }
  factory NoneEncryptedRequestHashing(
      {required CryptoRequestHashingType type,
      String? dataHex,
      List<int>? dataBytes}) {
    if (dataHex != null && dataBytes != null) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if ((dataHex == null && dataBytes == null) &&
        type != CryptoRequestHashingType.generateUuid) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return NoneEncryptedRequestHashing._(
        hashingType: type, dataBytes: dataBytes, dataHex: dataHex);
  }
  factory NoneEncryptedRequestHashing.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.hashing.tag);
    return NoneEncryptedRequestHashing._(
        hashingType: CryptoRequestHashingType.fromName(values.elementAt(0)),
        dataBytes: values.elementAt(1),
        dataHex: values.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          hashingType.name,
          dataBytes == null ? null : CborBytesValue(dataBytes!),
          dataHex
        ]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.hashing;

  static List<int> generateHash(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex}) {
    if (type == CryptoRequestHashingType.generateUuid) {
      final rand = QuickCrypto.generateRandom(16);
      final uuid = UUID.fromBuffer(rand);
      return StringUtils.encode(uuid);
    }
    List<int>? bytes = dataBytes;
    if (bytes == null) {
      if (type == CryptoRequestHashingType.uuid) {
        bytes = StringUtils.toBytes(dataHex!);
      } else {
        bytes = BytesUtils.fromHexString(dataHex!);
      }
    }
    switch (type) {
      case CryptoRequestHashingType.md4:
        return MD4.hash(bytes);
      case CryptoRequestHashingType.md5:
        return MD5.hash(bytes);
      case CryptoRequestHashingType.sha256:
        return SHA256.hash(bytes);
      case CryptoRequestHashingType.sha3:
        return SHA3.hash(bytes);
      case CryptoRequestHashingType.sha3256:
        return SHA3256.hash(bytes);
      case CryptoRequestHashingType.sha512:
        return SHA512.hash(bytes);
      case CryptoRequestHashingType.keccack256:
        return Keccack.hash(bytes);
      case CryptoRequestHashingType.uuid:
        final hash = MD4.hash(bytes);
        return StringUtils.encode(UUID.fromBuffer(hash));
      default:
        throw WalletExceptionConst.dataVerificationFailed;
    }
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    return MessageArgsOneBytes(
        keyOne: generateHash(
            type: hashingType, dataBytes: dataBytes, dataHex: dataHex));
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  Future<List<int>> result({List<int>? encryptedPart}) async {
    return generateHash(
        type: hashingType, dataBytes: dataBytes, dataHex: dataHex);
  }
}

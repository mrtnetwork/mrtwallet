import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/utils/crypto/utils.dart';

class CryptoRequestWalletKey
    implements CryptoRequest<List<int>, MessageArgsOneBytes> {
  final List<int> key;
  final List<int> checksum;
  CryptoRequestWalletKey._(
      {required List<int> key, required List<int> checksum})
      : key = BytesUtils.toBytes(key, unmodifiable: true),
        checksum = BytesUtils.toBytes(checksum, unmodifiable: true);
  factory CryptoRequestWalletKey.fromString(
      {required String key, required String checksum}) {
    final checksumBytes = BytesUtils.fromHexString(checksum);
    final keyBytes = StringUtils.encode(key);
    return CryptoRequestWalletKey._(key: keyBytes, checksum: checksumBytes);
  }

  factory CryptoRequestWalletKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.walletKey.tag);
    return CryptoRequestWalletKey._(
        key: values.elementAt(0), checksum: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(key), CborBytesValue(checksum)]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.walletKey;

  @override
  MessageArgsOneBytes getResult() {
    final walletKey = WorkerCryptoUtils.hashKey(key: key, checksum: checksum);
    return MessageArgsOneBytes(keyOne: walletKey);
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  List<int> result() {
    return WorkerCryptoUtils.hashKey(key: key, checksum: checksum);
  }
}

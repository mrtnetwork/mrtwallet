import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class NoneEncryptedRequestHexToBytes<T>
    extends NoneEncryptedCryptoRequest<List<int>, MessageArgsOneBytes> {
  final String hex;
  NoneEncryptedRequestHexToBytes({required this.hex});
  factory NoneEncryptedRequestHexToBytes.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.hexToBytes.tag);
    return NoneEncryptedRequestHexToBytes(
        hex: String.fromCharCodes(values.elementAs(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([CborBytesValue(hex.codeUnits)]), method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.hexToBytes;

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    return MessageArgsOneBytes(keyOne: BytesUtils.fromHexString(hex));
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  Future<List<int>> result({List<int>? encryptedPart}) async {
    return BytesUtils.fromHexString(hex);
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class NoneEncryptedRequestDecodeCbor<T>
    extends NoneEncryptedCryptoRequest<CborObject, MessageArgsCbor> {
  final String hex;
  NoneEncryptedRequestDecodeCbor({required this.hex});
  factory NoneEncryptedRequestDecodeCbor.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.cbor.tag);
    return NoneEncryptedRequestDecodeCbor(
        hex: String.fromCharCodes(values.elementAs(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([CborBytesValue(hex.codeUnits)]), method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.cbor;

  @override
  Future<MessageArgsCbor> getResult({List<int>? encryptedPart}) async {
    return MessageArgsCbor(
        message: CborObject.fromCbor(BytesUtils.fromHexString(hex)));
  }

  @override
  CborObject parsResult(MessageArgsCbor result) {
    return result.message;
  }

  @override
  Future<CborObject> result({List<int>? encryptedPart}) async {
    return CborObject.fromCbor(BytesUtils.fromHexString(hex));
  }
}

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';

class APPImage with CborSerializable {
  final ContentType type;
  final String uri;
  const APPImage({required this.type, required this.uri});
  const APPImage.local(this.uri) : type = ContentType.local;

  factory APPImage.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, APPSerializationConst.imageTag);
      return APPImage(
          type: ContentType.fromValue(cbor.elementAt(0)),
          uri: cbor.elementAt(1));
    } catch (e) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([type.value, CborStringValue(uri)]),
        APPSerializationConst.imageTag);
  }
}

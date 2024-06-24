import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'content_type.dart';

class AppImage with CborSerializable {
  final ContentType type;
  final String uri;
  const AppImage({required this.type, required this.uri});
  const AppImage.local(this.uri) : type = ContentType.local;

  factory AppImage.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.image);
      return AppImage(
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
        WalletModelCborTagsConst.image);
  }
}

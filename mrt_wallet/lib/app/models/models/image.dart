import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/constant/global/serialization.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'content_type.dart';
// import 'package:mrt_wallet/app/core.dart';

class APPImage with CborSerializable, Equatable {
  final ContentType type;
  final String uri;
  final String cacheKey;
  const APPImage._(
      {required this.type, required this.uri, required this.cacheKey});
  APPImage.local(this.uri)
      : type = ContentType.local,
        cacheKey = "asset_${uri.split("/").last}";
  factory APPImage.hex({required String hexData, required String cacheKey}) {
    return APPImage._(type: ContentType.hex, uri: hexData, cacheKey: cacheKey);
  }
  factory APPImage.base64({required String hexData, required String cacheKey}) {
    return APPImage._(
        type: ContentType.base64, uri: hexData, cacheKey: cacheKey);
  }
  factory APPImage.network(String imageUrl, String cache) {
    return APPImage._(
        type: ContentType.network, uri: cache, cacheKey: "net_$cache");
  }
  factory APPImage.faviIcon(String websiteUrl) {
    final host = Uri.tryParse(websiteUrl);
    String cacheKey = host?.host ?? "";
    if (cacheKey.isEmpty) {
      cacheKey = websiteUrl;
    }
    return APPImage._(
        type: ContentType.favIcon, uri: websiteUrl, cacheKey: "fav_$cacheKey");
  }

  factory APPImage.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, APPSerializationConst.imageTag);
      final String uri = cbor.elementAt(1);
      return APPImage._(
          type: ContentType.fromValue(cbor.elementAt(0)),
          uri: uri,
          cacheKey: cbor.elementAt<String?>(2) ?? uri.split("/").last);
    } catch (e) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([type.value, CborStringValue(uri), cacheKey]),
        APPSerializationConst.imageTag);
  }

  @override
  List get variabels => [type, uri];
}

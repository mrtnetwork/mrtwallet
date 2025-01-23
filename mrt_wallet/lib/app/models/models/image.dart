import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/constant/global/serialization.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'content_type.dart';

// import 'package:mrt_wallet/app/core.dart';
typedef OnLoadUrl = Future<String> Function();
typedef OnLoadCacheKey = Future<String> Function();

abstract class APPImageInfo with Equatable {
  abstract final OnLoadUrl loadUrl;
  abstract final ContentType type;
}

class LazyAPPImage with Equatable implements APPImageInfo {
  final String identifier;
  @override
  final ContentType type = ContentType.lazy;
  const LazyAPPImage({required this.loadUrl, required this.identifier});
  @override
  final OnLoadUrl loadUrl;

  @override
  List get variabels => [identifier];
}

class APPImage with CborSerializable, Equatable implements APPImageInfo {
  @override
  final ContentType type;
  final String uri;
  // final String cacheKey;
  const APPImage._({required this.type, required this.uri});
  APPImage.local(this.uri) : type = ContentType.local;
  factory APPImage.hex({required String hexData}) {
    return APPImage._(type: ContentType.hex, uri: hexData);
  }
  factory APPImage.base64({required String hexData}) {
    return APPImage._(type: ContentType.base64, uri: hexData);
  }
  static APPImage? network(String? imageUrl) {
    final validateUrl = StrUtils.validateUri(imageUrl);
    if (validateUrl == null) return null;
    return APPImage._(type: ContentType.network, uri: imageUrl!);
  }

  factory APPImage.faviIcon(String websiteUrl) {
    final host = Uri.tryParse(websiteUrl);
    String cacheKey = host?.host ?? "";
    if (cacheKey.isEmpty) {
      cacheKey = websiteUrl;
    }
    return APPImage._(type: ContentType.favIcon, uri: websiteUrl);
  }

  factory APPImage.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, APPSerializationConst.imageTag);
      final String uri = cbor.elementAt(1);
      return APPImage._(
          type: ContentType.fromValue(cbor.elementAt(0)), uri: uri);
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

  @override
  List get variabels => [type, uri];

  @override
  OnLoadUrl get loadUrl => () async => uri;
}

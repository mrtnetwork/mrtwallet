import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/constant/global/serialization.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';

import 'image.dart';

class WebViewTab with CborSerializable, Equatable {
  final String id;
  final String url;
  final String? path;
  final String? title;
  final APPImage? image;
  final DateTime lastVisit;
  final String? host;

  late final String viewName = host ?? path ?? url;
  WebViewTab._(
      {required this.id,
      required this.url,
      this.path,
      this.title,
      this.image,
      required this.lastVisit,
      required this.host});
  factory WebViewTab(
      {required String id,
      required String url,
      required String? title,
      required APPImage? image,
      DateTime? lastVisit}) {
    String? path;
    String? host;
    Uri? uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty) {
      host = uri.host;
      uri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path,
      );
      path = uri.toString();
    }
    return WebViewTab._(
        id: id,
        url: url,
        title: title,
        image: image,
        lastVisit: lastVisit ?? DateTime.now(),
        path: path,
        host: host);
  }
  factory WebViewTab.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: APPSerializationConst.webviewTab);
    return WebViewTab(
      id: values.elementAt(0),
      url: values.elementAt(1),
      title: values.elementAt(2),
      image: values
          .getCborTag(3)
          ?.to((e) => APPImage.fromCborBytesOrObject(obj: e)),
      lastVisit: values.elementAt(4),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          id,
          url,
          title,
          image?.toCbor(),
          CborEpochIntValue(lastVisit),
          path
        ]),
        APPSerializationConst.webviewTab);
  }

  @override
  List get variabels => [url, path, host, title, image, lastVisit];
}

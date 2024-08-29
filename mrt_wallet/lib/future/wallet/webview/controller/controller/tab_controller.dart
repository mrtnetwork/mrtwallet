import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/app/models/models.dart';
import 'package:mrt_wallet/future/wallet/webview/view/native_view.dart';

class WebViewController {
  final MRTAndroidViewController controller;
  final Live<WebViewTab> _tab;
  final List<int> viewTypeBytes;
  final String viewType;
  WebViewController(
      {required this.controller,
      required this.viewType,
      required List<int> key,
      required WebViewTab tab})
      : viewTypeBytes = BytesUtils.fromHexString(viewType),
        _tab = Live<WebViewTab>(tab);

  // bool _inited = false;
  // bool get inited => _inited;
  Live<WebViewTab> get tab => _tab;

  String get url => tab.value.url;

  String get title => tab.value.title ?? "";

  String get tabId => _tab.value.id;
  APPImage? get image => _tab.value.image;
  void setTab(WebViewTab tab) {
    _tab.value = tab;
  }

  void dispose() {
    controller.dispose();
    _tab.dispose();
  }
}

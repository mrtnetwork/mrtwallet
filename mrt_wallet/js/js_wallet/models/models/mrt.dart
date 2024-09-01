import 'dart:js_interop';
import 'package:mrt_native_support/web/api/core/js.dart';

import 'networks/ethereum.dart';

@JS("MRT")
external MRTWallet? get mrtNull;

@JS("MRT")
external MRTWallet get mrt;

@JS("MRT")
external set mrt(JSAny mrt);

@JS("ethereum")
external set ethereum(Proxy? ethereum);

@JS("ethereum")
external Proxy get ethereum;

@JS("MRT")
extension type MRTWallet(JSObject _) implements MRTJsObject {
  @JS("scriptId")
  external JSAny get _scriptId;
  @JS("scriptId")
  external String _scriptIdFunc();
  @JS("scriptId")
  external String get _scriptIdStr;

  @JS("ethereum")
  external set ethereum(EIP1193 ethereum);
  @JS("ethereum")
  external set ethereum2(JSAny ethereum);
  external set version(int version);
  external int get version;
  @JS("ethereum")
  external JSAny get ethereum2;

  external EIP1193 get ethereum;

  @JS("onMrtMessage")
  external set onMrtMessage(JSFunction? f);

  @JS("onMrtJsRequest")
  external void onMrtJsRequest(
      String id, String data, String requestId, String type);

  String get clientId {
    if (_scriptId.isA<JSFunction>()) {
      return _scriptIdFunc();
    } else {
      return _scriptIdStr;
    }
  }
}

@JS()
extension type Web3JSRequestParams._(JSObject o) implements MRTJsObject {
  external String? get method;
  external String? get id;
  external JSAny? get params;

  Map<String, dynamic> toJson() {
    return {"method": method, "params": params == null ? [] : params.dartify()};
  }
}

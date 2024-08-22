import 'dart:js_interop';
import 'package:mrt_native_support/web/api/core/js.dart';

import 'ethreum/ethereum.dart';

@JS("MRT")
external MRTWallet? get mrtNull;

@JS("MRT")
external MRTWallet get mrt;

@JS("MRT")
external set mrt(JSAny mrt);

@JS("ethereum")
external set ethereum(EIP1193? ethereum);

@JS("ethereum")
external EIP1193? get ethereumNullable;

@JS("ethereum")
external EIP1193 get ethereum;

@JS("MRT")
extension type MRTWallet(JSObject _) implements MRTJsObject {
  external String get scriptId;
  // external String scriptId();

  @JS("ethereum")
  external set ethereum(EIP1193 ethereum);
  external set version(int version);
  external int get version;

  external EIP1193 get ethereum;

  @JS("onMrtMessage")
  external set onMrtMessage(JSFunction? f);

  @JS("onMrtJsRequest")
  external void onMrtJsRequest(
      String id, String data, String requestId, String type);
}

@JS()
extension type Web3JSRequestParams._(JSObject o) implements MRTJsObject {
  external String? get method;
  external String? get id;
  external JSAny? get params;

  Map<String, dynamic> toJson() {
    return {"method": method, "params": params == null ? [] : params.dartify()};
  }

  ClientMessageEthereum? toWalletRequest(String requestId) {
    try {
      return ClientMessageEthereum(
          method: method!, params: params.dartify(), id: requestId);
    } catch (e) {
      return null;
    }
  }
}

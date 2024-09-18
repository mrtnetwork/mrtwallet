import 'dart:js_interop';
import 'package:mrt_native_support/web/api/core/js.dart';

import 'networks.dart';
import 'requests.dart';

@JS("ton")
external set ton(Proxy? ton);

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
  external set tonconnect(TonWalletAdapter tonconnect);

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

extension type MRTNetworkAdapter(JSObject _) implements MRTJsObject {
  @JS("sendWalletRequest")
  external set sendWalletRequest(JSFunction f);
  @JS("sendWalletRequest")
  external JSPromise<T> sendWalletRequest_<T extends JSAny>(
      Web3JSRequestParams params);
  @JS("selectedAddress")
  external set selectedAddress(JSString? selectedAddress);
  external set on(JSFunction f);
  external set removeListener(JSFunction f);
  external set cancelListener(JSFunction f);
  external set cancelAllListener(JSFunction f);
  external set providerInfo(EIP6963ProviderInfo f);
  external set disconnect(JSFunction f);
  external set enable(JSFunction? f);
  external EIP6963ProviderInfo get providerInfo;
  external bool get isMRT;
}

import 'dart:js_interop';
import 'package:mrt_native_support/models/device/models/platform.dart';
import 'package:mrt_wallet/app/http/isolate/impl/caller/caller.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';

@JS("postMessage")
external void postMessage(JSAny data);

@JS()
external set mrtJsHandler(JSFunction handler);

@JS()
external set mrtWalletActivation(JSFunction? handler);
final Service service = Service();

void _onMessage(JSAny message) {
  service.sentResult(message);
}

String _onActivation() {
  try {
    return "";
  } finally {
    mrtWalletActivation = null;
  }
}

void main(List<String> args) {
  mrtJsHandler = _onMessage.toJS;
  mrtWalletActivation = _onActivation.toJS;
}

class Service {
  final ServicesHTTPCaller caller = ServicesHTTPCaller();
  void sentResult(JSAny message) async {
    final msg = HTTPWorkerRequest.fromJson(
        (message.dartify()! as Map).cast<String, dynamic>());
    final response = await caller.makeCall(msg, platform: AppPlatform.web);
    postMessage(response.toJson().jsify()!);
  }
}

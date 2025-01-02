import 'package:mrt_wallet/app/http/http.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/crypto/isolate/cross/exception.dart';
import 'package:mrt_wallet/app/http/isolate/impl/caller/caller.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';

import '../impl/cross.dart'
    if (dart.library.js_interop) '../impl/web/service.dart'
    if (dart.library.io) '../impl/io/service.dart';

abstract class HTTPServiceWorker {
  static final HTTPServiceWorker instance = getHTTPWorker();
  final ServicesHTTPCaller caller = ServicesHTTPCaller();
  Future<HTTPCallerResponse> send(HTTPWorkerMessage request);

  Future<HTTPCallerResponse> call(
      {required Uri url,
      required Duration timeout,
      required ProviderAuthenticated? authenticated,
      HTTPRequestType type = HTTPRequestType.post,
      Map<String, String>? headers,
      HTTPClientType clientType = HTTPClientType.cached,
      HTTPResponseType responseType = HTTPResponseType.binary,
      Object? body,
      APPIsolate isolate = APPIsolate.separate}) async {
    final request = HTTPWorkerMessage(
        type: type,
        responseType: responseType,
        url: url,
        params: body,
        headers: headers,
        timeout: timeout,
        clientType: clientType,
        authenticated: authenticated);
    if (!isolate.separateThread) {
      try {
        return send(request);
      } on FailedIsolateInitialization catch (_) {}
    }
    final result =
        await caller.makeCall(HTTPWorkerRequest(id: -1, message: request));
    return result.response;
  }

  Future<HTTPCallerResponse> makeStream(
      {required Uri uri,
      Map<String, String> headers = const {},
      OnStreamReapose? onProgress}) async {
    final r = await caller.makeStream(
        uri: uri, headers: headers, onProgress: onProgress);
    return r.response;
  }
}

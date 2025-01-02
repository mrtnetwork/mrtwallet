import 'dart:async';
import 'package:http/http.dart';
import 'package:mrt_native_support/models/device/models/platform.dart';
import 'package:mrt_wallet/app/http/impl/http.dart';
import 'package:mrt_wallet/app/http/models/models.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';

class ServicesHTTPCaller {
  static String _getExceptionMessage(Object e) {
    if (e is TimeoutException) return "api_http_timeout_error";
    if (e is ClientException) return "api_http_client_error";
    return e.toString();
  }

  Future<HTTPWorkerResponse> makeCall(HTTPWorkerRequest message,
      {AppPlatform platform = AppPlatform.android}) async {
    try {
      final HTTPCallerResponse response = switch (message.message.type) {
        HTTPRequestType.get => await HTTPCaller.get(
            uri: message.message.url,
            headers: message.message.headers,
            timeout: message.message.timeout,
            type: message.message.responseType,
            clientType: message.message.clientType,
            authenticated: message.message.authenticated,
            platform: platform),
        HTTPRequestType.post => await HTTPCaller.post(
            uri: message.message.url,
            clientType: message.message.clientType,
            headers: message.message.headers,
            timeout: message.message.timeout,
            body: message.message.params,
            type: message.message.responseType,
            authenticated: message.message.authenticated,
            platform: platform)
      };
      return HTTPWorkerResponseSuccess(response: response, id: message.id);
    } catch (e) {
      return HTTPWorkerResponseError(
          message: _getExceptionMessage(e), id: message.id);
    }
  }

  Future<HTTPWorkerResponse> makeStream(
      {required Uri uri,
      Map<String, String> headers = const {},
      OnStreamReapose? onProgress}) async {
    try {
      final r = await HTTPCaller.getStream(
          uri: uri, headers: headers, onProgress: onProgress);
      return HTTPWorkerResponseSuccess(response: r, id: -1);
    } catch (e) {
      return HTTPWorkerResponseError(message: _getExceptionMessage(e), id: -1);
    }
  }
}

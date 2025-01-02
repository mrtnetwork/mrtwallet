import 'dart:async';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/http/http.dart';

enum HTTPRequestType {
  get("GET"),
  post("POST");

  final String name;
  const HTTPRequestType(this.name);
  static HTTPRequestType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: "invalid http request type name"),
    );
  }
}

class HTTPWorkerMessage {
  final HTTPRequestType type;
  final Uri url;
  final Object? params;
  final Map<String, String>? headers;
  final Duration timeout;
  final HTTPResponseType responseType;
  final HTTPClientType clientType;
  final ProviderAuthenticated? authenticated;
  factory HTTPWorkerMessage.fromJson(Map<String, dynamic> json) {
    return HTTPWorkerMessage(
        type: HTTPRequestType.fromName(json["type"]),
        url: Uri.parse(json["url"]),
        params: json["params"],
        timeout: Duration(seconds: json["timeout"]),
        responseType: HTTPResponseType.fromName(json["responseType"]),
        clientType: HTTPClientType.fromName(json["clientType"]),
        authenticated: json["authenticated"] == null
            ? null
            : ProviderAuthenticated.deserialize(cborHex: json["authenticated"]),
        headers: Map<String, String>.from(json["headers"] ?? {}));
  }
  const HTTPWorkerMessage(
      {required this.type,
      required this.url,
      required this.params,
      required this.timeout,
      required this.responseType,
      required this.clientType,
      this.authenticated,
      this.headers});
  Map<String, dynamic> toJson() {
    return {
      "url": url.toString(),
      "type": type.name,
      "params": params,
      "headers": headers,
      "timeout": timeout.inSeconds,
      "responseType": responseType.name,
      "clientType": clientType.name,
      "authenticated": authenticated?.toCbor().toCborHex()
    };
  }
}

class HTTPWorkerRequest {
  final int id;
  final HTTPWorkerMessage message;
  const HTTPWorkerRequest({required this.id, required this.message});
  Map<String, dynamic> toJson() {
    return {"id": id, "message": message.toJson()};
  }

  factory HTTPWorkerRequest.fromJson(Map<String, dynamic> json) {
    return HTTPWorkerRequest(
        id: json["id"],
        message: HTTPWorkerMessage.fromJson((json["message"] as Map).cast()));
  }
}

abstract class HTTPWorkerResponse {
  final int id;
  abstract final HTTPCallerResponse response;
  bool get isSuccess => true;
  const HTTPWorkerResponse({required this.id});
  factory HTTPWorkerResponse.fromJs(Map<String, dynamic> json) {
    if (json.containsKey("response")) {
      return HTTPWorkerResponseSuccess(
          response: HTTPCallerResponse.fromJs(
              (json["response"] as Map).cast<String, dynamic>()),
          id: json["id"]);
    }
    return HTTPWorkerResponseError(message: json["message"], id: json["id"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "response": response.toJson()};
  }
}

class HTTPWorkerResponseSuccess<T> extends HTTPWorkerResponse {
  @override
  final HTTPCallerResponse response;
  const HTTPWorkerResponseSuccess({required this.response, required super.id});
  @override
  Map<String, dynamic> toJson() {
    return {"id": id, "response": response.toJson()};
  }
}

class HTTPWorkerResponseError<T> extends HTTPWorkerResponse {
  @override
  bool get isSuccess => false;
  final String message;
  @override
  HTTPCallerResponse get response =>
      throw ApiProviderException(message: message);
  const HTTPWorkerResponseError({required this.message, required super.id});
  factory HTTPWorkerResponseError.fromJson(Map<String, dynamic> json) {
    return HTTPWorkerResponseError(id: json["id"], message: json["message"]);
  }
  @override
  Map<String, dynamic> toJson() {
    return {"id": id, "message": message};
  }
}

class HTTPWorkerMessageCompleter {
  final int id;
  HTTPWorkerMessageCompleter(this.id);
  final Completer<HTTPWorkerResponse> _messageCompleter = Completer();

  void complete(HTTPWorkerResponse message) {
    _messageCompleter.complete(message);
  }

  void error(WalletException err) {
    _messageCompleter.completeError(err);
  }

  Future<HTTPWorkerResponse> getResult({Duration? timeout}) async {
    final result = await _messageCompleter.future
        .timeout(timeout ?? const Duration(seconds: 60));
    return result;
  }
}

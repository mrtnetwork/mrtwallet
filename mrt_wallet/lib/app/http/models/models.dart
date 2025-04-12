import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/device/models/platform.dart';
import 'package:mrt_wallet/app/core.dart';

enum HTTPClientType {
  cached,
  single;

  static HTTPClientType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: "invalid client type name"),
    );
  }
}

typedef OnStreamReapose = void Function(
    int cumulativeBytesLoaded, int expectedTotalBytes);

enum HTTPResponseType {
  binary,
  string,
  json,
  map,
  listOfMap;

  static HTTPResponseType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: "invalid response type name"),
    );
  }
}

class HTTPCallerResponse {
  final Object? result;
  final int statusCode;
  final HTTPResponseType responseType;

  HTTPCallerResponse copyWith(
      {Object? result, int? statusCode, HTTPResponseType? responseType}) {
    return HTTPCallerResponse(
        result: result ?? this.result,
        statusCode: statusCode ?? this.statusCode,
        responseType: responseType ?? this.responseType);
  }

  factory HTTPCallerResponse.fromJs(Map<String, dynamic> json) {
    final responseType = HTTPResponseType.fromName(json["responseType"]);
    final int status = json["statusCode"];
    return HTTPCallerResponse(
        result: isSuccessStatusCode(status)
            ? fromJsObject(json["result"], responseType)
            : json["result"],
        statusCode: status,
        responseType: responseType);
  }
  Map<String, dynamic> toJson() {
    return {
      "result": result,
      "statusCode": statusCode,
      "responseType": responseType.name
    };
  }

  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static Object stringToJsonObject(String data, HTTPResponseType type) {
    switch (type) {
      case HTTPResponseType.json:
        return StringUtils.toJson(data);
      case HTTPResponseType.map:
        return StringUtils.toJson<Map<String, dynamic>>(data);
      case HTTPResponseType.listOfMap:
        return StringUtils.toJson<List>(data)
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
      default:
        return data;
    }
  }

  static Object? fromJsObject(Object? fromJsObject, HTTPResponseType type) {
    if (fromJsObject == null) return null;
    switch (type) {
      case HTTPResponseType.binary:
        return (fromJsObject as List).cast<int>();
      default:
        return stringToJsonObject(fromJsObject as String, type);
    }
  }

  bool get isSuccess => isSuccessStatusCode(statusCode);

  T bodyAs<T>() {
    return result as T;
  }

  T successResult<T>() {
    throwIfError();
    return bodyAs<T>();
  }

  String? error() {
    if (isSuccess) return null;
    return result as String?;
  }

  void throwIfError() {
    if (isSuccess) return;
    final err = error();
    if (err?.isEmpty ?? true) {
      throw ApiProviderException(statusCode: statusCode);
    } else if (StrUtils.isHtml(err!)) {
      throw ApiProviderException(statusCode: statusCode);
    } else {
      throw ApiProviderException(statusCode: statusCode, message: err);
    }
  }

  const HTTPCallerResponse({
    required this.result,
    required this.statusCode,
    required this.responseType,
  });
  factory HTTPCallerResponse.parse(
      {required List<int> bodyBytes,
      required int statusCode,
      required HTTPResponseType type,
      required AppPlatform platform}) {
    if (!isSuccessStatusCode(statusCode)) {
      return HTTPCallerResponse(
          result: StringUtils.tryDecode(bodyBytes),
          statusCode: statusCode,
          responseType: type);
    }
    Object body;
    try {
      if (platform == AppPlatform.web && type != HTTPResponseType.binary) {
        body = StringUtils.decode(bodyBytes);
      } else {
        switch (type) {
          case HTTPResponseType.binary:
            body = bodyBytes;
            break;
          case HTTPResponseType.string:
            body = StringUtils.decode(bodyBytes);
            break;
          case HTTPResponseType.json:
            body = StringUtils.toJson(StringUtils.decode(bodyBytes));
            break;
          case HTTPResponseType.map:
            body = StringUtils.toJson<Map<String, dynamic>>(
                StringUtils.decode(bodyBytes));
            break;
          case HTTPResponseType.listOfMap:
            body = StringUtils.toJson<List>(StringUtils.decode(bodyBytes))
                .map((e) => (e as Map).cast<String, dynamic>())
                .toList();
            break;
        }
      }
      return HTTPCallerResponse(
          result: body, statusCode: statusCode, responseType: type);
    } on ApiProviderException {
      rethrow;
    } catch (e) {
      throw const ApiProviderException(message: "invalid_request_type");
    }
  }
}

enum DigestAuthHeadersAlg {
  md5(name: "MD5"),
  md5Sess(name: "MD5-sess"),
  sha256(name: "SHA-256"),
  sha256Sess(name: "SHA-256-sess"),
  sha512(name: "SHA-512"),
  sha512Sess(name: "SHA-512-sess"),
  sha512256(name: "SHA-512-256"),
  sha512256Sess(name: "SHA-512-256-sess");

  bool get sessionBased => name.endsWith("sess");

  final String name;
  const DigestAuthHeadersAlg({required this.name});
  static DigestAuthHeadersAlg fromName(String? name) {
    if (name == null) return DigestAuthHeadersAlg.md5;
    return values.firstWhere((e) => e.name == name,
        orElse: () =>
            throw WalletException("unsuported_digest_auth_algorithm"));
  }

  List<int> hashBytes(List<int> input) {
    return switch (this) {
      DigestAuthHeadersAlg.md5 ||
      DigestAuthHeadersAlg.md5Sess =>
        MD5.hash(input),
      DigestAuthHeadersAlg.sha256 ||
      DigestAuthHeadersAlg.sha256Sess =>
        SHA256.hash(input),
      DigestAuthHeadersAlg.sha512 ||
      DigestAuthHeadersAlg.sha512Sess =>
        SHA512.hash(input),
      DigestAuthHeadersAlg.sha512256 ||
      DigestAuthHeadersAlg.sha512256Sess =>
        SHA512256.hash(input),
    };
  }

  String hashString(String input) {
    return BytesUtils.toHexString(hashBytes(StringUtils.encode(input)));
  }
}

enum DigestAuthQop {
  auth(name: "auth"),
  authInt(name: "auth-int");

  final String name;
  const DigestAuthQop({required this.name});
  static DigestAuthQop fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletException("unsuported_digest_auth_qop"));
  }
}

class DigestAuthHeaders {
  final String nonce;
  final DigestAuthQop? qop;
  final String realm;
  final DigestAuthHeadersAlg algorithm;
  final String? opaque;
  const DigestAuthHeaders(
      {required this.nonce,
      this.qop,
      required this.realm,
      required this.algorithm,
      required this.opaque});
  factory DigestAuthHeaders.fromJson(Map<String, dynamic> json) {
    return DigestAuthHeaders(
        nonce: json["nonce"],
        qop: json["qop"] == null ? null : DigestAuthQop.fromName(json["qop"]),
        realm: json["realm"],
        algorithm: DigestAuthHeadersAlg.fromName(json["algorithm"]),
        opaque: json["opaque"]);
  }
}

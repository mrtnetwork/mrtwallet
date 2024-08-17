class ApiProviderExceptionConst {
  static const int timeoutStatucCode = 10001;
}

class ApiProviderException implements Exception {
  static const List<int> validStatusCode = [
    404,
    400,
    401,
    403,
    405,
    408,
    500,
    503
  ];

  final String? message;
  final int? statusCode;
  final int? code;
  final Map<String, dynamic>? responseData;
  final Map<String, dynamic>? requestPayload;
  bool get isTimeout => code == ApiProviderExceptionConst.timeoutStatucCode;
  const ApiProviderException(
      {this.message,
      this.statusCode,
      this.responseData,
      this.code,
      this.requestPayload});
  @override
  String toString() {
    if (message != null) return message!;
    if (responseData?["error"] != null) {
      return responseData!["error"].toString();
    }
    if (responseData?["message"] != null) {
      return responseData!["message"].toString();
    }
    if (statusCode != null && validStatusCode.contains(statusCode)) {
      return "http_error_$statusCode";
    }
    return "request_error";
  }
}

class ApiProviderException implements Exception {
  final String? message;
  final int? statusCode;
  final int? code;
  final Map<String, dynamic>? responseData;
  final Map<String, dynamic>? requestPayload;
  const ApiProviderException(
      {this.message,
      this.statusCode,
      this.responseData,
      this.code,
      this.requestPayload});
  @override
  String toString() {
    if (message != null) return message!;
    if (responseData?["error"] != null) return responseData!["error"];
    if (responseData?["message"] != null) return responseData!["message"];
    return "request_error";
  }
}

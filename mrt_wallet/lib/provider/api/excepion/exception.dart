class ApiProviderException implements Exception {
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? responseData;
  const ApiProviderException(
      {this.message, this.statusCode, this.responseData});
  @override
  String toString() {
    if (message != null) return message!;
    if (responseData?["error"] != null) return responseData!["error"];
    if (responseData?["message"] != null) return responseData!["message"];
    return "request_error";
  }
}

import 'package:http/http.dart' as http;

mixin HttpProvider {
  static final http.Client _client = http.Client();
  http.Client get client => _client;

  /// Performs an HTTP GET request to the specified [url].
  ///
  /// The type parameter [T] specifies the expected response type.
  Future<T> get<T>(String url);

  /// Performs an HTTP POST request to the specified [url].
  ///
  /// The type parameter [T] specifies the expected response type.
  ///
  /// Optional parameters:
  /// - [headers]: A map of headers to be included in the request.
  /// - [body]: The request body, typically in JSON format.
  Future<T> post<T>(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"},
      Object? body});
}

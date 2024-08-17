import 'package:blockchain_utils/utils/string/string.dart';
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/app/utils/method/utiils.dart';

class HttpUtils {
  static const Map<String, String> applicationJson = {
    "Accept": "application/json"
  };
  static Future<MethodResult<T>> get<T>(String uri,
      {Map<String, String>? header,
      Duration timeout = const Duration(seconds: 30)}) async {
    final client = http.Client();
    try {
      return await MethodUtils.httpCaller<T>(() async {
        try {
          return client.get(Uri.parse(uri), headers: header).timeout(timeout);
        } catch (e) {
          rethrow;
        }
      });
    } finally {
      client.close();
    }
  }

  static Future<MethodResult<List<int>>> getStream(String uri,
      {Map<String, String>? headers,
      Duration timeout = const Duration(seconds: 30),
      OnStreamReapose? response}) async {
    final client = http.Client();
    try {
      return await MethodUtils.httpStreamCaller(() async {
        final request = http.Request("GET", Uri.parse(uri));
        request.headers.addAll(headers ?? {});
        return client.send(http.Request("GET", Uri.parse(uri)));
      }, onProgress: response);
    } finally {
      client.close();
    }
  }

  static Future<MethodResult<T>> post<T>(
    String uri, {
    Map<String, String>? header,
    Object? body,
  }) async {
    final client = http.Client();
    Object? data;
    if (body != null && (body is Map || body is List)) {
      data = StringUtils.fromJson(body);
    }
    try {
      return await MethodUtils.httpCaller(() async =>
          await client.post(Uri.parse(uri), headers: header, body: data));
    } finally {
      client.close();
    }
  }
}

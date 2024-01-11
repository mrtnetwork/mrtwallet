import 'dart:async';

import 'package:bitcoin_base/bitcoin_base.dart' show ApiService;
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class BitcoinApiService with HttpProvider implements ApiService {
  BitcoinApiService(this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  final ApiProviderTracker provider;
  final Duration defaultTimeOut;
  Future<T> _httpCaller<T>(Future<http.Response> Function() t,
      {bool isPost = false}) async {
    bool hasError = false;
    bool isRechedLimit = false;
    try {
      final tx = await t().timeout(defaultTimeOut);
      return _readResponse<T>(tx, isPost: isPost);
    } on http.ClientException catch (e) {
      hasError = true;
      throw ApiProviderException(message: e.message);
    } on TimeoutException catch (e) {
      hasError = true;
      throw ApiProviderException(message: e.toString());
    } on ApiProviderException catch (e) {
      hasError = true;
      isRechedLimit = e.statusCode == 429;
      rethrow;
    } catch (e) {
      hasError = true;
      rethrow;
    } finally {
      if (hasError) {
        if (isRechedLimit) {
          provider.setReachedLimit();
        } else {
          provider.setErr();
        }
      } else {
        provider.setActive();
      }
    }
  }

  @override
  Future<T> get<T>(String url) async {
    final result =
        await _httpCaller<T>(() async => await client.get(Uri.parse(url)));
    return result;
  }

  @override
  Future<T> post<T>(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"},
      Object? body}) async {
    final result = await _httpCaller<T>(
        () async => client.post(Uri.parse(url), headers: headers, body: body),
        isPost: true);

    return result;
  }

  T _readResponse<T>(http.Response response, {bool isPost = false}) {
    final String toString = _readBody(response, isPost: isPost);
    switch (T) {
      case String:
        return toString as T;
      case List:
      case Map:
        return StringUtils.toJson(toString) as T;
      default:
        try {
          return StringUtils.toJson(toString) as T;
        } catch (e) {
          throw const ApiProviderException(message: "invalid_request_type");
        }
    }
  }

  String _readBody(http.Response response, {bool isPost = false}) {
    _readErr(response, isPost: isPost);
    return StringUtils.decode(response.bodyBytes);
  }

  void _readErr(http.Response response, {bool isPost = false}) {
    if (response.statusCode == 200) return;
    if (response.statusCode == 201) {
      if (isPost && provider.provider == ApiProviderService.blockCypher) return;
    }
    String toString = StringUtils.decode(response.bodyBytes);
    Map<String, dynamic>? errorResult;
    try {
      if (toString.isNotEmpty) {
        errorResult = StringUtils.toJson(toString);
      }
      // ignore: empty_catches
    } catch (e) {}

    throw ApiProviderException(
        message: toString.isEmpty || errorResult != null ? null : toString,
        statusCode: response.statusCode,
        responseData: errorResult);
  }
}

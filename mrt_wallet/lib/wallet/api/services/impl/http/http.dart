import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart';
import 'package:mrt_wallet/wallet/api/services/core/tracker.dart';
import 'dart:async';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';

abstract class HTTPService<P extends APIProvider>
    implements BaseServiceProtocol<P> {
  @override
  ServiceProtocol get protocol => ServiceProtocol.http;
  @override
  final APIServiceTracker tracker = APIServiceTracker();
  static final http.Client _client = http.Client();
  http.Client get client => _client;
  Duration get defaultTimeOut;

  final _lock = SynchronizedLock();

  Future<T> _callSynchronized<T>(Future<http.Response> Function() t,
      {List<int> allowStatus = const [200]}) async {
    if (requestTimeout == null) {
      return _onException<T>(t, allowStatus: allowStatus);
    }
    await _lock.synchronized(() async {
      await Future.delayed(requestTimeout!);
    });
    return _onException<T>(t, allowStatus: allowStatus);
  }

  Duration? get requestTimeout => null;
  Uri _toUri(String callUrl) {
    final uri = Uri.parse(callUrl);
    if (provider.auth?.type != ProviderAuthType.query) {
      return uri;
    }
    return uri.replace(queryParameters: provider.auth!.auth);
  }

  @override
  void disposeService() {}

  Future<T> providerPOST<T>(String url, Object? params,
      {List<int> allowStatus = const [200],
      Duration? timeout,
      Map<String, String>? headers}) async {
    T? response;
    try {
      response = await _callSynchronized<T>(() async {
        return await client
            .post(_toUri(url),
                headers: {
                  'Content-Type': 'application/json',
                  ...headers ?? {},
                  if (provider.auth?.type == ProviderAuthType.header)
                    ...provider.auth!.auth
                },
                body: params)
            .timeout(timeout ?? defaultTimeOut);
      }, allowStatus: allowStatus);
      return response!;
    } on ApiProviderException catch (e) {
      tracker.addRequest(
          ApiRequest(uri: url, params: params?.toString(), error: e));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(ApiRequest(
            params: params?.toString(), response: response.toString()));
      }
    }
  }

  Future<T> providerGET<T>(String url,
      {List<int> allowStatus = const [200],
      Duration? timeout,
      Map<String, String>? headers}) async {
    T? response;

    try {
      response = await _callSynchronized<T>(() async {
        return await client
            .get(_toUri(url),
                headers: headers ??
                    {
                      'Content-Type': 'application/json',
                      if (provider.auth?.type == ProviderAuthType.header)
                        ...provider.auth!.auth
                    })
            .timeout(timeout ?? defaultTimeOut);
      }, allowStatus: allowStatus);
      return response!;
    } on ApiProviderException catch (e) {
      tracker.addRequest(ApiRequest(uri: url, params: null, error: e));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(
            ApiRequest(uri: url, params: null, response: response.toString()));
      }
    }
  }

  Future<T> _onException<T>(Future<http.Response> Function() t,
      {List<int> allowStatus = const [200]}) async {
    try {
      final response = await t();
      if (allowStatus.isNotEmpty &&
          !allowStatus.contains(response.statusCode)) {
        final decode = StringUtils.tryToJson(response.body);
        final Map<String, dynamic>? map =
            (decode is Map<String, dynamic>?) ? decode : null;
        throw ApiProviderException(
            statusCode: response.statusCode,
            responseData: map,
            message: map == null ? response.body : null);
      }
      return _readResponse<T>(response);
    } on http.ClientException {
      throw const ApiProviderException(message: "api_http_client_error");
    } on ApiProviderException {
      rethrow;
    } on TimeoutException {
      throw const ApiProviderException(
          message: "api_http_timeout_error",
          code: ApiProviderExceptionConst.timeoutStatucCode);
    } on FormatException {
      throw const ApiProviderException(message: "invalid_json_response");
    } on ArgumentError catch (e) {
      throw ApiProviderException(message: e.message.toString());
    } catch (e) {
      throw const ApiProviderException(message: "api_unknown_error");
    }
  }

  T _readResponse<T>(http.Response response) {
    final String toString = StringUtils.decode(response.bodyBytes);
    switch (T) {
      case http.Response:
        return response as T;
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
}

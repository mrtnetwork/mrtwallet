import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart';
import 'package:mrt_wallet/wallet/api/services/core/tracker.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';
import 'dart:async';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';

abstract class HTTPService<P extends APIProvider>
    with HttpImpl
    implements BaseServiceProtocol<P> {
  @override
  APPIsolate get isolate;
  @override
  ServiceProtocol get protocol => ServiceProtocol.http;
  @override
  final APIServiceTracker tracker = APIServiceTracker();
  Duration get defaultTimeOut;

  final _lock = SynchronizedLock();

  Future<HTTPCallerResponse> _callSynchronized<T>(
    Future<HTTPCallerResponse> Function() t, {
    List<int> allowStatus = const [200],
  }) async {
    if (requestTimeout == null) {
      return _onException<T>(t, allowStatus: allowStatus);
    }
    await _lock.synchronized(() async {
      await Future.delayed(requestTimeout!);
    });
    return _onException<T>(t, allowStatus: allowStatus);
  }

  Future<BaseServiceResponse<T>> _callSynchronizedService<T>(
    Future<HTTPCallerResponse> Function() t, {
    List<int> allowStatus = const [200],
  }) async {
    if (requestTimeout == null) {
      return _onServiceException<T>(t, allowStatus: allowStatus);
    }
    await _lock.synchronized(() async {
      await Future.delayed(requestTimeout!);
    });
    return _onServiceException<T>(t, allowStatus: allowStatus);
  }

  Duration? get requestTimeout => null;

  Uri _toUri(String uri) {
    return Uri.parse(uri);
  }

  @override
  void disposeService() {}

  Future<HTTPCallerResponse> providerPOST<T>(String url, Object? params,
      {List<int> allowStatus = const [200],
      Duration? timeout,
      Map<String, String>? headers,
      HTTPResponseType? responseType}) async {
    HTTPCallerResponse? response;
    try {
      final toUri = _toUri(url);
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        ...headers ?? {}
      };
      response = await _callSynchronized<T>(
        () async {
          return await serviceCaller.call(
              url: toUri,
              timeout: timeout ?? defaultTimeOut,
              body: params,
              headers: requestHeaders,
              responseType: _detectTemplateType<T>(responseType: responseType),
              type: HTTPRequestType.post,
              isolate: isolate,
              authenticated: provider.auth);
        },
        allowStatus: allowStatus,
      );
      return response;
    } on ApiProviderException catch (e) {
      tracker.addRequest(
          ApiRequest(uri: url, params: params?.toString(), error: e));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(ApiRequest(
            params: params?.toString(), response: response.result.toString()));
      }
    }
  }

  Future<HTTPCallerResponse> providerGET<T>(String url,
      {List<int> allowStatus = const [200],
      Duration? timeout,
      Map<String, String>? headers,
      HTTPResponseType? responseType}) async {
    HTTPCallerResponse? response;

    try {
      final toUri = _toUri(url);

      final Map<String, String> requestHeaders =
          headers ?? {'Content-Type': 'application/json'};
      response = await _callSynchronized<T>(() async {
        return await serviceCaller.call(
            url: toUri,
            timeout: timeout ?? defaultTimeOut,
            headers: requestHeaders,
            responseType: _detectTemplateType<T>(responseType: responseType),
            type: HTTPRequestType.get,
            isolate: isolate,
            authenticated: provider.auth);
      }, allowStatus: allowStatus);
      return response;
    } on ApiProviderException catch (e) {
      tracker.addRequest(ApiRequest(uri: url, params: null, error: e));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(ApiRequest(
            uri: url, params: null, response: response.result.toString()));
      }
    }
  }

  Future<BaseServiceResponse<T>> serviceRequest<T>(
      BaseServiceRequestParams request,
      {List<int> allowStatus = const [200],
      Uri? uri,
      Duration? timeout,
      HTTPResponseType? responseType}) async {
    BaseServiceResponse<T>? response;
    final toUri = uri ?? request.toUri(provider.callUrl);
    try {
      final Map<String, String> headers = {
        if (request.type == RequestServiceType.post)
          'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...request.headers
      };
      final type = _detectTemplateType<T>(responseType: responseType);
      response = await _callSynchronizedService<T>(() async {
        return switch (request.type) {
          RequestServiceType.get => await serviceCaller.call(
              url: toUri,
              timeout: timeout ?? defaultTimeOut,
              headers: headers,
              responseType: type,
              type: HTTPRequestType.get,
              isolate: isolate,
              authenticated: provider.auth),
          RequestServiceType.post => await serviceCaller.call(
              url: toUri,
              timeout: timeout ?? defaultTimeOut,
              headers: headers,
              responseType: type,
              body: request.body(),
              type: HTTPRequestType.post,
              isolate: isolate,
              authenticated: provider.auth)
        };
      }, allowStatus: allowStatus);

      return response;
    } on ApiProviderException catch (e) {
      tracker.addRequest(
          ApiRequest(uri: toUri.toString(), params: null, error: e));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(
            ApiRequest(uri: toUri.toString(), params: null, response: null));
      }
    }
  }

  Future<BaseServiceResponse<T>> _onServiceException<T>(
    Future<HTTPCallerResponse> Function() t, {
    List<int> allowStatus = const [200],
  }) async {
    try {
      final response = await t();
      if (allowStatus.isNotEmpty &&
          !allowStatus.contains(response.statusCode)) {
        final isValidStatusCode =
            ApiProviderException.validStatusCode.contains(response.statusCode);
        final Map<String, dynamic>? decode =
            StringUtils.tryToJson(response.result);
        throw ApiProviderException(
            statusCode: response.statusCode,
            responseData: decode,
            message:
                decode == null && isValidStatusCode ? null : response.error());
      }
      return _readServiceResponse<T>(response);
    } on http.ClientException catch (e) {
      throw ApiProviderException(message: e.toString());
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

  Future<HTTPCallerResponse> _onException<T>(
    Future<HTTPCallerResponse> Function() t, {
    List<int> allowStatus = const [200],
  }) async {
    try {
      final response = await t();
      if (allowStatus.isNotEmpty &&
          !allowStatus.contains(response.statusCode)) {
        final isValidStatusCode =
            ApiProviderException.validStatusCode.contains(response.statusCode);
        final Map<String, dynamic>? decode =
            StringUtils.tryToJson(response.result);
        throw ApiProviderException(
            statusCode: response.statusCode,
            responseData: decode,
            message:
                decode == null && isValidStatusCode ? null : response.error());
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

  HTTPResponseType _detectTemplateType<T>({HTTPResponseType? responseType}) {
    if (responseType != null) return responseType;
    if (dynamic is T) return HTTPResponseType.json;
    if (<String, dynamic>{} is T) return HTTPResponseType.map;
    if (<Map<String, dynamic>>[] is T) return HTTPResponseType.listOfMap;
    if (<int>[] is T) return HTTPResponseType.binary;
    switch (T) {
      case const (String):
        return HTTPResponseType.string;
      default:
        return HTTPResponseType.json;
    }
  }

  BaseServiceResponse<T> _readServiceResponse<T>(HTTPCallerResponse response) {
    try {
      if (response.isSuccess) {
        return ServiceSuccessRespose(
            response: response.bodyAs<T>(), statusCode: response.statusCode);
      }
      return ServiceErrorResponse(
          error: response.bodyAs<String?>(), statusCode: response.statusCode);
    } catch (e) {
      throw const ApiProviderException(message: "invalid_request_type");
    }
  }

  HTTPCallerResponse _readResponse<T>(HTTPCallerResponse response) {
    try {
      return HTTPCallerResponse(
          result: response.bodyAs<T>(),
          statusCode: response.statusCode,
          responseType: response.responseType);
    } catch (e) {
      throw const ApiProviderException(message: "invalid_request_type");
    }
  }
}

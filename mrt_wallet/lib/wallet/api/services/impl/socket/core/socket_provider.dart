import 'dart:async';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';

abstract class BaseSocketService<T extends APIProvider>
    implements BaseServiceProtocol<T> {
  Future<void> connect();
  bool get isConnected;
  String get url;
  Future<Map<String, dynamic>> providerCaller(
      Future<Map<String, dynamic>> Function() t,
      SocketRequestCompeleter param) async {
    Map<String, dynamic>? response;
    try {
      response = await _onException(t);
      return response;
    } on ApiProviderException catch (e) {
      tracker.addRequest(ApiRequest(params: param.params, error: e));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(
            ApiRequest(params: param.params, response: response.toString()));
      }
    }
  }

  Future<Map<String, dynamic>> _onException(
      Future<Map<String, dynamic>> Function() t) async {
    try {
      await connect().timeout(const Duration(seconds: 30));
      if (!isConnected) {
        throw const ApiProviderException(message: "node_connection_error");
      }
      final response = await t();
      return response;
    } on ApiProviderException {
      rethrow;
    } on RPCError catch (e) {
      throw ApiProviderException(
          message: e.message,
          statusCode: e.errorCode,
          responseData: e.request,
          code: e.errorCode,
          requestPayload: e.details);
    } on TimeoutException {
      throw const ApiProviderException(message: "api_http_timeout_error");
    } on ArgumentError catch (e) {
      throw ApiProviderException(message: e.message.toString());
    } catch (e) {
      throw const ApiProviderException(message: "api_unknown_error");
    }
  }
}

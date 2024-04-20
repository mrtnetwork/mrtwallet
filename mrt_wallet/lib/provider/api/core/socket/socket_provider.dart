import 'dart:async';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/api/models/request_completer.dart';

abstract class BaseSocketProvider implements BaseProviderProtocol {
  @override
  void close();
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
      provider.addRequest(ApiRequest(params: param.params, error: e));
      rethrow;
    } finally {
      if (response != null) {
        provider.addRequest(
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
          requestPayload: e.data);
    } on TimeoutException {
      throw const ApiProviderException(message: "api_http_timeout_error");
    } on ArgumentError catch (e) {
      throw ApiProviderException(message: e.message.toString());
    } catch (e) {
      throw const ApiProviderException(message: "api_unknown_error");
    }
  }
}

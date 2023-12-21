import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:mrt_wallet/app/utility/method_caller.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:xrp_dart/xrp_dart.dart';

mixin HttpProvider {
  static final http.Client _client = http.Client();
  http.Client get client => _client;

  Future<T> providerCaller<T>(
      Future<T> Function() t, ApiProviderTracker provider,
      {Canclable? canclable, Duration? delay}) async {
    bool hasError = false;
    bool isRechedLimit = false;
    try {
      return await t();
    } on RPCError catch (e) {
      throw ApiProviderException(
          message: e.message,
          statusCode: e.errorCode,
          responseData: e.request,
          code: e.errorCode,
          requestPayload: e.data);
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
}

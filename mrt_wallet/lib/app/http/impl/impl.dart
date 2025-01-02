import 'package:mrt_wallet/app/http/isolate/core/service.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';
import 'package:mrt_wallet/app/http/models/models.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';

mixin HttpImpl {
  static final HTTPServiceWorker _serviceCaller = HTTPServiceWorker.instance;
  HTTPServiceWorker get serviceCaller => _serviceCaller;
  static HTTPResponseType _detectTemplateType<T>(
      {HTTPResponseType? responseType}) {
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

  Future<MethodResult<T>> httpGet<T>(String uri,
      {Map<String, String>? headers,
      Duration timeout = const Duration(seconds: 30),
      HTTPResponseType? responseType,
      HTTPClientType clientType = HTTPClientType.single,
      ProviderAuthenticated? authenticated,
      APPIsolate isolate = APPIsolate.separate}) async {
    final rType = _detectTemplateType<T>(responseType: responseType);
    return await MethodUtils.call<T>(() async {
      final r = await serviceCaller.call(
          url: Uri.parse(uri),
          timeout: timeout,
          type: HTTPRequestType.get,
          clientType: clientType,
          headers: headers,
          responseType: rType,
          authenticated: authenticated,
          isolate: isolate);
      return r.bodyAs<T>();
    });
  }

  Future<MethodResult<List<int>>> makeStream(
      {required String uri,
      Map<String, String> headers = const {},
      OnStreamReapose? onProgress}) async {
    return await MethodUtils.call(() async {
      final r = await serviceCaller.makeStream(
          uri: Uri.parse(uri), onProgress: onProgress, headers: headers);
      return r.bodyAs<List<int>>();
    });
  }
}

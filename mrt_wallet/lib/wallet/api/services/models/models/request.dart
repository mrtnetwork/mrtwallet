import 'package:mrt_wallet/app/error/exception/exception.dart';

class ApiRequest {
  ApiRequest({this.error, required this.uri, required this.identifier})
      : time = DateTime.now().toLocal();
  final String identifier;
  // final String? params;
  final String uri;
  final ApiProviderException? error;
  bool get hasError => error != null;
  // final String? response;
  final DateTime time;
}

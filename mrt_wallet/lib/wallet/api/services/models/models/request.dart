import 'package:mrt_wallet/app/error/exception/exception.dart';

class ApiRequest {
  ApiRequest({required this.params, this.response, this.error, this.uri})
      : time = DateTime.now().toLocal();
  final String? params;
  final String? uri;
  final ApiProviderException? error;
  bool get hasError => error != null;
  final String? response;
  final DateTime time;
}

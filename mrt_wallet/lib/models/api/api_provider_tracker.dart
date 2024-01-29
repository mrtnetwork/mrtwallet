import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

enum ApiProviderStatus { active, warning, error }

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

class ApiProviderTracker<T extends ApiProviderService> {
  ApiProviderTracker({required this.provider});
  final Live<ApiProviderStatus> _status = Live(ApiProviderStatus.active);
  ApiProviderStatus get status => _status.value;
  Live<ApiProviderStatus> get liveStatus => _status;
  final T provider;
  final List<ApiRequest> _requests = [];
  List<ApiRequest> get requests => List<ApiRequest>.from(_requests)
    ..sort((a, b) => b.time.compareTo(a.time));
  bool get hasActive => _status.value == ApiProviderStatus.active;
  int get requestCount => _requests.length;

  int _totalSuccess = 0;
  int _totalError = 0;
  int get totalSuccess => _totalSuccess;

  void addRequest(ApiRequest request) {
    _requests.add(request);
    _updateStatus();
  }

  ApiProviderStatus _checkStatus() {
    _totalSuccess = _requests.where((element) => !element.hasError).length;
    _totalError = _requests.length - _totalSuccess;
    if (_requests.isEmpty || _totalSuccess == _requests.length) {
      return ApiProviderStatus.active;
    }
    if (_totalError == _requests.length) return ApiProviderStatus.error;
    return ApiProviderStatus.warning;
  }

  void _updateStatus() {
    final updateStatus = _checkStatus();
    if (_status.value != updateStatus) {
      _status.value = updateStatus;
    }
  }

  void notify() {
    _status.notify();
  }

  void clean() {
    _requests.clear();
    _totalSuccess = 0;
    _totalError = 0;
    _status.value == ApiProviderStatus.active;
    _status.dispose();
  }
}

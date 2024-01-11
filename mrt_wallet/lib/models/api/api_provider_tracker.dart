import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

enum ApiProviderStatus {
  active,
  error,
  reachedLimit,
}

class ApiProviderTracker<T extends ApiProviderService> {
  ApiProviderTracker({required this.provider});
  final Live<ApiProviderStatus> _status = Live(ApiProviderStatus.active);
  final T provider;
  bool get hasActive => _status.value == ApiProviderStatus.active;
  int _requestCount = 0;
  int get requestCount => _requestCount;
  void _setStatus(ApiProviderStatus status) {
    if (_status.value == status) return;
    _status.value = status;
  }

  void addRequest() {
    _requestCount++;
  }

  void setErr() => _setStatus(ApiProviderStatus.error);

  void setActive() => _setStatus(ApiProviderStatus.active);

  void setReachedLimit() => _setStatus(ApiProviderStatus.reachedLimit);

  @override
  String toString() {
    switch (_status.value) {
      case ApiProviderStatus.active:
        return "active";
      case ApiProviderStatus.error:
        return "last_request_error";
      default:
        return "reached_limit_error";
    }
  }
}

import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';

class APIServiceTracker {
  final Live<APIServiceStatus> _status = Live(APIServiceStatus.active);
  APIServiceStatus get status => _status.value;
  Live<APIServiceStatus> get liveStatus => _status;
  final List<ApiRequest> _requests = [];
  List<ApiRequest> get requests => List<ApiRequest>.from(_requests)
    ..sort((a, b) => b.time.compareTo(a.time));
  bool get hasActive => _status.value == APIServiceStatus.active;
  int get requestCount => _requests.length;

  int _totalSuccess = 0;
  int _totalError = 0;
  int get totalSuccess => _totalSuccess;

  void addRequest(ApiRequest request) {
    _requests.add(request);
    _updateStatus();
  }

  APIServiceStatus _checkStatus() {
    _totalSuccess = _requests.where((element) => !element.hasError).length;
    _totalError = _requests.length - _totalSuccess;
    if (_requests.isEmpty || _totalSuccess == _requests.length) {
      return APIServiceStatus.active;
    }
    if (_totalError == _requests.length) return APIServiceStatus.error;
    return APIServiceStatus.warning;
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
    _status.value == APIServiceStatus.active;
    _status.dispose();
  }
}

import 'app_exception.dart';

class CancelableExption implements AppException {
  const CancelableExption();

  @override
  String get message => "request_cancelled";
  @override
  String toString() {
    return message;
  }
}

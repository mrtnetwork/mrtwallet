import 'app_exception.dart';

class BadCondition implements AppException {
  const BadCondition();

  @override
  String toString() {
    return "wallet_in_progress_wait";
  }

  @override
  String get message => "wallet_in_progress_wait";
}

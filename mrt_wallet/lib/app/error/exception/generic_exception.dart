import 'app_exception.dart';

class GenericException implements AppException {
  const GenericException(this.message);
  @override
  final String message;
  @override
  String toString() {
    return message;
  }
}

import 'package:mrt_wallet/wallet/api/services/core/tracker.dart';

abstract class BaseServiceProtocol {
  APIServiceTracker get provider;
  void close();
}

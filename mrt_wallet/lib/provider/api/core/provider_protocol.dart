import 'package:mrt_wallet/models/api/api_provider_tracker.dart';

abstract class BaseProviderProtocol {
  ApiProviderTracker get provider;

  void close();
}

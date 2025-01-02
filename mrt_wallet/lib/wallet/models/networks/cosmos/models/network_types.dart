import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

class CosmosNetworkTypes {
  final int value;
  const CosmosNetworkTypes._(this.value);
  static const CosmosNetworkTypes main = CosmosNetworkTypes._(0);
  static const CosmosNetworkTypes forked = CosmosNetworkTypes._(1);
  static const CosmosNetworkTypes thorAndForked = CosmosNetworkTypes._(2);
  static const CosmosNetworkTypes ethermint = CosmosNetworkTypes._(3);
  bool get isEthermint => this == ethermint;
  bool get isThorAndForked => this == thorAndForked;
  static const List<CosmosNetworkTypes> values = [
    main,
    forked,
    thorAndForked,
    ethermint
  ];
  factory CosmosNetworkTypes.fromValue(int value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw const WalletException(
            "No CosmosNetworkTypes element found for the given value."));
  }
}

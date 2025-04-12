part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

enum CosmosChainStorage implements ChainStorageKey {
  channelIds(0);

  @override
  final int storageId;
  const CosmosChainStorage(this.storageId);
}

class CosmosChainConfig extends ChainConfig<CosmosChainStorage> {
  CosmosChainConfig();
  factory CosmosChainConfig.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    return CosmosChainConfig();
  }

  @override
  double get appbarHeight => 0;

  @override
  bool get hasAction => false;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([]), CborTagsConst.cosmosChainConfig);
  }

  @override
  List<CosmosChainStorage> get storageKeys => CosmosChainStorage.values;
}

part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

mixin CosmosChainRepository on Chain<
    CosmosAPIProvider,
    CosmosNetworkParams,
    CosmosBaseAddress,
    CW20Token,
    NFTCore,
    ICosmosAddress,
    WalletCosmosNetwork,
    CosmosClient,
    ChainStorageKey,
    CosmosChainConfig,
    WalletTransaction<CosmosBaseAddress>> {
  final _repositorySync = SynchronizedLock();
  CosmosAccountIBCChannelIds? _channelId;
  Future<CosmosAccountIBCChannelIds> _loadChannelIds() async {
    try {
      final data = await _readStorage(storage: CosmosChainStorage.channelIds);
      return CosmosAccountIBCChannelIds.deserialize(hex: data);
    } catch (_) {
      return CosmosAccountIBCChannelIds();
    }
  }

  Future<CosmosAccountIBCChannelIds> _getOrCreateChanelIds() async {
    _channelId ??= await _loadChannelIds();
    return _channelId!;
  }

  Future<List<CosmosIBCChannelId>> loadChannelIds() async {
    return _repositorySync.synchronized(() async {
      final channelIds = await _getOrCreateChanelIds();
      return channelIds.channelIds;
    });
  }

  Future<void> saveChannelId(CosmosIBCChannelId channel) async {
    return _repositorySync.synchronized(() async {
      final channelIds = await _getOrCreateChanelIds();
      channelIds.addChannel(channel);
      await _writeStorageItem(
          storage: CosmosChainStorage.channelIds, item: _channelId);
    });
  }
}

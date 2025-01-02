part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

mixin MoneroChainRepository on Chain<
    MoneroAPIProvider,
    MoneroNetworkParams,
    MoneroAddress,
    TokenCore,
    NFTCore,
    IMoneroAddress,
    WalletMoneroNetwork,
    MoneroClient,
    MoneroChainStorage,
    MoneroChainConfig,
    MoneroWalletTransaction> {
  MoneroAccountBlocksTracker? _defaultTracker;
  MoneroAccountBlocksTracker get defaultTracker => _defaultTracker!;
  MoneroSyncRequests? _syncRequests;
  MoneroSyncRequests get syncRequestss => _syncRequests!;
  final Map<String, MoneroAccountTransactions> _txes = {};
  final _repositorySync = SynchronizedLock();
  Future<MoneroAccountTransactions> _getTransactions(
      IMoneroAddress address) async {
    final data = await _readStorage(
        storage: MoneroChainStorage.transaction,
        identifier: address.identifier);
    if (data == null) {
      return MoneroAccountTransactions(transactions: []);
    }
    return MoneroAccountTransactions.deserialize(cborHex: data);
  }

  @override
  Future<MoneroAccountTransactions> getTransactions(
      IMoneroAddress address) async {
    return _repositorySync.synchronized(() async {
      return _txes[address.identifier] ??= await _getTransactions(address);
    });
  }

  @override
  Future<void> saveTransaction(
      {required IMoneroAddress address,
      required MoneroWalletTransaction transaction}) async {
    final txes = await getTransactions(address);
    txes.addTx(transaction);
    await _writeStorageItem(
        storage: MoneroChainStorage.transaction,
        item: txes,
        identifier: address.identifier);
  }

  Future<MoneroSyncRequests> _getSyncRequests() async {
    final data = await _readStorage(storage: MoneroChainStorage.syncRequests);
    try {
      return MoneroSyncRequests.deserialize(hex: data);
    } catch (e) {
      return MoneroSyncRequests([]);
    }
  }

  Future<MoneroSyncRequests> getSyncRequests() async {
    return _repositorySync.synchronized(() async {
      return _syncRequests ??= await _getSyncRequests();
    });
  }

  Future<void> _saveTracker(MoneroAccountBlocksTracker tracker) async {
    await _repositorySync.synchronized(() async {
      if (tracker.isRequest) {
        if (_syncRequests == null ||
            !_syncRequests!.requests.contains(tracker)) {
          throw WalletExceptionConst.invalidData(messsage: "invalid tracker.");
        }
      } else if (_defaultTracker != tracker) {
        throw WalletExceptionConst.invalidData(messsage: "invalid tracker.");
      }
      if (tracker.isRequest) {
        await _writeStorageItem(
            storage: MoneroChainStorage.syncRequests, item: _syncRequests!);
        return;
      }
      await _writeStorageItem(
          storage: MoneroChainStorage.defaultTracker, item: tracker);
    });
  }

  Future<MoneroAccountBlocksTracker> _loadTracker() async {
    try {
      final data =
          await _readStorage(storage: MoneroChainStorage.defaultTracker);
      return MoneroAccountBlocksTracker.deserialize(hex: data);
    } catch (_) {
      return MoneroAccountBlocksTracker.start();
    }
  }

  Future<MoneroAccountBlocksTracker> loadTracker() async {
    return _repositorySync.synchronized(() async {
      return _defaultTracker ??= await _loadTracker();
    });
  }

  Future<MoneroAPIProvider?> getWalletRPC() async {
    final data = await _readStorage(storage: MoneroChainStorage.walletRPC);
    if (data == null) return null;
    return MoneroAPIProvider.fromCborBytesOrObject(hex: data);
  }

  Future<void> updateWalletRPC(MoneroAPIProvider? provider) async {
    await _writeStorageItem(
        storage: MoneroChainStorage.walletRPC, item: provider);
  }
}

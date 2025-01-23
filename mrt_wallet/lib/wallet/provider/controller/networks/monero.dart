part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletMoneroImpl on WalletManager {
  final _lock = SynchronizedLock();
  SyncRequestController<MoneroSyncBlocksResponse, MoneroSyncBlocksRequest>?
      _syncAccountRequestSubscription;
  SyncRequestController<MoneroSyncBlocksResponse, MoneroSyncBlocksRequest>?
      _syncRequestSubscription;

  Future<
      SyncRequestController<MoneroSyncBlocksResponse,
          MoneroSyncBlocksRequest>?> _hanleStreamRequests(
      {required MoneroChain account,
      required MoneroAccountBlocksTracker tracker,
      required DynamicVoid onDone}) async {
    final MoneroAPIProvider provider = account.client.service.provider;
    final newSync = tracker.getHeightRequest();
    if (newSync == null) return null;
    final r = await crypto.streamRequest(
        StreamRequestMoneroBlockTracking(provider: provider),
        encryptedPart: tracker.toCbor().encode(),
        mode: tracker.isRequest ? WorkerMode.sync2 : WorkerMode.sync1);

    final StreamController<MoneroSyncBlocksRequest> controller = r.controller;
    final stream = r.stream.listen((e) async {
      _lock.synchronized(() async {
        switch (e.type) {
          case MoneroSyncBlockResponseType.blockInfo:
            final blockInfo = e.cast<MoneroBlocksInfoResponse>();
            final offsets = tracker.validatePossitions(blockInfo);
            controller.add(offsets);
            break;
          case MoneroSyncBlockResponseType.trackInfo:
            final accountInfos = e.cast<MoneroSyncAccountResponse>();
            await account.updateSyncTracker(
                response: accountInfos, activeSync: tracker);
            if (account.defaultTracker.hasPendingTxes) {
              _moneroUpdatePendingTxes(account: account);
            }
            if (!tracker.status.inProcess) {
              controller.close();
              onDone();
              return;
            }
            final newSync = tracker.getCurrentRequest();
            if (newSync == null) return;
            controller.add(newSync);
            break;
        }
      });
    }, onDone: onDone);
    controller.add(newSync);
    r.subscription = stream;
    return r;
  }

  Future<void> _updateMoneroAddressBalance(
      {required MoneroChain account, required IMoneroAddress address}) async {
    await _lock.synchronized(() async {
      if (_syncAccountRequestSubscription != null) return;
      final client = account.client;
      final height = await client.getHeight();
      final tracker = account.defaultTracker;
      tracker.updateHeight(height.block);
      _syncAccountRequestSubscription = await _hanleStreamRequests(
        account: account,
        tracker: tracker,
        onDone: () {
          _syncAccountRequestSubscription?.close();
          _syncAccountRequestSubscription = null;
        },
      );
    });
  }

  @override
  Future<void> _updateAddressBalance<
          CHAINTOKEN extends ChainAccount<dynamic, TokenCore, NFTCore>>(
      {required APPCHAINACCOUNT<CHAINTOKEN> account,
      required CHAINTOKEN address}) async {
    if (account.network.type == NetworkType.monero) {
      _updateMoneroAddressBalance(
          account: account.cast(), address: address.cast());
    }
    return super._updateAddressBalance(account: account, address: address);
  }

  Future<void> _moneroAddSyncRequest(
      {required MoneroChain account,
      required IMoneroAddress address,
      required MoneroAccountBlocksTracker request}) async {
    final client = account.client;
    final r = await client.getHeight();
    if (request.endHeight > r.block) {
      throw WalletException("monero_invalid_end_block_height_validator");
    }
    await account.addSyncRequest(request);
    _startSync();
  }

  // final _updatePaymentUtxosSync = SynchronizedLock();

  Future<List<MoneroUnlockedPaymentRequestDetails>> _moneroUpdatePendingTxes(
      {required MoneroChain account,
      List<MoneroAccountPendingTxes>? txIds}) async {
    final txids = txIds ?? account.getAccountsPendingTxes();
    if (txids.isEmpty) return [];
    final txes = await account.client.getTxes(txIds: txids);
    final r = await _callWalletInternal(
      ({required masterKey, required wKey}) async {
        final unlockedInfo = await _walletRequest(
            masterkey: masterKey,
            walletKey: wKey,
            message: WalletRequestMoneroOutputUnlocker(
                account.createUnlockOutputRequests(txes: txes)));
        final payments = await account.client
            .updatePaymentsStatus(unlockedInfo.successPaymets());
        await account.addAddressesUtxos(payments);
        return unlockedInfo.payments;
      },
    );
    return r?.map((e) => e.responses).expand((e) => e).toList() ?? [];
  }

  void _startSync() {
    _lock.synchronized(() async {
      if (_syncRequestSubscription != null) return;
      final chains = _appChains.chains().whereType<MoneroChain>();
      final List<MoneroAccountBlocksTracker> pendingRequests = [];
      for (final i in chains) {
        final r = await i.getSyncRequests();
        pendingRequests.addAll(r.pendingRequests());
      }
      pendingRequests.sort((a, b) => a.created.compareTo(b.created));
      final activeSync =
          pendingRequests.firstWhereNullable((e) => e.status.inProcess);
      if (activeSync == null || activeSync.accounts.isEmpty) return null;
      final syncChain = chains.firstWhere((e) =>
          e.network.coinParam.network ==
          activeSync.accounts.first.primaryAccount.network);
      _syncRequestSubscription = await _hanleStreamRequests(
        account: syncChain,
        tracker: activeSync,
        onDone: () {
          _syncRequestSubscription?.close();
          _syncRequestSubscription = null;
          _startSync();
        },
      );
    });
  }

  Future<void> _moneroUpdateTrackerStatus(
      {required MoneroAccountBlocksTracker tracker,
      required MoneroChain account,
      required MoneroAccountBlocksTrackerStatus status}) async {
    await account.updateTrackerStatus(tracker: tracker, status: status);
    _syncRequestSubscription?.close();
    _syncRequestSubscription = null;
    _startSync();
  }

  @override
  Future<void> _onInitController() async {
    await super._onInitController();
    _startSync();
  }

  @override
  void _dispose() {
    super._dispose();
    _lock.synchronized(() {
      _syncRequestSubscription?.close();
      _syncRequestSubscription = null;
      _syncAccountRequestSubscription?.close();
      _syncAccountRequestSubscription = null;
    });
  }

  @override
  void _onUnlock() async {
    super._onUnlock();
    final chains = _appChains.chains().whereType<MoneroChain>();
    for (final i in chains) {
      await i.init();
      _moneroUpdatePendingTxes(account: i);
    }
  }
}

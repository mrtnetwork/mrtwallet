part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

mixin MoneroChainController
    on
        Chain<
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
            MoneroWalletTransaction>,
        MoneroChainRepository {
  @override
  MoneroAccountBlocksTracker get defaultTracker;
  List<MoneroAccountIndex> relateAccountIndexes(
      MoneroViewPrimaryAccountDetails viewKey) {
    final accounts = relatedTxAccounts(viewKey);
    return accounts.map((e) => e.addrDetails.index).toList();
  }

  List<IMoneroAddress> relatedTxAccounts(
      MoneroViewPrimaryAccountDetails viewKey) {
    return addresses.where((e) => e.addrDetails.viewKey == viewKey).toList();
  }

  List<MoneroAddress> relatedAccountAddresses(
      MoneroViewPrimaryAccountDetails viewKey) {
    final accounts = relatedTxAccounts(viewKey);
    return accounts.map((e) => e.networkAddress).toList();
  }

  List<MoneroOutputDetails> getUtxos(MoneroViewPrimaryAccountDetails viewKey) {
    final addresses = relatedTxAccounts(viewKey);
    return addresses.map((e) => e.utxos).expand((e) => e).toList();
  }

  List<MoneroAccountWithUtxo> relatedTxAccountsUtxos(
      MoneroViewPrimaryAccountDetails viewKey) {
    final addresses = relatedTxAccounts(viewKey);
    final List<MoneroAccountWithUtxo> utxos = [];
    for (final i in addresses) {
      if (i.utxos.isEmpty) continue;
      final addrUtxos = MoneroAccountWithUtxo(
          address: ReceiptAddress(
              view: i.networkAddress.address,
              networkAddress: i.networkAddress,
              account: i),
          utxos: i.utxos);
      utxos.add(addrUtxos);
    }
    return utxos;
  }

  void _updateAddressBalance(IMoneroAddress address) {
    final balance =
        address.utxos.fold(BigInt.zero, (p, c) => p + c.amount.balance);
    address.address.updateAddressBalance(balance);
  }

  Future<void> updateAddressUtxos(
      {required IMoneroAddress address,
      required List<MoneroOutputDetails> outs}) async {
    final unspents = outs.where((e) => e.status.isUnspent || e.status.inPool);
    for (final i in addresses) {
      if (i.addrDetails.viewKey != address.addrDetails.viewKey) continue;
      final addressUtxos =
          unspents.where((e) => e.index == i.addrDetails.index).toList();
      i.replaceUtxos(addressUtxos);
      _updateAddressBalance(i);
    }
    _refreshTotalBalance();
    await _save();
  }

  void checkChainStatus() {
    if (haveAddress) {
      if (defaultTracker.hasPendingTxes) {
        updateConfig(config.copyWith(status: MoneroChainStatus.outputReceived));
        return;
      }
    }
    updateConfig(config.copyWith(status: MoneroChainStatus.none));
  }

  Future<void> addAddressesUtxos(List<MoneroUpdatePaymentRequest> outs) async {
    for (final out in outs) {
      final relatedAccount = relatedTxAccounts(out.primaryAddress);
      for (final i in relatedAccount) {
        if (i.updateUtxos(out.payments)) {
          _updateAddressBalance(i);
        }
      }
      final txes = out.payments.map((e) => e.txId).toList();
      defaultTracker.getAccountInfo(out.primaryAddress).removeTxes(txes);
    }
    _refreshTotalBalance();
    await _saveTracker(defaultTracker);
    checkChainStatus();
  }

  List<MoneroAccountPendingTxes> getAccountsPendingTxes() {
    return defaultTracker.getAccountsPendingTxes();
  }

  IMoneroAddress accountFromPrimaryAddress(
      MoneroViewPrimaryAccountDetails address) {
    return addresses.firstWhere((e) => e.addrDetails.viewKey == address,
        orElse: () => throw WalletExceptionConst.accountDoesNotFound);
  }

  List<MoneroProcessTxIdsRequest> createUnlockOutputRequests(
      {required List<MoneroFetchTxIdsResponse> txes}) {
    final List<MoneroProcessTxIdsRequest> requests = [];
    for (final i in txes) {
      final account = accountFromPrimaryAddress(i.primaryAddress);
      final keyIndexes = relateAccountIndexes(i.primaryAddress);
      requests.add(MoneroProcessTxIdsRequest(
          txes: i.txes,
          primaryAddress: i.primaryAddress,
          keyIndexes: keyIndexes,
          index: account.keyIndex));
    }
    return requests;
  }

  Future<void> updateSyncTracker(
      {required MoneroSyncAccountResponse response,
      required MoneroAccountBlocksTracker activeSync}) async {
    final update = activeSync.updateOffset(response.blockPosition);
    if (update) {
      defaultTracker.addSyncedAccountsPaymentTx(response.txIds);
      await _saveTracker(defaultTracker);
    }
    if (activeSync.isRequest) {
      await _saveTracker(activeSync);
    }
    checkChainStatus();
    await _save();
  }

  Future<void> updatePendingTxes(MoneroAccountPendingTxes tx) async {
    if (tx.txIDs.isEmpty) return;
    final List<String> unknowTxes = [];
    final utxos = getUtxos(tx.primaryAddress);
    for (final i in tx.txIDs) {
      final exists = utxos.any((e) => e.txId == i);
      if (exists) continue;
      unknowTxes.add(i);
    }
    if (unknowTxes.isEmpty) return;
    defaultTracker.addPendingTx(MoneroAccountPendingTxes(
        primaryAddress: tx.primaryAddress, txIDs: unknowTxes));
    await _saveTracker(defaultTracker);
    checkChainStatus();
  }

  @override
  void updateAddressBalance(
      {required IMoneroAddress address, required BigInt? updateBalance}) {
    if (!addresses.contains(address)) return;
    _updateAddressBalance(address);
    _refreshTotalBalance();
  }

  @override
  Future<IMoneroAddress> addNewAddress(CryptoPublicKeyData? publicKey,
      NewAccountParams<MoneroAddress> accountParams) async {
    final newAddress = await super.addNewAddress(publicKey, accountParams);
    defaultTracker.addAccount(newAddress.addrDetails);
    await _saveTracker(defaultTracker);
    return newAddress;
  }

  @override
  Future<bool> removeAccount(IMoneroAddress address) async {
    final r = await super.removeAccount(address);
    if (r) {
      defaultTracker.removeAccount(
          account: address.addrDetails.viewKey,
          index: address.addrDetails.index);
      await _saveTracker(defaultTracker);
      checkChainStatus();
    }
    return r;
  }

  MoneroAccountBlocksTracker createSyncRequest(
      {required List<IMoneroAddress> accounts,
      required int startHeight,
      required int endHeight}) {
    final Map<MoneroViewPrimaryAccountDetails, MoneroSyncAccountsInfos>
        syncAccounts = {};
    for (final i in accounts) {
      final primary = i.addrDetails.primaryAccount();
      final index = MoneroSyncAccountIndexInfo(
          index: i.addrDetails.index, startHeight: startHeight);
      if (syncAccounts.containsKey(primary)) {
        syncAccounts[primary]?.addIndex(index);
      } else {
        syncAccounts[primary] =
            MoneroSyncAccountsInfos(primaryAccount: primary, indexes: [index]);
      }
    }
    return MoneroAccountBlocksTracker.sync(
        accounts: syncAccounts.values.toList(),
        startHeight: startHeight,
        endHeight: endHeight);
  }

  @override
  void hideStatus() {
    updateConfig(config.copyWith(status: MoneroChainStatus.none));
  }

  Future<void> hideAlert() async {
    updateConfig(config.copyWith(showInitializeAlert: false));
    await _save();
  }

  Future<void> addSyncRequest(MoneroAccountBlocksTracker request) async {
    if (!request.isRequest) return;
    if (request.startHeight < network.coinParam.rctHeight) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    final r = await getSyncRequests();
    r.addSyncRequest(request);
    await _saveTracker(request);
  }

  Future<void> _setWalletClient() async {
    final client = clientNullable;
    if (client == null) return;
    final walletClient = await getWalletRPC();
    client.setWalletClient(walletClient);
  }

  Future<void> updateTrackerStatus(
      {required MoneroAccountBlocksTracker tracker,
      required MoneroAccountBlocksTrackerStatus status}) async {
    tracker.updateStatus(status);
    await _saveTracker(tracker);
  }

  @override
  void initProvider() {
    super.initProvider();
    _setWalletClient();
  }

  @override
  Future<MoneroAccountBlocksTracker> loadTracker() async {
    final tracker = await super.loadTracker();
    if (tracker.accounts.isEmpty && haveAddress) {
      for (final i in addresses) {
        tracker.addAccount(i.addrDetails);
      }
      await _saveTracker(tracker);
    }
    return tracker;
  }

  @override
  Future<void> init() async {
    _defaultTracker ??= await loadTracker();
    checkChainStatus();
    return super.init();
  }
}

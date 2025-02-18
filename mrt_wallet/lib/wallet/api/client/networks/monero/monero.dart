import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/monero.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/monero/monero.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';

class MoneroClient extends NetworkClient<IMoneroAddress, MoneroAPIProvider>
    with CryptoWokerImpl {
  MoneroClient({required this.provider, required this.network});
  MoneroWalletClient? _walletClient;
  final MoneroProvider provider;
  @override
  final WalletMoneroNetwork? network;
  MoneroCachedBlockHeight? _height;
  MoneroCachedBlockHeight? get currentHeight => _height;

  String? _genesis;

  @override
  MoneroHTTPService get service => provider.rpc as MoneroHTTPService;

  void setWalletClient(MoneroAPIProvider? provider) {
    _walletClient?.dispose();
    _walletClient =
        provider == null ? null : MoneroWalletClient(provider, network);
    _walletClient?.init();
  }

  Future<MoneroCachedBlockHeight> getHeight({bool refresh = false}) async {
    if (refresh || (_height?.needFetch ?? true)) {
      final h = await provider.request(DaemonRequestGetLastBlockHeader());
      _height = MoneroCachedBlockHeight(h.blockHeader.height);
    }
    return _height!;
  }

  Future<void> _updateBalance(IMoneroAddress address, MoneroChain chain) async {
    final walletTransfers = await MethodUtils.call(
        () async => _walletClient?.getAvailableTxes(address));
    if (walletTransfers.hasResult) {
      final relatedTxes = walletTransfers.result;
      if (relatedTxes != null) {
        await chain.updatePendingTxes(relatedTxes);
      }
    }
  }

  @override
  Future<void> updateBalance(
      IMoneroAddress address, APPCHAINACCOUNT<IMoneroAddress> chain) async {
    await _updateBalance(address, chain.cast());
    await updateAccountUtxos(address: address, account: chain.cast());
  }

  Future<DaemonGetBlocksByHeightResponse> getBlockByRange(
      int start, int end) async {
    final List<int> heights = List.generate(end - start, (i) => start + i);
    if (heights.isEmpty) {
      heights.add(start);
    }
    final blocks =
        await provider.request(DaemonRequestGetBlocksByHeightBin(heights));
    if (blocks.blocks.length != heights.length) {
      throw const WalletException("invalid_daemon_repsone");
    }
    return blocks;
  }

  Future<List<int>> getBlocksByRangeBinary(int start) async {
    final genesis = await getGenesisBlockHash();
    final blocks = await provider.requestBinary(
        DaemonRequestGetBlocksBin(
            startHeight: start,
            requestedInfo: DaemonRequestBlocksInfo.blocksOnly,
            blockIds: [genesis]),
        timeout: const Duration(minutes: 2));
    return blocks;
  }

  Future<List<DaemonBlockHeaderResponse>> getBlockHeadersRange(
      {required int start,
      required int end,
      bool validateResponse = true}) async {
    final r = await provider.request(
        DaemonRequestGetBlockHeaderByRange(startHeight: start, endHeight: end));
    if (validateResponse && r.headers.length != (end - start) + 1) {
      throw const WalletException("invalid_daemon_repsone");
    }
    return r.headers;
  }

  Future<DaemonGetEstimateFeeResponse> getFeeEstimate() async {
    final result = await provider.request(const DaemonRequestGetFeeEstimate(
        MoneroNetworkConst.feeEstimateGraceBlocks));
    return result;
  }

  Future<String> getGenesisBlockHash() async {
    _genesis ??= await provider.request(DaemonRequestOnGetBlockHash(0));
    return _genesis!;
  }

  Future<List<TxResponse>> _getTxes(
      {required List<String> txIds, bool validateResponse = true}) async {
    final rParams = DaemonRequestGetTransactions(txIds,
        prune: false, decodeAsJson: false, split: false);
    final result = await provider.request(rParams);
    if (validateResponse && rParams.txHashes.length != result.length) {
      throw const WalletException("some_transaction_missing");
    }
    return result;
  }

  Future<MoneroTransaction> getTx(String txId) async {
    final rParams = DaemonRequestGetTransactions([txId],
        prune: false, decodeAsJson: false, split: false);
    final result = await provider.request(rParams);
    if (rParams.txHashes.length != result.length) {
      throw const WalletException("transaction_not_found");
    }
    return result[0].toTx();
  }

  Future<List<MoneroFetchTxIdsResponse>> getTxes(
      {required List<MoneroAccountPendingTxes> txIds,
      bool validateResponse = true}) async {
    final rParams = DaemonRequestGetTransactions(
        txIds.expand((e) => e.txIDs).toList(),
        prune: false,
        decodeAsJson: false,
        split: false);
    final result = await provider.request(rParams);
    if (validateResponse && rParams.txHashes.length != result.length) {
      throw const WalletException("some_transaction_missing");
    }
    int offset = 0;
    return List.generate(txIds.length, (i) {
      final txesLen = txIds[i].txIDs.length;
      try {
        return MoneroFetchTxIdsResponse(
            txes: result
                .sublist(offset, offset + txesLen)
                .map((e) => MoneroTxInfo(
                    txId: e.txHash,
                    txHex: e.txHex,
                    globalIndices: e.outoutIndices,
                    confirmations: e.confirmations ?? 0))
                .toList(),
            primaryAddress: txIds[i].primaryAddress);
      } finally {
        offset += txesLen;
      }
    });
  }

  Future<DaemonIsKeyImageSpentResponse> keyImagesStatus(List<String> keyImages,
      {bool validateResponse = true}) async {
    final result =
        await provider.request(DaemonRequestIsKeyImageSpent(keyImages));
    if (validateResponse && result.spentStatus.length != keyImages.length) {
      throw const DartMoneroPluginException("invalid_daemon_repsone");
    }
    return result;
  }

  Future<List<MoneroUpdatePaymentRequest>> updatePaymentsStatus(
      List<MoneroUpdatePaymentRequest> payments) async {
    final List<MoneroOutputDetails> unknownPayments = payments
        .expand((e) => e.payments)
        .where((e) => e.status.isUnknown)
        .toList();
    if (unknownPayments.isEmpty) {
      return payments;
    }
    final keyImages = unknownPayments.map((e) => e.keyImage).toList();
    final status = await keyImagesStatus(keyImages);
    for (int i = 0; i < unknownPayments.length; i++) {
      unknownPayments[i].updatePaymentStatus(status: status.spentStatus[i]);
    }
    return payments;
  }

  Future<void> updateAccountUtxos(
      {required IMoneroAddress address, required MoneroChain account}) async {
    final utxos = account.getUtxos(address.addrDetails.viewKey);
    if (utxos.isEmpty) return;
    final keyImages = utxos.map((e) => e.keyImage).toList();
    final status = await keyImagesStatus(keyImages);
    for (int i = 0; i < keyImages.length; i++) {
      utxos[i].updatePaymentStatus(status: status.spentStatus[i]);
    }

    final updateRequired = utxos.where((e) => e.needUpdate).toList();
    if (updateRequired.isNotEmpty) {
      final txes =
          await _getTxes(txIds: updateRequired.map((e) => e.txId).toList());
      for (int i = 0; i < txes.length; i++) {
        final tx = txes[i];
        final utxo = updateRequired[i];
        if (!utxo.hasGlobalIndex) {
          utxo.updateIndices(tx.outoutIndices);
        }
        utxo.updateConfrimation(tx.confirmations ?? 0);
      }
    }
    await account.updateAddressUtxos(outs: utxos, address: address);
  }

  Future<List<int>> getBinaryAbsoluteDistribution() async {
    final distributions = await provider.requestBinary(
        DaemonRequestGetOutputDistributionBin(
            amounts: [BigInt.zero], compress: true, cumulative: false));
    return distributions;
  }

  Future<GetOutResponse> getOuts(
      List<DaemonGetOutRequestParams> outputs) async {
    final outs = await provider
        .request(DaemonRequestGetOuts(outputs: outputs, getTxId: false));
    return outs;
  }

  Future<List<SpendablePayment<T>>>
      generatePaymentOutputs<T extends MoneroPayment>(
          {required List<T> payments,
          int fakeOutsLength = 15,
          required List<BigInt> outKeysRequestOrder,
          required List<BigInt> outKeysRequests}) async {
    if (fakeOutsLength <= 0) {
      throw const DartMoneroPluginException(
          "fake outs length should be greather than zero.");
    }
    final List<List<OutsEntery>> outs = [];
    final int baseRequestCount = ((fakeOutsLength + 1) * 1.5 + 1).ceil();
    final List<OutKeyResponse> outKeysResponse = [];
    int offset = 0;
    while (offset < outKeysRequests.length) {
      const int size = 1000;
      final int outChunSize =
          IntUtils.min(outKeysRequests.length - offset, size);
      final List<DaemonGetOutRequestParams> chunkRequest = List.generate(
          outChunSize,
          (i) => DaemonGetOutRequestParams(
              amount: BigInt.zero, index: outKeysRequests[offset + i]));
      offset += size;
      final outs = await getOuts(chunkRequest);
      outKeysResponse.addAll(outs.outs);
    }
    int base = 0;
    for (final payment in payments) {
      const defaultOutCount =
          MoneroNetworkConst.cryptonoteMinedMoneyUnlockWindow -
              MoneroNetworkConst.cryptonoteDefaultTxSpendableAge;
      final int outputsCount = baseRequestCount + defaultOutCount;
      final List<OutsEntery> out = [];
      final mask = RCT.commit(
          xmrAmount: payment.output.amount, mask: payment.output.mask);
      bool hasRealOut = false;
      for (int n = 0; n < outputsCount; ++n) {
        final int i = base + n;
        if (outKeysRequests[i] == payment.globalIndex) {
          if (BytesUtils.bytesEqual(
              outKeysResponse[i].key, payment.output.outputPublicKey)) {
            if (BytesUtils.bytesEqual(outKeysResponse[i].mask, mask)) {
              if (outKeysResponse[i].unlocked) {
                hasRealOut = true;
              }
            }
          }
        }
      }
      if (!hasRealOut) {
        throw const DartMoneroPluginException(
            "Daemon response did not include the requested real output");
      }
      out.add(OutsEntery(
          index: payment.globalIndex,
          key: CtKey(dest: payment.output.outputPublicKey, mask: mask)));

      for (int idx = base;
          idx < base + outputsCount && out.length < fakeOutsLength + 1;
          ++idx) {
        final attemptedOutput = outKeysRequestOrder[idx];
        int i;
        for (i = base; i < base + outputsCount; ++i) {
          if (outKeysRequests[i] == attemptedOutput) {
            break;
          }
        }
        if (i == base + outputsCount) {
          throw const DartMoneroPluginException(
              "Could not find index of picked output in requested outputs");
        }
        final fakeOutResponse = outKeysResponse[i];
        final fakeOutRequest = outKeysRequests[i];
        final fakeEntry = OutsEntery(
            index: fakeOutRequest,
            key: CtKey(dest: fakeOutResponse.key, mask: fakeOutResponse.mask));
        if (fakeOutResponse.unlocked &&
            fakeOutRequest != payment.globalIndex &&
            !out.contains(fakeEntry)) {
          out.add(fakeEntry);
        }
      }
      out.sort((a, b) => a.index.compareTo(b.index));
      outs.add(out);
      if (out.length < fakeOutsLength + 1) {
        throw const DartMoneroPluginException("not enough outs to mix.");
      }

      base += outputsCount;
    }
    return List.generate(payments.length, (i) {
      final payment = payments[i];
      final sourceOuts = outs[i];
      final index =
          sourceOuts.indexWhere((e) => e.index == payment.globalIndex);
      if (index.isNegative) {
        throw const DartMoneroPluginException("Index not found.");
      }
      return SpendablePayment<T>(
          payment: payment, outs: sourceOuts, realOutIndex: index);
    });
  }

  Future<void> sendTx(String txHex,
      {bool doNotRelay = false, bool doSanityChecks = true}) async {
    await provider.request(DaemonRequestSendRawTransaction(
        txAsHex: txHex,
        doNotRelay: doNotRelay,
        doSanityChecks: doSanityChecks));
  }

  Future<bool> validateNetworkGenesis() async {
    final gnesis = await getGenesisBlockHash();
    return gnesis == network?.genesisBlock;
  }

  @override
  Future<bool> onInit() async {
    await getHeight();
    return validateNetworkGenesis();
  }

  @override
  NetworkType get networkType => NetworkType.monero;
}

class MoneroWalletClient
    extends NetworkClient<IMoneroAddress, MoneroAPIProvider>
    with CryptoWokerImpl {
  final MoneroProvider provider;
  List<MoneroWalletRPCAccounts>? _walletAccounts;
  MoneroWalletClient(MoneroAPIProvider provider, this.network)
      : provider = MoneroProvider(MoneroHTTPService(provider));

  @override
  WalletMoneroNetwork? network;

  @override
  MoneroHTTPService get service => provider.rpc as MoneroHTTPService;

  Future<MoneroAccountPendingTxes?> getAvailableTxes(
      IMoneroAddress address) async {
    _walletAccounts ??= await readMoneroWalletAdresses();
    MoneroWalletRPCAddress? index;
    for (final i in _walletAccounts!) {
      index = i.addresses
          .firstWhereOrNull((e) => e.address == address.networkAddress);
      if (index != null) break;
    }
    if (index == null) return null;
    final txes = await readMoneroWalletTxes([index]);
    return MoneroAccountPendingTxes(
        txIDs: txes.map((e) => e.txHash).toSet().toList(),
        primaryAddress: address.addrDetails.primaryAccount());
  }

  @override
  Future<void> updateBalance(
      IMoneroAddress address, APPCHAINACCOUNT<IMoneroAddress> chain) async {
    throw UnimplementedError();
  }

  Future<WalletRPCGetAccountsResponse> readMoneroWalletAccounts() async {
    return provider.request(WalletRequestGetAccounts());
  }

  Future<List<MoneroWalletRPCAccounts>> readMoneroWalletAdresses() async {
    final accounts = await readMoneroWalletAccounts();
    final List<MoneroWalletRPCAccounts> existsAccounts = [];
    for (final i in accounts.subaddressAccounts) {
      final addresses = await provider
          .request(WalletRequestGetAddress(accountIndex: i.accountIndex));
      existsAccounts.add(MoneroWalletRPCAccounts(
          primary: i.baseAddress,
          addresses: addresses.addresses
              .map((e) => MoneroWalletRPCAddress(
                    address: e.address,
                    addressIndex: e.addressIndex,
                    accountIndex: i.accountIndex,
                  ))
              .toList()));
    }
    return existsAccounts;
  }

  Future<List<WalletRPCIncommingTransferResponse>> readMoneroWalletTxes(
      List<MoneroWalletRPCAddress> accountsIndexes) async {
    final List<WalletRPCIncommingTransferResponse> availableTransfers = [];
    final idexes = accountsIndexes.map((e) => e.accountIndex).toSet();
    for (final i in idexes) {
      final subaddrIndices = accountsIndexes
          .where((e) => e.accountIndex == i)
          .map((e) => e.addressIndex)
          .toList();
      final r = await provider.request(WalletRequestIncommingTransfers(
          transferType: IncommingTransferType.available,
          accountIndex: i,
          subaddrIndices: subaddrIndices));
      availableTransfers.addAll(r);
    }
    return availableTransfers;
  }

  @override
  Future<bool> onInit() async {
    _walletAccounts = await readMoneroWalletAdresses();
    return super.onInit();
  }

  @override
  NetworkType get networkType => NetworkType.monero;
}

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/binary/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/bitcoin_state_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/bitcoin/bitcoin_multi_sig_core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/networks/bitcoin/core/core.dart';
import 'package:mrt_wallet/types/typedef.dart';

import 'memo_impl.dart';

enum TransactionOrdering {
  bip69("bip_69_desc"),
  shuffle("shuffle_desc"),
  none("none_ordering_transaction_desc"),
  manually("manually_ordering_transaction_desc");

  const TransactionOrdering(this.desc);
  final String desc;

  BitcoinOrdering get ordering {
    switch (this) {
      case TransactionOrdering.none:
      case TransactionOrdering.manually:
        return BitcoinOrdering.none;
      case TransactionOrdering.shuffle:
        return BitcoinOrdering.shuffle;
      default:
        return BitcoinOrdering.bip69;
    }
  }
}

enum BitcoinTransactionPages { account, utxo, send }

abstract class BitcoinTransactionImpl extends StateController
    with BitcoinTransactionMemoImpl {
  BitcoinTransactionImpl({
    required this.walletProvider,
    required this.chainAccount,
  });
  bool get hasFeeRate;
  late IBitcoinAddress _onChangeAddress =
      chainAccount.account.address as IBitcoinAddress;
  String get onChangeAddressView => _onChangeAddress.address.toAddress;
  BitcoinBaseAddress get onChangeAddress => _onChangeAddress.networkAddress;
  BigInt get minimumOutput =>
      isBCHTransaction ? BitcoinCashUtils.minimumOutput : BigInt.zero;
  Future<void> estimateFee({
    required List<BitcoinBaseOutput> outPuts,
    required List<UtxoWithAddress> inputs,
    BCMR? bcmr,
  });

  final List<BitcoinUtxoWithBalance> selectedUtxo = [];
  int _utxosCount = 0;
  void countUtxos() {
    _utxosCount = 0;
    for (final i in accountsUtxos) {
      _utxosCount += i.utxosWithBalance?.length ?? 0;
    }
  }

  TransactionOrdering _ordering = TransactionOrdering.bip69;
  TransactionOrdering get ordering => _ordering;

  List<UtxoWithAddress> inputs = [];
  void buildInputs() {
    inputs = List.unmodifiable(selectedUtxo
        .map((e) => UtxoWithAddress(utxo: e.utxo, ownerDetails: e.address))
        .toList());
  }

  List<BitcoinBaseOutput> outputs = [];

  void buildOutputs([List<BitcoinBaseOutput> extraOutputs = const []]) {
    outputs = List<BitcoinBaseOutput>.unmodifiable([
      ...extraOutputs,
      ...receivers
          .map<BitcoinBaseOutput>((e) => BitcoinOutput(
              address: e.address.networkAddress, value: e.balance.balance))
          .toList(),
      if (remindAmount.balance > BigInt.zero)
        BitcoinOutput(address: onChangeAddress, value: remindAmount.balance),
      ...memoScripts.map((e) => e.script).toList()
    ]);
    if (_ordering == TransactionOrdering.manually) {
      _ordering = TransactionOrdering.bip69;
      notify();
    }
  }

  void changeAccount(CryptoAccountAddress? change) {
    if (change == null || !addresses.contains(change)) return;
    change as IBitcoinAddress;
    _onChangeAddress = change;
    buildOutputs();
    calculateFee();
  }

  bool get haveUtxos => _utxosCount > 0;
  bool get canBuildTransaction => selectedUtxo.isNotEmpty;
  bool get allUtxosSelected => selectedUtxo.length == _utxosCount;
  bool utxoSelected(BitcoinUtxoWithBalance utxo) => selectedUtxo.contains(utxo);

  final WalletProvider walletProvider;
  final AppChain chainAccount;
  late final NoneDecimalBalance remindAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late final NoneDecimalBalance setupAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  AppBitcoinNetwork get network => chainAccount.network as AppBitcoinNetwork;
  late final NoneDecimalBalance spendableAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  final Map<String, BitcoinOutputWithBalance> _receivers = {};
  List<BitcoinOutputWithBalance> get receivers => _receivers.values.toList();
  bool get hasOutput => _receivers.isNotEmpty;

  void _updateUtxosAmount() {
    BigInt sum = BigInt.zero;
    for (final i in selectedUtxo) {
      sum += i.balance.balance;
    }
    spendableAmount.updateBalance(sum);
  }

  void selectAllUtxos() {
    if (allUtxosSelected) {
      selectedUtxo.clear();
    } else {
      for (final a in accountsUtxos) {
        for (final u in a.utxosWithBalance ?? <BitcoinUtxoWithBalance>[]) {
          if (selectedUtxo.contains(u)) continue;
          selectedUtxo.add(u);
        }
      }
    }
    _updateUtxosAmount();
    notify();
  }

  void addUtxo(BitcoinUtxoWithBalance utxo) {
    final bool remove = selectedUtxo.remove(utxo);
    if (!remove) {
      selectedUtxo.add(utxo);
    }
    _updateUtxosAmount();
    notify();
  }

  void onSetupUtxo();
  List<IBitcoinAddress> get addresses => chainAccount.account.addresses.cast();
  NetworkAccountCore get account => chainAccount.account;
  late final BasedBitcoinApiProvider apiProvider = chainAccount.provider()!;

  void setFee(String? feeType, {BigInt? customFee}) {
    onCalculateAmount();
    notify();
  }

  void onCalculateAmount();

  NoneDecimalBalance get transactionFee;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "BitcoinTransactionPages");
  late final bool isBCHTransaction =
      chainAccount.network is AppBitcoinCashNetwork;
  late final NoneDecimalBalance sumOfSelectedUtxo =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  bool _rbf = false;
  bool get rbf => _rbf;
  void toggleRbf(bool onChanged) {
    _rbf = !_rbf;
    notify();
  }

  ///up

  BitcoinTransactionPages _page = BitcoinTransactionPages.account;
  bool get canPopPage =>
      progressKey.status == StreamWidgetStatus.success ||
      _page == BitcoinTransactionPages.account;
  BitcoinTransactionPages get page => _page;
  bool get inAccountPage => _page == BitcoinTransactionPages.account;
  bool get inUtxoPage => _page == BitcoinTransactionPages.utxo;
  bool get inSendPage => _page == BitcoinTransactionPages.send;

  bool onBackButtom() {
    if (progressKey.status == StreamWidgetStatus.success) {
      return true;
    }
    try {
      switch (_page) {
        case BitcoinTransactionPages.account:
          return true;
        case BitcoinTransactionPages.utxo:
          _page = BitcoinTransactionPages.account;
          break;
        default:
          _page = BitcoinTransactionPages.utxo;
          break;
      }
      return false;
    } finally {
      notify();
    }
  }

  final GlobalKey<StreamWidgetState> updateBalancessKey =
      GlobalKey<StreamWidgetState>(debugLabel: "updateBalancessKey");

  final Map<String, UtxoAddressDetails> _addresses = {};
  final Map<String, BItcoinAccountUtxos> _accountsUtxos = {};

  List<BItcoinAccountUtxos> get accountsUtxos => _accountsUtxos.values.toList();
  final Map<String, BItcoinAccountUtxos> _retrievedUtxos = {};
  bool addressSelected(String addressProgram) =>
      _addresses.containsKey(addressProgram);
  bool get hasSpender => _addresses.isNotEmpty;
  void addAccount(IBitcoinAddress account) {
    final address = account.networkAddress.addressProgram;

    if (_addresses.containsKey(address)) {
      _addresses.remove(address);
    } else {
      if (account.multiSigAccount) {
        final multiSignatureAddress =
            (account as BitcoinMultiSigBase).multiSignatureAddress;

        _addresses.addAll({
          address: UtxoAddressDetails.multiSigAddress(
              address: account.networkAddress,
              multiSigAddress: multiSignatureAddress)
        });
      } else {
        _addresses.addAll({
          address: UtxoAddressDetails(
              address: account.networkAddress,
              publicKey: BytesUtils.toHexString(account.publicKey))
        });
      }
    }
    notify();
  }

  void fetchUtxos([bool includeTokenUtxos = false]) async {
    progressKey.progressText("retrieving_transaction".tr);
    _accountsUtxos.clear();
    selectedUtxo.clear();
    bool hasError = false;
    for (final i in _addresses.keys) {
      if (_retrievedUtxos[i]?.hasUtxo ?? false) {
        _accountsUtxos[i] = _retrievedUtxos[i]!;
        continue;
      }
      final result = await MethodCaller.call(() async {
        return await apiProvider.readUtxos(_addresses[i]!, includeTokenUtxos);
      });
      if (result.hasError) {
        hasError = true;
      }
      _retrievedUtxos[i] = BItcoinAccountUtxos(
          address: i,
          utxos: result.hasError ? null : result.result,
          addressDetails: _addresses[i]!,
          network: network);
      _accountsUtxos[i] = _retrievedUtxos[i]!;
    }
    countUtxos();
    _page = BitcoinTransactionPages.utxo;
    if (hasError) {
      progressKey.errorText("problem_when_receiving_utxos".tr);
    } else {
      progressKey.successText("transaction_successfully_received".tr);
    }
  }

  void updateBalances() async {
    if (updateBalancessKey.inProgress) return;
    updateBalancessKey.process();
    await walletProvider.updateAccountBalance();
    updateBalancessKey.success();
    notify();
  }

  void onAddRecever(
      ReceiptAddress<BitcoinBaseAddress>? addr, DynamicVoid onAccountExists) {
    if (addr == null) return;
    if (_receivers.containsKey(addr.networkAddress.addressProgram)) {
      onAccountExists();
      return;
    } else {
      _receivers[addr.networkAddress.addressProgram] =
          BitcoinOutputWithBalance(address: addr, network: network);
    }
    buildOutputs();
    calculateFee();
  }

  void removeReceiver(ReceiptAddress<BitcoinBaseAddress>? addr) {
    if (addr == null) return;
    final re = _receivers.remove(addr.networkAddress.addressProgram);
    onCalculateAmount();
    if (re != null) {
      calculateFee();
    }
  }

  void setupAccountAmount(String address, BigInt? amount) async {
    if (amount == null) return;
    _receivers[address]?.balance.updateBalance(amount);
    bool isMax = amount == remindAmount.balance;
    onCalculateAmount();
    if (isMax) {
      await calculateFee();
      final fixedAmount = amount + remindAmount.balance;
      _receivers[address]?.balance.updateBalance(fixedAmount);
      onCalculateAmount();
    }
    notify();
  }

  void onChangeOrdering(
      TransactionOrdering? ordering, OnCustomOrdering custom) async {
    try {
      if (ordering == null) return;
      if (ordering == TransactionOrdering.manually) {
        final ordered = await custom(inputs, outputs);
        if (ordered == null) return;
        inputs = ordered.$1;
        outputs = ordered.$2;
      }
      _ordering = ordering;
    } finally {
      notify();
    }
  }

  Future<void> calculateFee() async {
    if (!hasFeeRate || page != BitcoinTransactionPages.send) {
      progressKey.progressText("processing_fee_please_wait".tr);
    }

    final result = await MethodCaller.call(() async {
      return estimateFee(outPuts: outputs, inputs: inputs);
    });
    onCalculateAmount();
    if (progressKey.inProgress) {
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        _page = BitcoinTransactionPages.send;
        progressKey.successText("transaction_fee_has_been_modified".tr);
      }
    }
    notify();
  }

  @override
  Future<void> onTapMemo(FutureNullString onAdd) async {
    final currentMemo = memoScripts.length;
    await super.onTapMemo(onAdd);
    if (currentMemo != memoScripts.length) {
      buildOutputs();
      calculateFee();
    }
  }

  @override
  void onRemoveMemo(BitcoinMemo? memo) {
    if (!memoScripts.contains(memo)) return;
    super.onRemoveMemo(memo);
    buildOutputs();
    calculateFee();
  }

  BasedBitcoinTransacationBuilder _buildTransaction() {
    if (isBCHTransaction) {
      return ForkedTransactionBuilder(
          outPuts: outputs,
          fee: transactionFee.balance,
          inputOrdering: ordering.ordering,
          outputOrdering: ordering.ordering,
          network: network.coinParam.transacationNetwork as BitcoinCashNetwork,
          utxos: inputs,
          enableRBF: rbf);
    }
    return BitcoinTransactionBuilder(
        outPuts: outputs,
        fee: transactionFee.balance,
        network: network.coinParam.transacationNetwork,
        inputOrdering: ordering.ordering,
        outputOrdering: ordering.ordering,
        utxos: inputs,
        enableRBF: rbf);
  }

  void sendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      final List<IBitcoinAddress> signers = [];
      for (final i in selectedUtxo) {
        try {
          final IBitcoinAddress utxosAcount = addresses.firstWhere((element) =>
              element.networkAddress.addressProgram ==
              i.address.address.addressProgram);
          signers.add(utxosAcount);
        } catch (e) {
          rethrow;
        }
      }
      final tr = _buildTransaction();
      final signedTr = await walletProvider.signBitcoinTransaction(
          request: BitcoinSigningRequest(
              addresses: signers, network: network, transaction: tr));
      if (signedTr.hasError) {
        throw signedTr.exception!;
      }
      final ser = signedTr.result.serialize();

      return await apiProvider.sendTransacation(ser);
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txId: result.result.toString(),
          ),
          backToIdle: false);
    }
    notify();
  }
}

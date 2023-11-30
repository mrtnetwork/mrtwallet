import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/types/typedef.dart';

enum BitcoinTransactionPages { account, utxo, receiver, send }

class BitcoinStateController extends StateController {
  BitcoinStateController(this._walletProvider);

  Future<bool> onBackButtom() async {
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
        case BitcoinTransactionPages.receiver:
          _page = BitcoinTransactionPages.utxo;
          break;
        default:
          _page = BitcoinTransactionPages.receiver;
          break;
      }
      return false;
    } finally {
      notify();
    }
  }

  final WalletProvider _walletProvider;
  List<IBitcoinAddress> get addresses =>
      _walletProvider.networkAccount.addresses.cast();

  AppBitcoinNetwork get network => _walletProvider.network as AppBitcoinNetwork;
  late final BitcoinApiProvider _apiProvider =
      _walletProvider.getNetworkApiProvider(network);

  late BitcoinAddress _onChangeAddress;
  late String _onChangeAddressView;
  String get onChangeAddressView => _onChangeAddressView;
  BitcoinAddress get onChangeAddress => _onChangeAddress;

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "BitcoinTransactionPages");
  final GlobalKey<StreamWidgetState> updateBalancessKey =
      GlobalKey<StreamWidgetState>(debugLabel: "updateBalancessKey");
  void updateBalances() async {
    if (updateBalancessKey.inProgress) return;
    updateBalancessKey.process();
    await _walletProvider.updateAccountBalance();
    updateBalancessKey.success();
    notify();
  }

  final Map<String, UtxoAddressDetails> _addresses = {};
  bool get canSpend => _addresses.isNotEmpty;
  final Map<String, BItcoinAccountUtxos> _fetchedUtxos = {};
  List<BItcoinAccountUtxos> get utxos => _fetchedUtxos.values.toList();
  int _utxosCount = 0;

  BitcoinTransactionPages _page = BitcoinTransactionPages.account;
  bool get inAccountPage => _page == BitcoinTransactionPages.account;
  bool get inUtxoPage => _page == BitcoinTransactionPages.utxo;
  bool get inReceiverPage => _page == BitcoinTransactionPages.receiver;
  bool get inSendPage => _page == BitcoinTransactionPages.send;
  bool addressSelected(String address) => _addresses.containsKey(address);

  final List<BitcoinUtxoWithBalance> _selectedUtxo = [];
  bool get canBuildTransaction => _selectedUtxo.isNotEmpty;
  bool utxoSelected(BitcoinUtxoWithBalance utxo) =>
      _selectedUtxo.contains(utxo);
  String? _memo;

  String? get memo => _memo;
  bool get hasMemo => _memo != null;

  void onTapMemo(FutureNullString onAdd) async {
    if (hasMemo) {
      _memo = null;
      moveToSend();
      return;
    }
    _memo = await onAdd();
    if (_memo != null) {
      moveToSend();
    }
  }

  void _updateUtxosAmount() {
    BigInt sum = BigInt.zero;
    for (final i in _selectedUtxo) {
      sum += i.balance.balance;
    }
    spendableAmount.updateBalance(sum);
  }

  void _selectOnChaangeAccounts() {
    if (_selectedUtxo.isNotEmpty) {
      _onChangeAddress = _selectedUtxo.first.address.address;
      _onChangeAddressView =
          _onChangeAddress.toAddress(network.coinParam.transacationNetwork);
    }
  }

  bool get allUtxosSelected => _selectedUtxo.length == _utxosCount;
  void selectAll() {
    if (allUtxosSelected) {
      _selectedUtxo.clear();
    } else {
      for (final a in utxos) {
        for (final u in a.utxosWithBalance ?? <BitcoinUtxoWithBalance>[]) {
          if (_selectedUtxo.contains(u)) continue;
          _selectedUtxo.add(u);
        }
      }
    }
    _selectOnChaangeAccounts();
    _updateUtxosAmount();
    notify();
  }

  void addUtxo(BitcoinUtxoWithBalance utxo) {
    final bool remove = _selectedUtxo.remove(utxo);
    if (!remove) {
      _selectedUtxo.add(utxo);
    }
    if (_selectedUtxo.isNotEmpty) {
      _onChangeAddress = utxo.address.address;
      _onChangeAddressView =
          _onChangeAddress.toAddress(network.coinParam.transacationNetwork);
    }
    _updateUtxosAmount();
    notify();
  }

  bool get hasSpender => _addresses.isNotEmpty;
  void addAccount(IBitcoinAddress account) {
    final address = account.address.toAddress;
    final blanace = account.address.balance.value.balance;
    if (_addresses.containsKey(address)) {
      _addresses.remove(address);
    } else {
      if (blanace > BigInt.zero) {
        if (account.isMultiSigAccounts) {
          account as IBitcoinMultiSigAddress;
          _addresses.addAll({
            address: UtxoAddressDetails(
                address: account.bitcoinAddress,
                multiSigAddress: account.multiSignatureAddress)
          });
        } else {
          _addresses.addAll({
            address: UtxoAddressDetails(
                address: account.bitcoinAddress,
                publicKey: BytesUtils.toHexString(account.publicKey))
          });
        }
      }
    }
    notify();
  }

  void _countUtxos() {
    _utxosCount = 0;
    for (final i in utxos) {
      _utxosCount += i.utxosWithBalance?.length ?? 0;
    }
  }

  void fetchUtxos() async {
    progressKey.progressText("retrieving_transaction".tr);
    bool hasError = false;
    for (final i in _addresses.keys) {
      if (_fetchedUtxos[i]?.hasUtxo ?? false) continue;
      final result = await MethodCaller.call(() async {
        return await _apiProvider.readUtxos(_addresses[i]!);
      });
      if (result.hasError) {
        hasError = true;
      }
      _fetchedUtxos[i] = BItcoinAccountUtxos(
          address: i,
          utxos: result.hasError ? null : result.result,
          addressDetails: _addresses[i]!,
          network: network);
    }
    _countUtxos();
    _page = BitcoinTransactionPages.utxo;
    if (hasError) {
      progressKey.errorText("problem_when_receiving_utxos".tr);
    } else {
      progressKey.successText("transaction_successfully_received".tr);
    }
  }

  late final CurrencyBalance spendableAmount =
      CurrencyBalance.zero(network.coinParam.decimal);

  late final CurrencyBalance _sumOfSelectedUtxo =
      CurrencyBalance.zero(network.coinParam.decimal);
  CurrencyBalance get sumOfSelectedUtxo => _sumOfSelectedUtxo;
  void moveToReceiver() {
    final sum = _selectedUtxo.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    _sumOfSelectedUtxo.updateBalance(sum);
    if (sum <= BigInt.zero) return;
    _page = BitcoinTransactionPages.receiver;
    notify();
  }

  final Map<String, BitcoinOutputWithBalance> _receivers = {};
  List<BitcoinOutputWithBalance> get receivers => _receivers.values.toList();
  bool get hasOutput => _receivers.isNotEmpty;
  void onAddRecever(BitcoinAddress? addr) {
    if (addr == null) return;
    final toAddr = addr.toAddress(network.coinParam.transacationNetwork);
    if (_receivers.containsKey(toAddr)) {
      _receivers.remove(toAddr);
    } else {
      _receivers[toAddr] =
          BitcoinOutputWithBalance(address: addr, network: network);
    }
    notify();
  }

  BitcoinFeeRateType? _feeRateType = BitcoinFeeRateType.medium;

  BitcoinFeeRate? _networkFeeRate;
  BitcoinFeeRate get feeRate => _networkFeeRate!;
  late final CurrencyBalance _feeRate =
      CurrencyBalance.zero(network.coinParam.decimal);
  CurrencyBalance get transactionFee => _feeRate;
  BitcoinFeeRateType? get feeRateType => _feeRateType;

  void setFee(BitcoinFeeRateType? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _feeRateType = feeType;
    if (_feeRateType == null) {
      _feeRate.updateBalance(customFee!);
    } else {
      _feeRate.updateBalance(
          _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
    }
    _calculateSetupAmount();
    notify();
  }

  Future<BitcoinFeeRate> _getFeeRate() async {
    if (network == AppBitcoinNetwork.bitcoinTestnet) {
      final BitcoinApiProvider blockCypherApi =
          _walletProvider.getBitcoinNetworkApiProvider(network,
              provider: ApiProviderService.blockCypher);
      return blockCypherApi.provider.getNetworkFeeRate();
    }
    return _apiProvider.provider.getNetworkFeeRate();
  }

  int? _trSize;
  int get trSize => _trSize!;
  void moveToSend() async {
    if (_receivers.isEmpty) return;
    progressKey.progressText("processing_fee_please_wait".tr);

    final result = await MethodCaller.call(() async {
      _feeRateType ??= BitcoinFeeRateType.medium;

      _trSize = BitcoinTransactionBuilder.estimateTransactionSize(
          utxos: _selectedUtxo
              .map(
                  (e) => UtxoWithAddress(utxo: e.utxo, ownerDetails: e.address))
              .toList(),
          memo: _memo,
          enableRBF: true,
          outputs: _receivers.values.map((e) => e.address).toList(),
          network: network.coinParam.transacationNetwork);
      WalletLogging.print("end");
      if (_networkFeeRate == null) {
        _networkFeeRate = await _getFeeRate();
      } else {
        await MethodCaller.wait();
      }
      _networkFeeRate ??= await _getFeeRate();
      _feeRate.updateBalance(
          _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
      _calculateSetupAmount();
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      _page = BitcoinTransactionPages.send;
      progressKey.success();
    }
  }

  late final CurrencyBalance _remindAmount =
      CurrencyBalance.zero(network.coinParam.decimal);
  CurrencyBalance get remindAmount => _remindAmount;
  late final CurrencyBalance _setupAmount =
      CurrencyBalance.zero(network.coinParam.decimal);
  CurrencyBalance get setupAmout => _setupAmount;
  bool _trReady = false;
  bool get trReady => _trReady;
  bool _isReady() {
    return _receivers.isNotEmpty &&
        !_remindAmount.isNegative &&
        !_setupAmount.isZero;
  }

  void _calculateSetupAmount() {
    final totalAmounts = _receivers.values.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    _setupAmount.updateBalance(totalAmounts);
    final remind =
        _sumOfSelectedUtxo.balance - totalAmounts - transactionFee.balance;
    _remindAmount.updateBalance(remind);
    _trReady = _isReady();
  }

  void setupAccountAmount(String address, BigInt? amount) {
    if (amount == null) return;
    _receivers[address]?.balance.updateBalance(amount);
    _calculateSetupAmount();

    notify();
  }

  bool _rbf = false;
  bool get rbf => _rbf;
  void toggleRbf(bool onChanged) {
    _rbf = !_rbf;
    notify();
  }

  void sigTr() async {
    if (!trReady) return;
    progressKey.progressText("create_send_transaction".tr);
    final result = await MethodCaller.call(() async {
      final List<IBitcoinAddress> signers = [];
      for (final i in _selectedUtxo) {
        final IBitcoinAddress utxosAcount = addresses.firstWhere((element) =>
            element.address.toAddress ==
            i.address.address.toAddress(network.coinParam.transacationNetwork));
        signers.add(utxosAcount);
      }
      final List<BitcoinOutput> outputs = receivers
          .map((e) =>
              BitcoinOutput(address: e.address, value: e.balance.balance))
          .toList();
      if (_remindAmount.balance >= BigInt.zero) {
        outputs.add(BitcoinOutput(
            address: _onChangeAddress, value: _remindAmount.balance));
      }
      final tr = BitcoinTransactionBuilder(
          outPuts: outputs,
          fee: _feeRate.balance,
          network: network.coinParam.transacationNetwork,
          memo: _memo,
          utxos: _selectedUtxo
              .map(
                  (e) => UtxoWithAddress(utxo: e.utxo, ownerDetails: e.address))
              .toList(),
          enableRBF: _rbf);

      final signedTr = await _walletProvider.signBitcoinTransaction(
          builder: tr, accouts: signers);
      if (signedTr.hasError) {
        throw signedTr.exception!;
      }
      final ser = signedTr.result.serialize();

      return await _apiProvider.provider.sendRawTransaction(ser);
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
  }

  void changeAccount(CryptoAddress? change) {
    if (change == null || !addresses.contains(change)) return;
    change as IBitcoinAddress;
    _onChangeAddress = change.bitcoinAddress;
    _onChangeAddressView = change.address.toAddress;
    notify();
  }

  @override
  String get repositoryId => "bitcoin";
}

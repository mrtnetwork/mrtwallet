import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/types/typedef.dart';

enum BitcoinTransactionPages { account, utxo, receiver, send }

class BitcoinStateController extends BitcoinTransactionImpl
    with BitcoinTransactionMemoImpl, BitcoinTransactionFeeImpl {
  BitcoinStateController(
      {required super.chainAccount, required super.walletProvider});
  late BitcoinAddress _onChangeAddress;
  late String _onChangeAddressView;
  String get onChangeAddressView => _onChangeAddressView;
  BitcoinAddress get onChangeAddress => _onChangeAddress;
  final GlobalKey<StreamWidgetState> updateBalancessKey =
      GlobalKey<StreamWidgetState>(debugLabel: "updateBalancessKey");
  final Map<String, UtxoAddressDetails> _addresses = {};
  bool get canSpend => _addresses.isNotEmpty;
  final Map<String, BItcoinAccountUtxos> _fetchedUtxos = {};
  List<BItcoinAccountUtxos> get utxos => _fetchedUtxos.values.toList();
  int _utxosCount = 0;

  BitcoinTransactionPages _page = BitcoinTransactionPages.account;
  bool get canPopPage =>
      progressKey.status == StreamWidgetStatus.success ||
      _page == BitcoinTransactionPages.account;
  bool get inAccountPage => _page == BitcoinTransactionPages.account;
  bool get inUtxoPage => _page == BitcoinTransactionPages.utxo;
  bool get inReceiverPage => _page == BitcoinTransactionPages.receiver;
  bool get inSendPage => _page == BitcoinTransactionPages.send;
  bool addressSelected(String address) => _addresses.containsKey(address);

  final List<BitcoinUtxoWithBalance> _selectedUtxo = [];
  bool get canBuildTransaction => _selectedUtxo.isNotEmpty;
  bool get haveUtxos => _utxosCount > 0;
  bool get allUtxosSelected => _selectedUtxo.length == _utxosCount;
  bool utxoSelected(BitcoinUtxoWithBalance utxo) =>
      _selectedUtxo.contains(utxo);
  final Map<String, BitcoinOutputWithBalance> _receivers = {};
  List<BitcoinOutputWithBalance> get receivers => _receivers.values.toList();
  bool get hasOutput => _receivers.isNotEmpty;

  late final NoneDecimalBalance _remindAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  NoneDecimalBalance get remindAmount => _remindAmount;
  late final NoneDecimalBalance _setupAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  NoneDecimalBalance get setupAmout => _setupAmount;
  bool _trReady = false;
  bool get trReady => _trReady;
  bool _rbf = false;
  bool get rbf => _rbf;

  late final NoneDecimalBalance spendableAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late final NoneDecimalBalance _sumOfSelectedUtxo =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  NoneDecimalBalance get sumOfSelectedUtxo => _sumOfSelectedUtxo;
  bool get hasSpender => _addresses.isNotEmpty;

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

  void updateBalances() async {
    if (updateBalancessKey.inProgress) return;
    updateBalancessKey.process();
    await walletProvider.updateAccountBalance();
    updateBalancessKey.success();
    notify();
  }

  @override
  Future<void> onTapMemo(FutureNullString onAdd) async {
    final currentMemo = memo;
    await super.onTapMemo(onAdd);
    if (currentMemo != memo) {
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

  void addAccount(IBitcoinAddress account) {
    final address = account.address.toAddress;
    final blanace = account.address.balance.value.balance;
    final bool canSpend = blanace > BigInt.zero;

    if (_addresses.containsKey(address)) {
      _addresses.remove(address);
    } else {
      if (canSpend) {
        if (account.multiSigAccount) {
          account as IBitcoinMultiSigAddress;
          _addresses.addAll({
            address: UtxoAddressDetails.multiSigAddress(
                address: account.networkAddress,
                multiSigAddress: account.multiSignatureAddress)
          });
        } else {
          _addresses.addAll({
            address: UtxoAddressDetails(
                address: account.networkAddress,
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

  @override
  void setFee(BitcoinFeeRateType? feeType, {BigInt? customFee}) {
    super.setFee(feeType, customFee: customFee);
    onCalculateAmount();
    notify();
  }

  void moveToSend() async {
    if (_receivers.isEmpty) return;
    progressKey.progressText("processing_fee_please_wait".tr);
    final result = await MethodCaller.call(() async {
      return calculateFee(receivers: _receivers, utxos: _selectedUtxo);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      _page = BitcoinTransactionPages.send;
      progressKey.success();
    }
  }

  void fetchUtxos() async {
    progressKey.progressText("retrieving_transaction".tr);
    bool hasError = false;
    for (final i in _addresses.keys) {
      if (_fetchedUtxos[i]?.hasUtxo ?? false) continue;
      final result = await MethodCaller.call(() async {
        return await apiProvider.readUtxos(_addresses[i]!);
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

  void moveToReceiver() {
    final sum = _selectedUtxo.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    _sumOfSelectedUtxo.updateBalance(sum);
    if (sum <= BigInt.zero) return;
    _page = BitcoinTransactionPages.receiver;
    notify();
  }

  void onAddRecever(ReceiptAddress<BitcoinAddress>? addr) {
    if (addr == null) return;
    final toAddr =
        addr.networkAddress.toAddress(network.coinParam.transacationNetwork);
    if (_receivers.containsKey(toAddr)) {
      _receivers.remove(toAddr);
    } else {
      _receivers[toAddr] =
          BitcoinOutputWithBalance(address: addr, network: network);
    }
    notify();
  }

  bool _isReady() {
    return _receivers.isNotEmpty &&
        !_remindAmount.isNegative &&
        !_setupAmount.isZero;
  }

  @override
  void onCalculateAmount() {
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
    onCalculateAmount();

    notify();
  }

  void toggleRbf(bool onChanged) {
    _rbf = !_rbf;
    notify();
  }

  void sendTransaction() async {
    if (!trReady) return;
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodCaller.call(() async {
      final List<IBitcoinAddress> signers = [];
      for (final i in _selectedUtxo) {
        final IBitcoinAddress utxosAcount = addresses.firstWhere((element) =>
            element.address.toAddress ==
            i.address.address.toAddress(network.coinParam.transacationNetwork));
        signers.add(utxosAcount);
      }
      final List<BitcoinOutput> outputs = receivers
          .map((e) => BitcoinOutput(
              address: e.address.networkAddress, value: e.balance.balance))
          .toList();
      if (_remindAmount.balance >= BigInt.zero) {
        outputs.add(BitcoinOutput(
            address: _onChangeAddress, value: _remindAmount.balance));
      }
      final tr = BitcoinTransactionBuilder(
          outPuts: outputs,
          fee: transactionFee.balance,
          network: network.coinParam.transacationNetwork,
          memo: memo,
          utxos: _selectedUtxo
              .map(
                  (e) => UtxoWithAddress(utxo: e.utxo, ownerDetails: e.address))
              .toList(),
          enableRBF: _rbf);

      final signedTr = await walletProvider.signBitcoinTransaction(
          request: BitcoinSigningRequest(
              addresses: signers, network: network, transaction: tr));
      if (signedTr.hasError) {
        throw signedTr.exception!;
      }
      final ser = signedTr.result.serialize();

      return await apiProvider.provider.sendRawTransaction(ser);
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

  void changeAccount(CryptoAccountAddress? change) {
    if (change == null || !addresses.contains(change)) return;
    change as IBitcoinAddress;
    _onChangeAddress = change.networkAddress;
    _onChangeAddressView = change.address.toAddress;
    notify();
  }

  @override
  String get repositoryId => "bitcoin";
}

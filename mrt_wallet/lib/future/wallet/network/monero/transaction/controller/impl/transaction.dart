import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

enum MoneroTxPage {
  utxo,
  send;
}

abstract class MoneroTransactionImpl extends StateController {
  MoneroTransactionImpl({required this.walletProvider, required this.account});
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final WalletProvider walletProvider;
  final MoneroChain account;
  WalletMoneroNetwork get network => account.network;
  MoneroClient get client => account.client;
  IMoneroAddress get address => account.address;
  DaemonGetEstimateFeeResponse get baseFee;
  late final IntegerBalance fee =
      IntegerBalance.zero(network.coinParam.decimal);
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  late final IntegerBalance setupAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  Future<void> calculateFee();

  List<MoneroAccountWithUtxo> _utxos = [];
  List<MoneroAccountWithUtxo> get utxos => _utxos;
  ReceiptAddress<MoneroAddress>? _change;
  ReceiptAddress<MoneroAddress> get change => _change!;

  bool _txReady = false;
  bool get txReady => _txReady;

  final Map<MoneroAddress, MoneroOutputWithBalance> _receivers = {};

  List<MoneroOutputWithBalance> get receivers => _receivers.values.toList();
  late final IntegerBalance spendableAmount =
      IntegerBalance.zero(network.coinDecimal, allowNegative: false);

  MoneroTxPage _page = MoneroTxPage.utxo;
  MoneroTxPage get page => _page;
  bool get canPop => page == MoneroTxPage.utxo;

  void onPop(bool canPop, Object? result) {
    _page = MoneroTxPage.utxo;
    notify();
  }

  bool _utxosIsReady = false;
  bool get utxosIsReay => _utxosIsReady;
  final Map<ReceiptAddress<MoneroAddress>, List<MoneroOutputDetails>>
      _selectedUtxos = {};

  Map<ReceiptAddress<MoneroAddress>, List<MoneroOutputDetails>>
      get selectedUtxos => _selectedUtxos;

  bool _isReady() {
    final zeroOutput = receivers.any((element) => !element.hasAmount);
    return receivers.isNotEmpty &&
        !zeroOutput &&
        !remindAmount.isNegative &&
        !setupAmount.isZero;
  }

  void addOrRemoveUtxo(
      ReceiptAddress<MoneroAddress> address, MoneroOutputDetails utxo) {
    try {
      final r = _selectedUtxos[address]!.remove(utxo);
      if (r) return;
      if (utxo.needUpdate) return;
      _selectedUtxos[address]?.add(utxo);
    } finally {
      _checkUtxos();
      notify();
    }
  }

  bool _canSendToAddress(MoneroAddress address) {
    if (address.isIntegratedAddress) {
      if (receivers.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  void _checkUtxos() {
    final total = _selectedUtxos.values.fold(
        BigInt.zero,
        (p, c) =>
            p + c.fold<BigInt>(BigInt.zero, (p, c) => p + c.amount.balance));
    spendableAmount.updateBalance(total);
    _utxosIsReady = spendableAmount.balance > BigInt.zero;
  }

  Future<void> initTransaction() async {
    try {
      await client.updateAccountUtxos(address: address, account: account);
      _utxos = account.relatedTxAccountsUtxos(address.addrDetails.viewKey);
      for (final i in _utxos) {
        _selectedUtxos.putIfAbsent(
            i.address, () => i.utxos.where((e) => !e.needUpdate).toList());
      }
      _change = ReceiptAddress(
          view: address.networkAddress.address,
          networkAddress: address.networkAddress,
          account: address,
          type: address.networkAddress.type.name);
      _checkUtxos();
    } catch (e, s) {
      WalletLogging.log("error here $e $s");
      rethrow;
    }
  }

  void goToSend() async {
    if (utxosIsReay) {
      progressKey.progressText("estimating_fee_please_wait".tr);
      onCalculateAmount();
      await calculateFee();
      onCalculateAmount();
      _page = MoneroTxPage.send;
      notify();
      progressKey.success();
    }
  }

  void onCalculateAmount() {
    final totalAmounts = receivers.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.amount.balance);
    setupAmount.updateBalance(totalAmounts);
    final remind = spendableAmount.balance - (totalAmounts + fee.balance);
    remindAmount.updateBalance(remind);
    _txReady = _isReady();
  }

  bool? _onAddRecever(ReceiptAddress<MoneroAddress> addr) {
    if (change.networkAddress == addr.networkAddress ||
        _receivers.containsKey(addr.networkAddress)) {
      return false;
    } else {
      if (_canSendToAddress(addr.networkAddress)) {
        _receivers[addr.networkAddress] =
            MoneroOutputWithBalance(address: addr, network: network);
        return true;
      }
      return false;
    }
  }

  void onAddRecever(
      List<ReceiptAddress<MoneroAddress>>? addr, BoolVoid onBadRecipient) {
    if (addr == null) return;
    bool hasBadReceipt = false;
    bool hasExistAddress = false;
    for (final i in addr) {
      final hasError = _onAddRecever(i);
      if (hasError == null) continue;
      if (hasError) {
        hasBadReceipt = true;
      } else {
        hasExistAddress = true;
      }
    }
    if (hasExistAddress || hasBadReceipt) {
      onBadRecipient(hasBadReceipt);
    }
    notify();
  }

  void onRemoveReceiver(ReceiptAddress<MoneroAddress> addr) {
    final r = _receivers.remove(addr.networkAddress);
    if (r != null) {
      onCalculateAmount();
      notify();
      calculateFee();
    }
  }

  void changeAccount(IMoneroAddress? change, DynamicVoid onAccountExists) {
    if (change != null) {
      if (change.networkAddress == _change?.networkAddress) return;
      if (_receivers.containsKey(change.networkAddress)) {
        onAccountExists();
        return;
      }
      _change = ReceiptAddress(
          view: change.networkAddress.address,
          networkAddress: change.networkAddress,
          type: change.type,
          account: change);
      notify();
    }
  }

  void setupAccountAmount(MoneroAddress address, BigInt? amount) async {
    if (amount == null) return;
    _receivers[address]?.updateBalance(amount);
    notify();
    final isMax = amount == remindAmount.balance;
    onCalculateAmount();
    if (isMax) {
      await calculateFee();
      if (isMax) {
        final fixedAmount = amount + remindAmount.balance;
        _receivers[address]?.updateBalance(fixedAmount);
        onCalculateAmount();
        notify();
      }
    } else {
      if (_utxosIsReady) {
        calculateFee();
      }
    }
  }
}

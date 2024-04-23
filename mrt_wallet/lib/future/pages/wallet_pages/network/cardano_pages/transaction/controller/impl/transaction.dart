import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cardano/cardano.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/account_utxos.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/cardano_output.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/utxo.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/utxo_multi_asset.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/utxo_with_owner.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:on_chain/on_chain.dart';

enum CardanoTransactionPages { account, utxo, send }

abstract class CardanoTransactionImpl extends StateController {
  late final NoneDecimalBalance spendableAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late final NoneDecimalBalance setupAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late final NoneDecimalBalance sumOfSelectedUtxo =
      NoneDecimalBalance.zero(network.coinParam.decimal);

  late final CardanoOutputWithBalance _changeADAOutput =
      CardanoOutputWithBalance(
          address: ReceiptAddress<ADAAddress>(
              view: address.address.toAddress,
              type: address.type,
              networkAddress: address.networkAddress),
          network: network);
  CardanoOutputWithBalance get changeADAOutput => _changeADAOutput;
  NoneDecimalBalance get remindAmount => changeADAOutput.balance;

  late final CardanoOutputWithBalance _changeAssetOutput =
      CardanoOutputWithBalance(
          address: ReceiptAddress<ADAAddress>(
              view: address.address.toAddress,
              type: address.type,
              networkAddress: address.networkAddress),
          network: network);
  CardanoOutputWithBalance get changeAssetOutput => _changeAssetOutput;

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "CardanoTransactionImpl");
  final WalletProvider walletProvider;

  final AppChain chainAccount;
  NetworkAccountCore get account => chainAccount.account;
  APPCardanoNetwork get network => chainAccount.network.toNetwork();
  CardanoApiProvider get providers => chainAccount.provider()!;
  ICardanoAddress get address =>
      chainAccount.account.address as ICardanoAddress;
  List<ICardanoAddress> get addresses => chainAccount.account.addresses.cast();

  GeneralTransactionMetadata? get transactionMemo;
  NoneDecimalBalance get transactionFee;
  int get coinsPerUtxoSize;
  Future<void> calculateFee();

  CardanoTransactionImpl(
      {required this.walletProvider, required this.chainAccount});

  bool _trReady = false;
  bool get trReady => _trReady;

  CardanoTransactionPages _page = CardanoTransactionPages.account;
  CardanoTransactionPages get page => _page;
  bool get inUtxoPage => _page == CardanoTransactionPages.utxo;
  bool get inSendPage => _page == CardanoTransactionPages.send;

  UtxoMultiAsset _totalAsset = UtxoMultiAsset.empty;
  UtxoMultiAsset get totalAssets => _totalAsset;
  bool get hasAsset => _totalAsset.hasAsset;

  final Map<String, List<ADAAccountUTXOs>> _fetchedUtxos = {};

  final Map<String, CardanoUtxoWithOwner> _accountUtxos = {};
  List<CardanoUtxoWithOwner> get utxos => _accountUtxos.values.toList();

  final List<CardanoUtxo> _selectedUtxos = [];
  List<CardanoUtxo> get selectedUtxos => _selectedUtxos;
  bool get allUtxosSelected => _selectedUtxos.length == _utxosCount;
  bool utxoSelected(CardanoUtxo utxo) => _selectedUtxos.contains(utxo);
  bool get canBuildTransaction => _selectedUtxos.isNotEmpty;

  int _utxosCount = 0;

  bool get haveUtxos => _utxosCount > 0;

  final List<ADAAddress> _addresses = [];
  bool addressSelected(ICardanoAddress addr) =>
      _addresses.contains(addr.networkAddress);
  List<ADAAddress> get spenders => _addresses;
  bool get hasSpender => spenders.isNotEmpty;

  final Map<String, CardanoOutputWithBalance> _receivers = {};
  List<CardanoOutputWithBalance> get receivers => _receivers.values.toList();

  void changeOutputAddress(ICardanoAddress? changeAddr) {
    if (changeAddr == null ||
        changeAddr.address.toAddress == _changeADAOutput.address.view) return;
    _changeADAOutput.setAddress(ReceiptAddress<ADAAddress>(
        view: changeAddr.address.toAddress,
        type: changeAddr.type,
        networkAddress: changeAddr.networkAddress));
    notify();
  }

  void changeAssetOutputAddress(ICardanoAddress? changeAddr) {
    if (changeAddr == null ||
        changeAddr.address.toAddress == _changeAssetOutput.address.view) return;
    _changeAssetOutput.setAddress(ReceiptAddress<ADAAddress>(
        view: changeAddr.address.toAddress,
        type: changeAddr.type,
        networkAddress: changeAddr.networkAddress));
    notify();
  }

  void onSetupUtxo() {
    _totalAsset = selectedUtxos.fold(UtxoMultiAsset({}),
        (previousValue, element) => previousValue + element.utxo.multiAsset);

    onCalculateAmount();
    if (hasAsset) {
      changeAssetOutput.updateBalance(
          changeAssetOutput.minValue(coinsPerUtxoSize),
          coinsPerUtxoSize: coinsPerUtxoSize);
      onCalculateAmount();
    }
    _page = CardanoTransactionPages.send;
    notify();
  }

  void _countUtxos() {
    _utxosCount = 0;
    for (final i in _accountUtxos.values) {
      _utxosCount += (i.utxos?.length ?? 0);
    }
  }

  void addSpender(ICardanoAddress address) {
    final r = _addresses.remove(address.networkAddress);
    if (!r) {
      _addresses.add(address.networkAddress);
    }
    notify();
  }

  void addUtxo(CardanoUtxo utxo) {
    final r = _selectedUtxos.remove(utxo);
    if (!r) {
      _selectedUtxos.add(utxo);
    }
    sumOfSelectedUtxo.updateBalance(_selectedUtxos.fold<BigInt>(
        BigInt.zero,
        (previousValue, element) =>
            previousValue + element.utxoBalance.balance));
    notify();
  }

  void selectAllUtxos() {
    try {
      if (allUtxosSelected) {
        _selectedUtxos.clear();
        return;
      }
      _selectedUtxos.clear();
      for (final i in _accountUtxos.values) {
        _selectedUtxos.addAll(i.utxos ?? <CardanoUtxo>[]);
      }
      sumOfSelectedUtxo.updateBalance(_selectedUtxos.fold<BigInt>(
          BigInt.zero,
          (previousValue, element) =>
              previousValue + element.utxoBalance.balance));
    } finally {
      notify();
    }
  }

  Future<void> fetchUtxos() async {
    if (_addresses.isEmpty) return;
    progressKey.progressText("retreiving_account_utxos".tr);
    _accountUtxos.clear();
    for (final i in _addresses) {
      if (_fetchedUtxos.containsKey(i.address)) {
        _accountUtxos[i.address] = CardanoUtxoWithOwner(
            owner: i,
            network: network,
            utxos:
                List<ADAAccountUTXOs>.unmodifiable(_fetchedUtxos[i.address]!));
        continue;
      }
      try {
        final utxos = await providers.getUtxos(i);
        _fetchedUtxos[i.address] = List<ADAAccountUTXOs>.unmodifiable(utxos);
        _accountUtxos[i.address] = CardanoUtxoWithOwner(
            owner: i,
            network: network,
            utxos:
                List<ADAAccountUTXOs>.unmodifiable(_fetchedUtxos[i.address]!));
        // ignore: empty_catches
      } catch (e) {}
    }
    _page = CardanoTransactionPages.utxo;
    spendableAmount.updateBalance(utxos.fold<BigInt>(
        BigInt.zero,
        (previousValue, element) =>
            previousValue + element.utxoAmounts.balance));
    onCalculateAmount();
    _countUtxos();
    progressKey.success();
  }

  void removeReceiver(ReceiptAddress<ADAAddress>? addr) {
    if (addr == null) return;
    final re = _receivers.remove(addr.networkAddress.address);
    onCalculateAmount();
    if (re != null) {
      calculateFee();
    }
    notify();
  }

  void setupAccountAmount(String address, BigInt? amount) async {
    if (amount == null) return;
    _receivers[address]
        ?.updateBalance(amount, coinsPerUtxoSize: coinsPerUtxoSize);
    bool isMax = amount == remindAmount.balance;
    onCalculateAmount();
    if (isMax) {
      await calculateFee();
      final fixedAmount = amount + remindAmount.balance;
      _receivers[address]
          ?.updateBalance(fixedAmount, coinsPerUtxoSize: coinsPerUtxoSize);
      onCalculateAmount();
    }
    notify();
  }

  void changeAssetAdaAmount(BigInt? amount) async {
    if (amount == null || !hasAsset) return;
    _changeAssetOutput.updateBalance(amount,
        coinsPerUtxoSize: coinsPerUtxoSize);
    onCalculateAmount();
    notify();
  }

  void setupAccountAsset(String address, UtxoMultiAsset? asset) async {
    if (asset == null) return;
    _receivers[address]!.setAsset(asset);
    calculateFee();
    onCalculateAmount();
    notify();
  }

  bool _isReady() {
    final zeroOutput = receivers.any((element) => !element.hasAmount);
    return receivers.isNotEmpty &&
        !zeroOutput &&
        !remindAmount.isNegative &&
        !setupAmount.isZero &&
        transactionFee.largerThanZero;
  }

  void onCalculateAmount() {
    final totalAmounts = receivers.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    setupAmount.updateBalance(totalAmounts + changeAssetOutput.balance.balance);
    final remind = sumOfSelectedUtxo.balance -
        totalAmounts -
        changeAssetOutput.balance.balance -
        transactionFee.balance;
    remindAmount.updateBalance(remind);
    final filledAsset = _receivers.values.fold(UtxoMultiAsset({}),
        (previousValue, element) => previousValue + element.asset);
    _changeAssetOutput.setAsset(_totalAsset - filledAsset);
    _trReady = _isReady();
    notify();
  }

  void onAddRecever(
      ReceiptAddress<ADAAddress>? addr, DynamicVoid onAccountExists) {
    if (addr == null) return;
    if (_receivers.containsKey(addr.networkAddress.address)) {
      onAccountExists();
      return;
    } else {
      _receivers[addr.networkAddress.address] =
          CardanoOutputWithBalance(address: addr, network: network);
    }
    notify();
    calculateFee();
  }
}

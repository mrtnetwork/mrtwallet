import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/select_account_or_contact.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum CardanoTransactionPages { account, utxo, send }

abstract class CardanoTransactionImpl extends StateController {
  List<ADAMintInfo> get mints;
  List<ADATransactionCertificate> get certificates;
  List<ADATransactionDeposit> _deposits = [];
  List<ADATransactionDeposit> get deposits => _deposits;
  bool get hasDeposit => deposits.isNotEmpty;
  List<ADATransactionDeposit> _refundDepsit = [];
  List<ADATransactionDeposit> get refundDeposit => _refundDepsit;
  bool get hasRefundDeposit => refundDeposit.isNotEmpty;
  void _findDeposits() {
    final List<ADATransactionDeposit> depositsValues = [];
    final List<ADATransactionDeposit> refund = [];
    for (final i in certificates) {
      if (i.type == ADATransactionCertificateType.registraction) {
        depositsValues.add(ADATransactionDeposit.amount(
            type: ADACustomFeeTypes.stakeRegistration,
            fee: protocolParams.keyDeposit));
      } else if (i.type == ADATransactionCertificateType.deregistration) {
        refund.add(ADATransactionDeposit.amount(
            type: ADACustomFeeTypes.stakeRegistration,
            fee: protocolParams.keyDeposit));
      }
    }
    _deposits = List<ADATransactionDeposit>.unmodifiable(depositsValues);
    _refundDepsit = List<ADATransactionDeposit>.unmodifiable(refund);
  }

  late final IntegerBalance spendableAmount =
      IntegerBalance.zero(network.coinParam.decimal);

  late final IntegerBalance sumOfSelectedUtxo =
      IntegerBalance.zero(network.coinParam.decimal);

  late final CardanoOutputWithBalance _changeADAOutput =
      CardanoOutputWithBalance(
          address: ReceiptAddress<ADAAddress>(
              view: address.address.toAddress,
              type: address.type,
              networkAddress: address.networkAddress,
              account: address),
          network: network,
          coinsPerUtxoSize: protocolParams.coinsPerUtxoSize);
  CardanoOutputWithBalance get changeADAOutput => _changeADAOutput;
  IntegerBalance get remindAmount => changeADAOutput.balance;

  late final CardanoOutputWithBalance _changeAssetOutput =
      CardanoOutputWithBalance(
          address: ReceiptAddress<ADAAddress>(
              view: address.address.toAddress,
              type: address.type,
              networkAddress: address.networkAddress,
              account: address),
          network: network,
          coinsPerUtxoSize: protocolParams.coinsPerUtxoSize);
  CardanoOutputWithBalance get changeAssetOutput => _changeAssetOutput;

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "CardanoTransactionImpl");
  final WalletProvider walletProvider;

  final ADAChain chainAccount;
  // Bip32NetworkAccount get account => chainAccount.account;
  WalletCardanoNetwork get network => chainAccount.network.toNetwork();
  CardanoClient get providers => chainAccount.client;
  ICardanoAddress get address => chainAccount.address;
  List<ICardanoAddress> get addresses => chainAccount.addresses;

  GeneralTransactionMetadata? get transactionMemo;
  IntegerBalance get transactionFee;
  ADAEpochParametersResponse get protocolParams;
  void calculateFee() {
    _findDeposits();
  }

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

  final List<ICardanoAddress> _addresses = [];
  bool addressSelected(ICardanoAddress addr) => _addresses.contains(addr);
  List<ICardanoAddress> get spenders => _addresses;
  bool get hasSpender => spenders.isNotEmpty;

  final Map<String, CardanoOutputWithBalance> _receivers = {};
  List<CardanoOutputWithBalance> get receivers => _receivers.values.toList();

  void setTotalAssets(UtxoMultiAsset? assets) {
    _totalAsset = assets ?? UtxoMultiAsset(const {});
  }

  void changeOutputAddress(ICardanoAddress? changeAddr) {
    if (changeAddr == null ||
        changeAddr.address.toAddress == _changeADAOutput.address.view) {
      return;
    }
    final bool needRecalculationFee = changeAddr.networkAddress.addressType !=
        _changeADAOutput.address.networkAddress.addressType;
    final ReceiptAddress<ADAAddress> changeReceiptAddr =
        ReceiptAddress<ADAAddress>(
            view: changeAddr.address.toAddress,
            type: changeAddr.type,
            networkAddress: changeAddr.networkAddress,
            account: changeAddr);
    _changeADAOutput.setAddress(changeReceiptAddr);
    if (needRecalculationFee) {
      calculateFee();
    }
    notify();
  }

  void changeAssetOutputAddress(ICardanoAddress? changeAddr) {
    if (changeAddr == null ||
        changeAddr.address.toAddress == _changeAssetOutput.address.view) {
      return;
    }
    final bool needRecalculationFee = changeAddr.networkAddress.addressType !=
        _changeAssetOutput.address.networkAddress.addressType;
    _changeAssetOutput.setAddress(ReceiptAddress<ADAAddress>(
        view: changeAddr.address.toAddress,
        type: changeAddr.type,
        networkAddress: changeAddr.networkAddress,
        account: changeAddr));
    if (needRecalculationFee) {
      calculateFee();
    }
    notify();
  }

  void onSetupUtxo() {
    final totalUtxosAsset = selectedUtxos.fold(UtxoMultiAsset({}),
        (previousValue, element) => previousValue + element.utxo.multiAsset);
    setTotalAssets(totalUtxosAsset);
    onCalculateAmount();
    if (hasAsset) {
      changeAssetOutput.initializeBalance();
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

  void addSpender(ICardanoAddress address, StringVoid onError) {
    if (address.networkAddress.isRewardAddress) {
      onError("unable_to_spend_from_stake_address");
      return;
    }
    final r = _addresses.remove(address);
    if (!r) {
      _addresses.add(address);
    }
    notify();
  }

  void _updateSelectedUtxosBalance() {
    final BigInt totalUtxosBalances = _selectedUtxos.fold<BigInt>(
        BigInt.zero,
        (previousValue, element) =>
            previousValue + element.utxoBalance.balance);
    sumOfSelectedUtxo.updateBalance(totalUtxosBalances);
  }

  void addUtxo(CardanoUtxo utxo) {
    final r = _selectedUtxos.remove(utxo);
    if (!r) {
      _selectedUtxos.add(utxo);
    }
    _updateSelectedUtxosBalance();
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
      _updateSelectedUtxosBalance();
    } finally {
      notify();
    }
  }

  Future<void> fetchUtxos() async {
    if (_addresses.isEmpty) return;
    progressKey.progressText("retreiving_account_utxos".tr);
    _accountUtxos.clear();
    for (final i in _addresses) {
      if (_fetchedUtxos.containsKey(i.networkAddress.address)) {
        _accountUtxos[i.networkAddress.address] = CardanoUtxoWithOwner(
            owner: i.networkAddress,
            network: network,
            utxos: List<ADAAccountUTXOs>.unmodifiable(
                _fetchedUtxos[i.networkAddress.address]!));
        continue;
      }
      try {
        final utxos = await providers.getUtxos(address: i, chain: chainAccount);
        _fetchedUtxos[i.networkAddress.address] =
            List<ADAAccountUTXOs>.unmodifiable(utxos);
        _accountUtxos[i.networkAddress.address] = CardanoUtxoWithOwner(
            owner: i.networkAddress,
            network: network,
            utxos: List<ADAAccountUTXOs>.unmodifiable(
                _fetchedUtxos[i.networkAddress.address]!));
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
    _receivers[address]?.updateBalance(amount);
    final bool isMax = amount == remindAmount.balance;
    onCalculateAmount();
    if (isMax) {
      calculateFee();
      final fixedAmount = amount + remindAmount.balance;
      _receivers[address]?.updateBalance(fixedAmount);
      onCalculateAmount();
    }
    notify();
  }

  void changeAssetAdaAmount(BigInt? amount) async {
    if (amount == null || !hasAsset || !_changeAssetOutput.hasAssets) return;
    _changeAssetOutput.updateBalance(amount);
    onCalculateAmount();
    notify();
  }

  void setupAccountAsset(String address, UtxoMultiAsset? asset) async {
    if (asset == null) return;
    _receivers[address]!.updateAssets(asset);
    calculateFee();
    onCalculateAmount();
    notify();
  }

  bool _isReady() {
    final hasNotReadyOutput = receivers.any((element) => !element.isReady);
    return !hasNotReadyOutput &&
        !remindAmount.isNegative &&
        transactionFee.largerThanZero &&
        (!hasAsset || _changeAssetOutput.isReady);
  }

  void onCalculateAmount() {
    final filledAsset = _receivers.values.fold(UtxoMultiAsset({}),
        (previousValue, element) => previousValue + element.asset);
    _changeAssetOutput.updateAssets(_totalAsset - filledAsset);
    final totalAmounts = receivers.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.balance.balance);
    _findDeposits();
    final BigInt depositsAmounts = deposits.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.fee.balance);
    final BigInt refaunds = refundDeposit.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.fee.balance);
    final remind = sumOfSelectedUtxo.balance +
        refaunds -
        totalAmounts -
        changeAssetOutput.balance.balance -
        transactionFee.balance -
        depositsAmounts;
    remindAmount.updateBalance(remind);

    _trReady = _isReady();
    notify();
  }

  bool _onAddRecever(ReceiptAddress<ADAAddress> addr) {
    if (!_receivers.containsKey(addr.networkAddress.address) &&
        !addr.networkAddress.isRewardAddress) {
      _receivers[addr.networkAddress.address] = CardanoOutputWithBalance(
          address: addr,
          network: network,
          coinsPerUtxoSize: protocolParams.coinsPerUtxoSize);
      return true;
    }
    return false;
  }

  String? validateAddress(ADAAddress addr) {
    if (addr.isRewardAddress) return "cannot_send_ada_to_stake_address".tr;
    if (_receivers.containsKey(addr.address)) {
      return "address_already_exist".tr;
    }
    return null;
  }

  Future<void> onAddRecever({
    required OnSelectRecipients<ADAAddress> onSelectAddresses,
    required StringVoid onAccountExists,
  }) async {
    final addresses = await onSelectAddresses(
        account: chainAccount,
        onFilterAccount: validateAddress,
        selectedAddresses: receivers.map((e) => e.address).toList());
    if (addresses == null) return;
    bool allAdded = true;
    for (final i in addresses) {
      allAdded &= _onAddRecever(i);
    }
    if (!allAdded) {
      onAccountExists("some_addresses_exist");
    }
    notify();
    calculateFee();
  }

  List<TransactionOutput> _getRemindOutputs() {
    final List<TransactionOutput> remindOutputs = [];
    if (remindAmount.largerThanZero) {
      TransactionOutput output = changeADAOutput.toOutput();
      output = output.copyWith(
          amount: output.amount.copyWith(coin: remindAmount.balance));
      remindOutputs.add(output);
    }
    if (changeAssetOutput.hasAssets) {
      final TransactionOutput assetOutput = changeAssetOutput.toOutput();
      remindOutputs.add(assetOutput);
    }
    return remindOutputs;
  }

  ADATransactionBuilder buildTransaction(BigInt fee) {
    final sortedCertificates = certificates.map((e) => e.certificate).toList()
      ..sort((a, b) {
        final aType = a.certificate.type;
        final bType = b.certificate.type;
        if (aType == CertificateType.stakeRegistration &&
            bType != CertificateType.stakeRegistration) {
          return -1;
        } else if (aType != CertificateType.stakeRegistration &&
            bType == CertificateType.stakeRegistration) {
          return 1;
        }
        return 0;
      });
    final transaction = ADATransactionBuilder(
        outputs: [
          ...receivers.map((e) => e.toOutput()),
          ..._getRemindOutputs()
        ],
        utxos: selectedUtxos.map((e) => e.utxo.toUtxoResponse()).toList(),
        metadata: transactionMemo,
        certificates: sortedCertificates,
        deposits: deposits.map((e) => e.toDepositBuilder()).toList(),
        refundDeposits: refundDeposit.map((e) => e.toDepositBuilder()).toList(),
        mints: mints.map((e) => e.toMintBuilder()).toList())
      ..setFee(fee);
    return transaction;
  }
}

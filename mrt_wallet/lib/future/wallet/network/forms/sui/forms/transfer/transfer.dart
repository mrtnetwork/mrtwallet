import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain/bcs/move/types/types.dart';
import 'package:on_chain/sui/sui.dart';

class SuiTransferForm extends SuiTransactionForm {
  SuiTransferForm(this.token);
  BigInt _transferValue = BigInt.zero;
  final SuiToken? token;
  late final Token transferToken = token?.token ?? network.token;
  @override
  late final SuiTransactionType transactionType = token == null
      ? SuiTransactionType.transfer
      : SuiTransactionType.tokenTransfer;
  @override
  late final bool enableSwitchAccount = token == null;
  @override
  BigInt get transferValue => _transferValue;

  void checkAmount() {
    if (transactionType.isTokenTransfer) return;
    _transferValue =
        destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
  }

  BigInt max(SuiOutputWithBalance receiver, BigInt fee) {
    if (transactionType.isTokenTransfer) {
      _transferValue =
          destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
      final max = (token!.balance.value.balance -
          _transferValue +
          receiver.balance.balance);
      return max;
    }
    final max = (address.address.currencyBalance -
        _transferValue +
        receiver.balance.balance);
    return max - fee;
  }

  final TransactionListFormField<SuiOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  @override
  String get name => "transfer".tr;
  void removeReceiver(SuiOutputWithBalance destination) {
    this.destination.removeValue(destination);
    checkAmount();
    onChanged?.call();
  }

  void setupAccountAmount(SuiOutputWithBalance destination, BigInt? amount) {
    if (amount == null) return;
    destination.updateBalance(amount);
    checkAmount();
    onChanged?.call();
  }

  String? filterAccount(SuiAddress address) {
    if (address == this.address.networkAddress ||
        destination.value.any((e) => e.address.networkAddress == address)) {
      return "address_already_exist".tr;
    }
    return null;
  }

  void onAddSingleRecever(
      ReceiptAddress<SuiAddress>? receiver, StringVoid onExists) {
    if (receiver == null) return;
    if (destination.isNotEmpty) return;
    if (receiver.networkAddress == address.networkAddress) {
      onExists("address_already_exist".tr);
      return;
    }
    MethodUtils.after(() async {
      final r = SuiOutputWithBalance(address: receiver, token: transferToken);
      destination.addValue(r);
      onChanged?.call();
    });
  }

  void onAddRecever(
      List<ReceiptAddress<SuiAddress>>? receiver, StringVoid onExists) {
    if (receiver == null) return;

    MethodUtils.after(() async {
      bool hasExistAccount = false;
      for (final i in receiver) {
        final r = SuiOutputWithBalance(address: i, token: transferToken);
        if (destination.value.contains(r) ||
            i.networkAddress == address.networkAddress) {
          hasExistAccount = true;
          continue;
        }
        destination.addValue(r);
      }
      if (hasExistAccount) onExists("some_addresses_exist".tr);
      onChanged?.call();
    });
  }

  @override
  String? validateError({ISuiAddress? account}) {
    if (destination.isEmpty) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value) {
      if (!i.hasAmount) {
        return "input_for_each_entery".tr;
      }
    }
    return null;
  }

  @override
  void close() {
    destination.clear();
    _transferValue = BigInt.zero;
    super.close();
  }

  @override
  Future<SuiProgrammableTransaction> createTransaction(
      ISuiAddress address) async {
    switch (transactionType) {
      case SuiTransactionType.transfer:
        return _createTransferSingleCoin();
      case SuiTransactionType.tokenTransfer:
        return _createTokenTransaction(address);
    }
  }

  SuiProgrammableTransaction _createTransferSingleCoin({SuiObjectRef? object}) {
    final destionations = destination.value;
    final index = object == null ? 0 : 1;
    final splitCoins = SuiCommandSplitCoins(
        amounts: List.generate(destionations.length, (i) {
          return SuiArgumentInput(index + i);
        }),
        coin: object == null ? SuiArgumentGasCoin() : SuiArgumentInput(0));
    final amounts = destionations
        .map((e) => SuiCallArgPure.u64(e.balance.balance))
        .toList();
    final addresses =
        destionations.map((e) => e.address.networkAddress).toList();
    final transfers = List.generate(destionations.length, (i) {
      return SuiCommandTransferObjects(objects: [
        SuiArgumentNestedResult(commandIndex: 0, resultIndex: i),
      ], address: SuiArgumentInput(index + i + amounts.length));
    });
    return SuiProgrammableTransaction(inputs: [
      if (object != null)
        SuiCallArgObject(SuiObjectArgImmOrOwnedObject(object)),
      ...amounts,
      ...addresses,
    ], commands: [
      splitCoins,
      ...transfers
    ]);
  }

  Future<SuiProgrammableTransaction> _createTokenTransaction(
      ISuiAddress address) async {
    final assetType = token!.assetType;
    final accountCoins = await client.getAccountCoins(address.networkAddress);
    final coins = accountCoins.where((e) => e.coinType == assetType).toList();
    if (coins.length == 1) {
      return _createTransferSingleCoin(object: coins[0].toObjectRef());
    }
    List<SuiCallArguments> inputs = coins
        .map((e) =>
            SuiCallArgObject(SuiObjectArgImmOrOwnedObject(e.toObjectRef())))
        .cast<SuiCallArguments>()
        .toList();
    final destionations = destination.value;
    List<SuiCommand> commands = [
      SuiCommandMergeCoins(
          sources:
              List.generate(coins.length - 1, (i) => SuiArgumentInput(i + 1)),
          destination: SuiArgumentInput(0)),
      SuiCommandSplitCoins(
          amounts: List.generate(
              destionations.length, (i) => SuiArgumentInput(inputs.length + i)),
          coin: SuiArgumentInput(0))
    ];

    final amounts = destionations
        .map((e) => SuiCallArgPure.u64(e.balance.balance))
        .toList();
    inputs.addAll(amounts);
    final transfers = List.generate(destionations.length, (i) {
      final index = inputs.length + i;
      return SuiCommandTransferObjects(objects: [
        SuiArgumentNestedResult(commandIndex: 1, resultIndex: i),
      ], address: SuiArgumentInput(index));
    });
    final addresses =
        destionations.map((e) => e.address.networkAddress).toList();
    inputs.addAll(addresses);
    commands.addAll(transfers);
    return SuiProgrammableTransaction(inputs: inputs, commands: commands);
  }
}

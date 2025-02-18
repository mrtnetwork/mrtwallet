import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/networks/aptos/models/types.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/aptos/aptos.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain/aptos/src/helper/helper.dart';

class AptosTransferForm extends AptosTransactionForm {
  AptosTransferForm(this.token);
  BigInt _transferValue = BigInt.zero;
  final AptosFATokens? token;
  late final Token transferToken = token?.token ?? network.token;
  @override
  late final AptosTransactionType transactionType = token == null
      ? AptosTransactionType.transfer
      : AptosTransactionType.tokenTransfer;
  bool _canAddReceiver = true;
  bool get canAddReceiver => _canAddReceiver;
  @override
  late final bool enableSwitchAccount = token == null;
  @override
  BigInt get transferValue => _transferValue;

  void checkReceiver() {
    _canAddReceiver = !transactionType.isTokenTransfer || destination.isEmpty;
  }

  void checkAmount() {
    if (transactionType.isTokenTransfer) return;
    _transferValue =
        destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
  }

  BigInt max(AptosOutputWithBalance receiver, BigInt fee) {
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

  final TransactionListFormField<AptosOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  String? filterAccount(AptosAddress address) {
    if (address == this.address.networkAddress ||
        destination.value.any((e) => e.address.networkAddress == address)) {
      return "address_already_exist".tr;
    }
    return null;
  }

  @override
  String get name => "transfer".tr;
  void removeReceiver(AptosOutputWithBalance destination) {
    this.destination.removeValue(destination);
    checkAmount();
    checkReceiver();
    onChanged?.call();
  }

  void setupAccountAmount(AptosOutputWithBalance destination, BigInt? amount) {
    if (amount == null) return;
    destination.updateBalance(amount);
    checkAmount();
    onChanged?.call();
  }

  void onAddSingleRecever(
      ReceiptAddress<AptosAddress>? receiver, StringVoid onExists) {
    if (receiver == null) return;
    if (destination.isNotEmpty) return;
    if (receiver.networkAddress == address.networkAddress) {
      onExists("address_already_exist".tr);
      return;
    }
    MethodUtils.after(() async {
      final r = AptosOutputWithBalance(address: receiver, token: transferToken);
      destination.addValue(r);
      checkReceiver();
      onChanged?.call();
    });
  }

  void onAddRecever(
      List<ReceiptAddress<AptosAddress>>? receiver, StringVoid onExists) {
    if (receiver == null) return;

    MethodUtils.after(() async {
      bool hasExistAccount = false;
      for (final i in receiver) {
        final r = AptosOutputWithBalance(address: i, token: transferToken);
        if (destination.value.contains(r) ||
            i.networkAddress == address.networkAddress) {
          hasExistAccount = true;
          continue;
        }
        destination.addValue(r);
      }
      if (hasExistAccount) onExists("some_addresses_exist".tr);
      checkReceiver();
      onChanged?.call();
    });
  }

  @override
  String? validateError({IAptosAddress? account}) {
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
  AptosTransactionPayload createTransaction(IAptosAddress address) {
    if (transactionType.isTokenTransfer) {
      return AptosTransactionPayloadEntryFunction(
          entryFunction:
              destination.value.first.createFTAssetTransfer(token!.assetType));
    }
    final transfers =
        destination.value.map((e) => e.createNativeTransfer()).toList();
    final entryFunction =
        AptosHelper.createBatchTransferTransferEntry(transfers);
    return AptosTransactionPayloadEntryFunction(entryFunction: entryFunction);
  }
}

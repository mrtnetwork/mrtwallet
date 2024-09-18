import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/core/cosmos.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class CosmosTransferForm extends CosmosTransactionForm {
  CosmosTransferForm({required this.network});

  @override
  BigInt get callValue =>
      destination.value?.fold<BigInt>(
          BigInt.zero,
          (previousValue, element) =>
              previousValue + element.balance.balance) ??
      BigInt.zero;
  final WalletCosmosNetwork network;
  final TransactionFormField<List<CosmosOutputWithBalance>> destination =
      TransactionFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  @override
  OnChangeForm? onChanged;

  @override
  String get name => "transfer";

  void setListValue<T>(TransactionFormField<List<T>> field, T? value,
      {DynamicVoid? onExists}) {
    if (value == null) return;
    if (field != destination) return;
    final addr =
        (value as CosmosOutputWithBalance).address.networkAddress.address;
    final bool exists = destination.value?.any(
            (element) => element.address.networkAddress.address == addr) ??
        false;
    if (exists) {
      onExists?.call();
      return;
    }
    if (destination.setValue([
      value as CosmosOutputWithBalance,
      ...destination.value ?? <CosmosOutputWithBalance>[]
    ])) {
      onChanged?.call();
    }
  }

  void setReceiver(
      {required ReceiptAddress<CosmosBaseAddress>? address,
      required DynamicVoid onExists,
      required WalletCosmosNetwork network}) {
    if (address == null) return;
    final bool exists = destination.value?.any((element) =>
            element.address.networkAddress.address ==
            address.networkAddress.address) ??
        false;
    if (exists) {
      onExists.call();
      return;
    }
    if (destination.setValue([
      CosmosOutputWithBalance(address: address, network: network),
      ...destination.value ?? <CosmosOutputWithBalance>[]
    ])) {
      onChanged?.call();
    }
  }

  void onRemoveReceiver(String? address) {
    if (address == null) return;
    destination.setValue(List.from(destination.value
            ?.where(
                (element) => element.address.networkAddress.address != address)
            .toList() ??
        []));
    onChanged?.call();
    final isValid = validateError();
    if (isValid == null) {
      final int hashCode = destination.value.hashCode;
      onReadyField?.call(hashCode.toString());
    }
  }

  void setBalance(String address, BigInt? balance) {
    if (balance == null) return;
    try {
      final des = MethodUtils.nullOnException(() => destination.value
          ?.firstWhere(
              (element) => element.address.networkAddress.address == address));
      if (des == null) return;
      des.updateBalance(balance);
      onChanged?.call();
      final isValid = validateError();
      if (isValid == null) {
        final int hashCode = destination.value.hashCode;
        onReadyField?.call(hashCode.toString());
      }
      // ignore: empty_catches
    } on StateError {}
  }

  @override
  String? validateError({ICosmosAddress? account}) {
    if (destination.value?.isEmpty ?? true) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value!) {
      if (!i.hasAmount) {
        return "the_amount_is_unspecified".tr;
      }
    }

    return null;
  }

  @override
  List<ServiceMessage> messages(CosmosBaseAddress signer) {
    return destination.value!.map((e) => e.toMessage(signer, network)).toList();
  }
}

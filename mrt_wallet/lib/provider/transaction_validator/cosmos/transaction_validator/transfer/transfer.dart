import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/cosmos/transaction_validator/core/cosmos_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:mrt_wallet/types/typedef.dart';

class CosmosTransferValidator extends CosmosTransactionValidator {
  CosmosTransferValidator({required this.network});

  @override
  BigInt get callValue =>
      destination.value?.fold<BigInt>(
          BigInt.zero,
          (previousValue, element) =>
              previousValue + element.balance.balance) ??
      BigInt.zero;
  final APPCosmosNetwork network;
  final ValidatorField<List<CosmosOutputWithBalance>> destination =
      ValidatorField(
          name: "destination",
          optional: false,
          onChangeValidator: (p0) {
            return p0;
          });

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [destination];

  @override
  String get name => "transfer";

  void setListValue<T>(ValidatorField<List<T>> field, T? value,
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
      required APPCosmosNetwork network}) {
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
      final des = MethodCaller.nullOnException(() => destination.value
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
  void setValue<T>(ValidatorField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
    }
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

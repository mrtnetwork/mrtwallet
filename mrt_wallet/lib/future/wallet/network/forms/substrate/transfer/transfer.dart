import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class SubstrateTransferForm extends SubstrateTransactionForm {
  SubstrateTransferForm({required this.network});
  BigInt _callValue = BigInt.zero;
  @override
  BigInt get callValue => _callValue;

  @override
  final WalletPolkadotNetwork network;
  final TransactionListFormField<SubstrateOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  @override
  OnChangeForm? onChanged;

  @override
  String get name => "transfer";

  bool _isReady = false;

  bool get isReady => _isReady;

  BigInt _calcNativeValue() {
    final balances =
        destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
    return balances + fee;
  }

  BigInt maxTransfer(
      {required ChainAccount account,
      required SubstrateOutputWithBalance receiver}) {
    return (account.address.currencyBalance - callValue) +
        receiver.balance.balance;
  }

  void _check() {
    calculateNativeValue();
    _isReady = destination.value.every((element) => element.hasAmount);
    onChanged?.call();
    if (isReady) {
      onReadyField?.call();
    }
  }

  @override
  void calculateNativeValue() {
    _callValue = _calcNativeValue();
  }

  void setReceiver(
      {required ReceiptAddress<SubstrateAddress>? address,
      required DynamicVoid onExists}) {
    if (address == null) return;
    final bool exists =
        destination.value.any((element) => element.address == address);
    if (exists) {
      onExists.call();
      return;
    }
    destination.addValue(
        SubstrateOutputWithBalance(address: address, network: network));
    _check();
  }

  void onRemoveReceiver(SubstrateOutputWithBalance output) {
    destination.removeValue(output);
    _check();
  }

  void setBalance(
      {required SubstrateOutputWithBalance address, BigInt? balance}) {
    if (balance == null) return;
    address.updateBalance(balance);
    _check();
  }

  @override
  String? validateError({ISubstrateAddress? account}) {
    if (!destination.hasValue) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value) {
      if (!i.hasAmount) {
        return "the_amount_is_unspecified".tr;
      }
    }

    return null;
  }

  @override
  List<Map<String, dynamic>> toMessage() {
    final bool usePallet = destination.length > 1;
    return destination.value
        .map((e) => e.toMessage(usePallet: usePallet))
        .toList();
  }

  @override
  int get methodsLength => destination.length;
}

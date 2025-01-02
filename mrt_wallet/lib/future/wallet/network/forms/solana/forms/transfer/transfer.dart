import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class SolanaTransferForm extends SolanaTransactionForm {
  SolanaTransferForm({required this.token, this.splToken});
  BigInt _transferValue = BigInt.zero;
  @override
  BigInt get transferValue => _transferValue;

  final Token token;
  final SolanaSPLToken? splToken;
  final GlobalKey<StreamWidgetState> accountKey =
      GlobalKey<StreamWidgetState>();
  SolanaTransferDestinationInfo? _accountInfo;
  SolanaTransferDestinationInfo? get accountInfo => _accountInfo;
  final bool _isPubKey = false;
  bool get isPubKey => _isPubKey;

  final bool _hasError = false;
  bool get hasError => _hasError;
  bool get isTokenTransfer => splToken != null;

  final bool _showRequirementAmountAlert = false;
  bool get showRequirementAmountAlert => _showRequirementAmountAlert;

  void checkAmount() {
    _transferValue =
        destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
  }

  BigInt max(SolanaOutputWithBalance receiver) {
    if (isTokenTransfer) {
      return splToken!.balance.value.balance - receiver.balance.balance;
    }
    return (address.address.currencyBalance -
        _transferValue +
        receiver.balance.balance);
  }

  final TransactionListFormField<SolanaOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  @override
  OnChangeForm? onChanged;

  @override
  String get name => "transfer".tr;
  void removeReceiver(SolanaOutputWithBalance destination) {
    this.destination.removeValue(destination);
    checkAmount();
    onChanged?.call();
  }

  void setupAccountAmount(SolanaOutputWithBalance destination, BigInt? amount) {
    if (amount == null) return;
    destination.updateBalance(amount);
    checkAmount();
    onChanged?.call();
  }

  void onAddRecever(
      List<ReceiptAddress<SolAddress>>? receiver, StringVoid onExists) {
    if (receiver == null) return;
    MethodUtils.after(() async {
      bool hasExistAccount = false;
      for (final i in receiver) {
        final r = SolanaOutputWithBalance(address: i, token: token);
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
  String? validateError({ISolanaAddress? account}) {
    if (destination.isEmpty) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value) {
      if (!i.hasAmount) {
        return "input_for_each_entery".tr;
      }
      if (i.hasError) {
        return "invalid_address".tr;
      }
    }
    return null;
  }

  @override
  Future<List<TransactionInstruction>> instructions(SolAddress owner) async {
    final error = validateError();
    if (error != null) {
      throw WalletException(error);
    }
    final List<TransactionInstruction> instructions = [];
    for (final i in destination.value) {
      final instruction =
          await i.instruction(owner: owner, client: provider!, token: splToken);
      instructions.addAll(instruction);
    }

    return instructions;
  }

  @override
  SolanaTransactionType get mode => isTokenTransfer
      ? SolanaTransactionType.spl
      : SolanaTransactionType.native;
}

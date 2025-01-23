import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class SolanaMintToForm extends SolanaTransactionForm {
  Token _token =
      Token(name: "unknown_token".tr, symbol: "unknown_token".tr, decimal: 0);
  Token get token => _token;

  void _updateToken() {
    if (mint.hasValue) {
      _token =
          _token.copyWith(name: mint.value!.view, symbol: mint.value!.view);
    } else {
      _token =
          _token.copyWith(name: "unknown_token".tr, symbol: "unknown_token".tr);
    }
  }

  final TransactionFormField<ReceiptAddress<SolAddress>> mint =
      TransactionFormField(
          name: "mint",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> destination =
      TransactionFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> authority =
      TransactionFormField(
          name: "authority",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> programId =
      TransactionFormField(
          name: "program_id",
          optional: false,
          value: ReceiptAddress<SolAddress>(
              networkAddress: SPLTokenProgramConst.tokenProgramId,
              view: SPLTokenProgramConst.tokenProgramId.address,
              type: null),
          onChangeForm: (p0) {
            return p0;
          });

  final TransactionFormField<IntegerBalance> amount = TransactionFormField(
      name: "amount",
      optional: false,
      onChangeForm: (p0) {
        return p0;
      });

  List<TransactionFormField> get fields =>
      [mint, destination, authority, programId, amount];

  SolanaTransferDestinationInfo? _destinationAccount;
  SolanaTransferDestinationInfo? get destinationAccount => _destinationAccount;

  final Cancelable _cancelable = Cancelable();
  final GlobalKey<StreamWidgetState> accountProgressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "SolanaMintToForm_progressKey");

  String? _fetchingAccountError;

  String? get error => _fetchingAccountError;
  bool get hasFetchingAccountError => _fetchingAccountError != null;

  void stopFetchingAccount() {
    _cancelable.cancel();
    _fetchingAccountError = null;
    _destinationAccount = null;
    accountProgressKey.idle();
  }

  Future<void> getDestinationAccountInfo() async {
    stopFetchingAccount();
    if (!mint.hasValue || !destination.hasValue) {
      return;
    }
    accountProgressKey.process();
    final address = destination.value!.networkAddress;
    final result = await MethodUtils.call(() async {
      final info = await provider!.getAccountInfo(address);
      return info;
    }, cancelable: _cancelable);
    if (result.hasError) {
      _fetchingAccountError = result.error!.tr;
    } else {
      if (result.result != null) {
        _destinationAccount = SolanaTransferDestinationInfo(
            account: result.result!, address: address);
      }
    }
    accountProgressKey.idle();
    onChanged?.call();
  }

  @override
  Future<List<TransactionInstruction>> instructions(SolAddress owner) async {
    final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mint.value!.networkAddress,
        owner: destination.value!.networkAddress);
    final mintTo = SPLTokenProgram.mintTo(
        layout: SPLTokenMintToLayout(amount: amount.value!.balance),
        mint: mint.value!.networkAddress,
        destination: pda.address,
        authority: authority.value!.networkAddress);
    final info = await provider!.getAccountInfo(pda.address);
    AssociatedTokenAccountProgram? associatedTokenAccountProgram;
    if (info == null) {
      associatedTokenAccountProgram =
          AssociatedTokenAccountProgram.associatedTokenAccount(
              payer: owner,
              associatedToken: pda.address,
              owner: destination.value!.networkAddress,
              mint: mint.value!.networkAddress,
              tokenProgramId: programId.value!.networkAddress);
    }
    final List<TransactionInstruction> instructions = [
      if (associatedTokenAccountProgram != null) associatedTokenAccountProgram,
      mintTo,
    ];
    return instructions;
  }

  @override
  SolanaTransactionType get mode => SolanaTransactionType.mintTo;

  @override
  String get name => "mint_to";

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      _updateToken();
      onChanged?.call();
    }
  }

  void setDestination(ReceiptAddress<SolAddress>? destinationAccount) {
    if (destinationAccount == null) {
      stopFetchingAccount();
      setValue(destination, destinationAccount);
      return;
    }
    if (destinationAccount.networkAddress.address ==
        destination.value?.networkAddress.address) {
      return;
    }
    setValue(destination, destinationAccount);
    getDestinationAccountInfo();
  }

  void setMintAccount(ReceiptAddress<SolAddress>? mintAcc) {
    if (mintAcc == null) {
      stopFetchingAccount();
      setValue(mint, mintAcc);
      return;
    }
    if (mintAcc.networkAddress.address == mint.value?.networkAddress.address) {
      return;
    }
    setValue(mint, mintAcc);
    getDestinationAccountInfo();
  }

  @override
  BigInt get transferValue => BigInt.zero;

  @override
  String? validateError({ISolanaAddress? account}) {
    if (hasFetchingAccountError) {
      return _fetchingAccountError;
    }
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  @override
  void close() {
    super.close();
    _token =
        Token(name: "unknown_token".tr, symbol: "unknown_token".tr, decimal: 0);
    for (final i in fields) {
      i.clear();
    }
    _cancelable.cancel();
    _destinationAccount = null;
    _fetchingAccountError = null;
  }
}

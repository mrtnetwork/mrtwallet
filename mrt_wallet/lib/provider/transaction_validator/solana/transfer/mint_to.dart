import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator_fields.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaMintToValidator extends SolanaTransactionValidator {
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

  final ValidatorField<ReceiptAddress<SolAddress>> mint = ValidatorField(
      name: "mint",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> destination = ValidatorField(
      name: "destination",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> authority = ValidatorField(
      name: "authority",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> programId = ValidatorField(
      name: "program_id",
      optional: false,
      value: ReceiptAddress<SolAddress>(
          networkAddress: SPLTokenProgramConst.tokenProgramId,
          view: SPLTokenProgramConst.tokenProgramId.address,
          type: null),
      onChangeValidator: (p0) {
        return p0;
      });

  final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
      name: "amount",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields =>
      [mint, destination, authority, programId, amount];

  SolanaAccountInfo? _destinationAccount;
  SolanaAccountInfo? get destinationAccount => _destinationAccount;

  final Cancelable _cancelable = Cancelable();
  final GlobalKey<StreamWidgetState> accountProgressKey =
      GlobalKey<StreamWidgetState>(
          debugLabel: "SolanaMintToValidator_progressKey");

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
    final result = await MethodCaller.call(() async {
      final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
          mint: mint.value!.networkAddress,
          owner: destination.value!.networkAddress);
      final info = await provider!.getAccountInfo(pda.address);
      if (info == null) return info;
    }, cancelable: _cancelable);
    if (result.hasError) {
      _fetchingAccountError = result.error!.tr;
    } else {
      _destinationAccount = result.result;
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
    final List<TransactionInstruction> instructions = [
      if (_destinationAccount == null)
        AssociatedTokenAccountProgram.associatedTokenAccount(
            payer: owner,
            associatedToken: pda.address,
            owner: destination.value!.networkAddress,
            mint: mint.value!.networkAddress,
            tokenProgramId: programId.value!.networkAddress),
      mintTo,
    ];
    return instructions;
  }

  @override
  SolanaTransactionType get mode => SolanaTransactionType.mintTo;

  @override
  String get name => "mint_to";

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
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
}

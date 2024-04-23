import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_type.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaTransferValidator extends SolanaTransactionValidator {
  SolanaTransferValidator({required this.token, this.splToken});
  final Token token;
  final SolanaSPLToken? splToken;
  final GlobalKey<StreamWidgetState> accountKey =
      GlobalKey<StreamWidgetState>();
  SolanaAccountInfo? _accountInfo;
  SolanaAccountInfo? get accountInfo => _accountInfo;
  bool _hasError = false;
  bool get hasErrpr => _hasError;
  bool get isTokenTransfer => splToken != null;

  bool get showRequirementAmountAlert =>
      destination.hasValue &&
      _accountInfo == null &&
      (amount.hasValue &&
          amount.value!.balance < SolanaConstants.systemProgramRent.balance);

  final ValidatorField<ReceiptAddress<SolAddress>> destination = ValidatorField(
      name: "destination",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
    name: "amount",
    optional: false,
    onChangeValidator: (v) {
      try {
        if (v!.isZero || v.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  @override
  OnChangeValidator? onChanged;

  @override
  @override
  List<ValidatorField> get fields => [destination, amount];

  @override
  String get name => "transfer_symbol".tr.replaceOne(token.symbol);

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      if (field == destination) {
        _accountInfo = null;
        if (field.hasValue) {
          updateAccountInfo();
        } else {
          accountKey.updateStream(StreamWidgetStatus.hide);
        }
      }
      onChanged?.call();
    }
  }

  final Cancelable _cancelabel = Cancelable();

  Future<void> updateAccountInfo() async {
    _cancelabel.cancel();
    _hasError = false;
    _accountInfo = null;
    accountKey.updateStream(StreamWidgetStatus.progress);
    final result = await MethodCaller.call(() async {
      final account =
          await provider!.getAccountInfo(destination.value!.networkAddress);
      return account;
    }, cancelable: _cancelabel);
    _hasError = result.hasError;
    if (result.hasResult) {
      _accountInfo = result.result;
    }
    accountKey.updateStream(StreamWidgetStatus.idle);
    onChanged?.call();
  }

  @override
  BigInt get transferValue => amount.value?.balance ?? BigInt.zero;

  @override
  String? validateError({ISolanaAddress? account}) {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  @override
  Future<List<TransactionInstruction>> instructions(SolAddress owner) async {
    final error = validateError();
    if (error != null) {
      throw MessageException(error);
    }
    if (isTokenTransfer) {
      final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
              mint: splToken!.mint, owner: destination.value!.networkAddress)
          .address;
      final exist = await provider!.getAccountInfo(pda);
      TransactionInstruction? ascAccout;
      if (exist == null) {
        ascAccout = AssociatedTokenAccountProgram.associatedTokenAccount(
            payer: owner,
            associatedToken: pda,
            owner: destination.value!.networkAddress,
            mint: splToken!.mint);
      }
      return [
        if (ascAccout != null) ascAccout,
        SPLTokenProgram.transferChecked(
            layout: SPLTokenTransferCheckedLayout(
                amount: amount.value!.balance,
                decimals: splToken!.token.decimal!),
            owner: owner,
            source: splToken!.tokenAccount,
            mint: splToken!.mint,
            destination:
                AssociatedTokenAccountProgramUtils.associatedTokenAccount(
                        mint: splToken!.mint,
                        owner: destination.value!.networkAddress)
                    .address)
      ];
    }
    return [
      SystemProgram.transfer(
          layout: SystemTransferLayout(lamports: amount.value!.balance),
          from: owner,
          to: destination.value!.networkAddress)
    ];
  }

  @override
  SolanaTransactionType get mode => isTokenTransfer
      ? SolanaTransactionType.spl
      : SolanaTransactionType.native;
}

import 'package:blockchain_utils/numbers/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/solana/solana_address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator_fields.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_type.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_validator.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/instructions/instructions.dart';
import 'package:on_chain/solana/src/models/transaction/instruction.dart';

class SolanaCreateAccountValidator extends SolanaTransactionValidator {
  bool _manuallyLamports = false;
  final GlobalKey<StreamWidgetState> rentProgress =
      GlobalKey<StreamWidgetState>(
          debugLabel: "SolanaCreateAccountValidator_rentProgress");

  final ValidatorField<NoneDecimalBalance> lamports = ValidatorField(
      name: "lamports",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> newAccountAddress =
      ValidatorField(
          name: "new_account_address",
          optional: false,
          onChangeValidator: (p0) {
            return p0;
          });
  final ValidatorField<ReceiptAddress<SolAddress>> ownerAddress =
      ValidatorField(
          name: "owner",
          optional: false,
          value: ReceiptAddress<SolAddress>(
              view: SystemProgramConst.programId.address,
              type: null,
              networkAddress: SPLTokenProgramConst.tokenProgramId),
          onChangeValidator: (p0) {
            return p0;
          });
  final ValidatorField<BigRational> space = ValidatorField(
      name: "account_size",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields =>
      [newAccountAddress, ownerAddress, space, lamports];

  final Cancelable _cancelable = Cancelable();

  void changeAssetOutputAddress(ISolanaAddress? changeAddr) {
    if (changeAddr == null ||
        changeAddr.address.toAddress ==
            newAccountAddress.value?.networkAddress.address) return;

    setValue(
        newAccountAddress,
        ReceiptAddress<SolAddress>(
            view: changeAddr.address.toAddress,
            type: changeAddr.type,
            networkAddress: changeAddr.networkAddress));
  }

  Future<void> _getLamportsForRent() async {
    if (_manuallyLamports) return;
    _cancelable.cancel();
    rentProgress.process();
    final lamp = await MethodCaller.call(() async {
      return await provider!.getRent(space.value!.toBigInt().toInt());
    });
    if (lamp.hasResult) {
      setValue(
          lamports, NoneDecimalBalance(lamp.result, SolanaConstants.decimal));
    }
    rentProgress.idle();
  }

  @override
  Future<List<TransactionInstruction>> instructions(SolAddress owner) async {
    final account = SystemProgram.createAccount(
        from: owner,
        newAccountPubKey: newAccountAddress.value!.networkAddress,
        layout: SystemCreateLayout(
            lamports: lamports.value!.balance,
            space: space.value!.toBigInt(),
            programId: ownerAddress.value!.networkAddress));
    return [account];
  }

  @override
  SolanaTransactionType get mode => SolanaTransactionType.createAccount;

  @override
  String get name => "create_account";

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
    }
  }

  void setSpace<T>(BigRational? val) {
    if (val == null) return;
    if (val.toBigInt() == space.value?.toBigInt()) return;
    setValue(
        lamports, NoneDecimalBalance(BigInt.zero, SolanaConstants.decimal));
    setValue(space, val);
    _getLamportsForRent();
  }

  void setLamports(BigInt? val) {
    if (val == null) {
      setValue(lamports, null);
      _manuallyLamports = false;
      return;
    }
    setValue(lamports, NoneDecimalBalance(val, SolanaConstants.decimal));
    _manuallyLamports = true;
  }

  @override
  BigInt get transferValue => lamports.value?.balance ?? BigInt.zero;

  @override
  String? validateError({ISolanaAddress? account}) {
    WalletLogging.print(lamports.hasValue);
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }
}

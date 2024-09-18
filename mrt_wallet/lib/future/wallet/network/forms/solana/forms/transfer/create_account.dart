import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/instructions/instructions.dart';
import 'package:on_chain/solana/src/models/transaction/instruction.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class SolanaCreateAccountForm extends SolanaTransactionForm {
  bool _manuallyLamports = false;
  final GlobalKey<StreamWidgetState> rentProgress =
      GlobalKey<StreamWidgetState>(
          debugLabel: "SolanaCreateAccountForm_rentProgress");

  final TransactionFormField<IntegerBalance> lamports = TransactionFormField(
      name: "lamports",
      optional: false,
      onChangeForm: (p0) {
        return p0;
      });
  final TransactionFormField<ReceiptAddress<SolAddress>> newAccountAddress =
      TransactionFormField(
          name: "new_account_address",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> ownerAddress =
      TransactionFormField(
          name: "owner",
          optional: false,
          value: ReceiptAddress<SolAddress>(
              view: SystemProgramConst.programId.address,
              type: null,
              networkAddress: SPLTokenProgramConst.tokenProgramId),
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<BigRational> space = TransactionFormField(
      name: "account_size",
      optional: false,
      onChangeForm: (p0) {
        return p0;
      });
  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields =>
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
    final lamp = await MethodUtils.call(() async {
      return await provider!.getRent(space.value!.toBigInt().toInt());
    });
    if (lamp.hasResult) {
      setValue(lamports, IntegerBalance(lamp.result, SolanaConst.decimal));
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

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
    }
  }

  void setSpace<T>(BigRational? val) {
    if (val == null) return;
    if (val.toBigInt() == space.value?.toBigInt()) return;
    setValue(lamports, IntegerBalance(BigInt.zero, SolanaConst.decimal));
    setValue(space, val);
    _getLamportsForRent();
  }

  void setLamports(BigInt? val) {
    if (val == null) {
      setValue(lamports, null);
      _manuallyLamports = false;
      return;
    }
    setValue(lamports, IntegerBalance(val, SolanaConst.decimal));
    _manuallyLamports = true;
  }

  @override
  BigInt get transferValue => lamports.value?.balance ?? BigInt.zero;

  @override
  String? validateError({ISolanaAddress? account}) {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }
}

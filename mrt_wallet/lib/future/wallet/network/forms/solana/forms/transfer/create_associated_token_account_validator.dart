import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/instructions/instructions.dart';
import 'package:on_chain/solana/src/models/transaction/instruction.dart';

class SolanaCreateAssociatedTokenAccountForm extends SolanaTransactionForm {
  SolAddress? _assosicatedAddress;
  SolAddress? get assosicatedAddress => _assosicatedAddress;

  void _validate() {
    final error = validateError();
    if (error != null) {
      _assosicatedAddress = null;
    } else {
      _assosicatedAddress =
          AssociatedTokenAccountProgramUtils.associatedTokenAccount(
                  mint: mintAddress.value!.networkAddress,
                  owner: ownerAddress.value!.networkAddress,
                  tokenProgramId: tokenProgram.value!.networkAddress)
              .address;
    }
    onChanged?.call();
  }

  final TransactionFormField<ReceiptAddress<SolAddress>> ownerAddress =
      TransactionFormField(
          name: "owner",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> mintAddress =
      TransactionFormField(
          name: "mint",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> tokenProgram =
      TransactionFormField(
          name: "token_program",
          optional: false,
          value: ReceiptAddress<SolAddress>(
              view: SPLTokenProgramConst.tokenProgramId.address,
              type: null,
              networkAddress: SPLTokenProgramConst.tokenProgramId),
          onChangeForm: (p0) {
            return p0;
          });

  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields =>
      [ownerAddress, mintAddress, tokenProgram];

  @override
  Future<List<TransactionInstruction>> instructions(SolAddress owner) async {
    final create = AssociatedTokenAccountProgram.associatedTokenAccount(
        payer: owner,
        tokenProgramId: tokenProgram.value!.networkAddress,
        associatedToken:
            AssociatedTokenAccountProgramUtils.associatedTokenAccount(
                    mint: mintAddress.value!.networkAddress,
                    owner: ownerAddress.value!.networkAddress,
                    tokenProgramId: tokenProgram.value!.networkAddress)
                .address,
        owner: ownerAddress.value!.networkAddress,
        mint: mintAddress.value!.networkAddress);
    return [create];
  }

  @override
  SolanaTransactionType get mode =>
      SolanaTransactionType.createAssociatedTokenAccount;

  @override
  String get name => "create_associated_token_account";

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      _validate();
    }
  }

  @override
  BigInt get transferValue => BigInt.zero;

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

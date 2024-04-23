import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/solana/solana_address.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator_fields.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_type.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_validator.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/instructions/instructions.dart';
import 'package:on_chain/solana/src/models/transaction/instruction.dart';

class SolanaCreateAssociatedTokenAccountValidator
    extends SolanaTransactionValidator {
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

  final ValidatorField<ReceiptAddress<SolAddress>> ownerAddress =
      ValidatorField(
          name: "owner",
          optional: false,
          onChangeValidator: (p0) {
            return p0;
          });
  final ValidatorField<ReceiptAddress<SolAddress>> mintAddress = ValidatorField(
      name: "mint",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> tokenProgram =
      ValidatorField(
          name: "token_program",
          optional: false,
          value: ReceiptAddress<SolAddress>(
              view: SPLTokenProgramConst.tokenProgramId.address,
              type: null,
              networkAddress: SPLTokenProgramConst.tokenProgramId),
          onChangeValidator: (p0) {
            return p0;
          });

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [ownerAddress, mintAddress, tokenProgram];

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

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
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

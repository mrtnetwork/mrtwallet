import 'package:blockchain_utils/utils/utils.dart';
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

class SolanaInitializeMintValidator extends SolanaTransactionValidator {
  final ValidatorField<ReceiptAddress<SolAddress>> programId = ValidatorField(
      name: "program_id",
      value: ReceiptAddress<SolAddress>(
          view: SPLTokenProgramConst.token2022ProgramId.address,
          type: null,
          networkAddress: SPLTokenProgramConst.token2022ProgramId),
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> mint = ValidatorField(
      name: "mint",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      });
  final ValidatorField<ReceiptAddress<SolAddress>> mintAuthority =
      ValidatorField(
          name: "mint_authority",
          optional: false,
          onChangeValidator: (p0) {
            return p0;
          });
  final ValidatorField<BigRational> decimals = ValidatorField(
      name: "decimals",
      optional: false,
      onChangeValidator: (p0) {
        if (p0 == null) return null;
        if (p0.isNegative) return null;

        return p0;
      });

  final ValidatorField<ReceiptAddress<SolAddress>> freezAuthority =
      ValidatorField(
          name: "freeze_authority",
          onChangeValidator: (p0) {
            return p0;
          });
  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields =>
      [mint, mintAuthority, decimals, freezAuthority];

  @override
  Future<List<TransactionInstruction>> instructions(SolAddress owner) async {
    final instruction = SPLTokenProgram.initializeMint2(
      layout: SPLTokenInitializeMint2Layout(
          decimals: decimals.value!.toBigInt().toInt(),
          mintAuthority: mintAuthority.value!.networkAddress,
          freezeAuthority: freezAuthority.value?.networkAddress),
      mint: mint.value!.networkAddress,
    );
    return [instruction];
  }

  @override
  SolanaTransactionType get mode => SolanaTransactionType.initializeMint;

  @override
  String get name => "initialize_mint";

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
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

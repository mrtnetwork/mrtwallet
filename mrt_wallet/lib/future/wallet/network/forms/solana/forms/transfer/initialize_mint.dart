import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/instructions/instructions.dart';
import 'package:on_chain/solana/src/models/transaction/instruction.dart';

class SolanaInitializeMintForm extends SolanaTransactionForm {
  final TransactionFormField<ReceiptAddress<SolAddress>> programId =
      TransactionFormField(
          name: "program_id",
          value: ReceiptAddress<SolAddress>(
              view: SPLTokenProgramConst.token2022ProgramId.address,
              type: null,
              networkAddress: SPLTokenProgramConst.token2022ProgramId),
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> mint =
      TransactionFormField(
          name: "mint",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<ReceiptAddress<SolAddress>> mintAuthority =
      TransactionFormField(
          name: "mint_authority",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<BigRational> decimals = TransactionFormField(
      name: "decimals",
      optional: false,
      onChangeForm: (p0) {
        if (p0 == null) return null;
        if (p0.isNegative) return null;

        return p0;
      });

  final TransactionFormField<ReceiptAddress<SolAddress>> freezAuthority =
      TransactionFormField(
          name: "freeze_authority",
          onChangeForm: (p0) {
            return p0;
          });
  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields =>
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

  void setValue<T>(TransactionFormField<T>? field, T? value) {
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

import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleSignerListForm implements RippleTransactionForm {
  final TransactionFormField<List<XRPSignerEntries>> signerEntries =
      TransactionFormField(
    name: "SignerEntries",
    subject: "ripple_signer_entries_desc",
    id: "signer_entries",
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<BigRational> signerQuorum = TransactionFormField(
    name: "SignerQuorum",
    subject: "ripple_signer_quorum_desc",
    id: "signer_quorum",
    optional: false,
    onChangeForm: (v) {
      if (v!.isNegative) return null;
      if (v > RippleConst.max32UnsignedRational) return null;
      return v;
    },
  );

  @override
  String? validateError({IXRPAddress? account}) {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name);
      }
    }
    final weight = signerEntries.value?.fold(BigRational.zero,
            (previousValue, element) => previousValue + element.weight) ??
        BigRational.zero;
    if (signerQuorum.value! > weight) {
      return "ripple_signer_quorum_validator".tr;
    }
    return toTransaction(XRPAddressConst.accountZero).validate;
  }

  @override
  List<TransactionFormField> get fields => [signerEntries, signerQuorum];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return SignerListSet(
      signerEntries: signerEntries.value!
          .map((e) => SignerEntry(
              account: e.address.networkAddress.address,
              signerWeight: e.weight.toBigInt().toInt()))
          .toList(),
      signerQuorum: signerQuorum.value!.toBigInt().toInt(),
      account: account.toAddress(),
      sourceTag: account.tag,
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
    );
  }

  @override
  OnChangeForm? onChanged;

  @override
  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
    }
  }

  @override
  String get name => "SignerListSet";
  @override
  String get helperUri => RippleConst.aboutSignerList;
  @override
  String get validatorName => "ripple_signer_list_fields";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {
    final remove = field.value?.removeAt(index);
    if (remove != null) {
      onChanged?.call();
    }
  }

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {
    if (value == null) return;
    if (field != signerEntries) return;
    if (signerEntries.value?.contains(value) ?? false) return;
    if (signerEntries
        .setValue([value as XRPSignerEntries, ...signerEntries.value ?? []])) {
      onChanged?.call();
    }
  }

  @override
  String get validatorDescription => "ripple_set_signer_list_desc";

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.signerListSet;
}

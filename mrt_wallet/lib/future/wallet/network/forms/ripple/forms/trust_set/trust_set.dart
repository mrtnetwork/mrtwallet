import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleTrustSetForm implements RippleTransactionForm {
  final TransactionFormField<XRPCurrencyAmount> amount = TransactionFormField(
    name: "amount",
    subject: "ripple_trust_set_limit_amount",
    optional: false,
    id: "trust_set_limit_amount",
    onChangeForm: (v) {
      try {
        if (v!.amount.isXrp) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  final TransactionFormField<BigRational> qualityIn = TransactionFormField(
    name: "trust_set_quality_in",
    subject: "trust_set_quality_in_desc",
    id: "trust_set_quality_in",
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<BigRational> qualityOut = TransactionFormField(
    name: "trust_set_quality_out",
    subject: "trust_set_quality_out_desc",
    id: "trust_set_quality_out",
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<TrustSetFlag> flag = TransactionFormField(
    name: "trust_set_flags",
    subject: "ripple_trust_set_flags",
    id: "trust_set_flags",
    onChangeForm: (v) {
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
    return toTransaction(XRPAddressConst.accountZero).validate;
  }

  @override
  List<TransactionFormField> get fields =>
      [amount, qualityIn, qualityOut, flag];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return TrustSet(
      limitAmount: amount.value!.amount.isseAmount!,
      account: account.toAddress(),
      sourceTag: account.tag,
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
      qualityIn: qualityIn.value?.toBigInt().toInt(),
      qualityOut: qualityOut.value?.toBigInt().toInt(),
      flags: flag.value?.value,
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
  String get name => "trust_set";

  @override
  String get validatorName => "trust_set_fields";
  @override
  String get validatorDescription => "ripple_trust_set_desc";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  String get helperUri => RippleConst.aboutRippleTrustSet;

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.trustSet;
}

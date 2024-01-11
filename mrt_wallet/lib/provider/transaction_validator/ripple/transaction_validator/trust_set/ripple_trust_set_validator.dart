import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:xrp_dart/xrp_dart.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class RippleTrustSetValidator implements RippleTransactionValidator {
  final ValidatorField<XRPCurrencyAmount> amount = ValidatorField(
    name: "amount",
    subject: "ripple_trust_set_limit_amount",
    optional: false,
    id: "trust_set_limit_amount",
    onChangeValidator: (v) {
      try {
        if (v!.amount.isXrp) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  final ValidatorField<BigRational> qualityIn = ValidatorField(
    name: "trust_set_quality_in",
    subject: "trust_set_quality_in_desc",
    id: "trust_set_quality_in",
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<BigRational> qualityOut = ValidatorField(
    name: "trust_set_quality_out",
    subject: "trust_set_quality_out_desc",
    id: "trust_set_quality_out",
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<TrustSetFlag> flag = ValidatorField(
    name: "trust_set_flags",
    subject: "ripple_trust_set_flags",
    id: "trust_set_flags",
    onChangeValidator: (v) {
      return v;
    },
  );

  @override
  bool get isValid => validateError() == null;

  @override
  String? validateError({IXRPAddress? account}) {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name);
      }
    }
    return toTransaction("").validate;
  }

  @override
  List<ValidatorField> get fields => [amount, qualityIn, qualityOut, flag];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return TrustSet(
        limitAmount: amount.value!.amount.isseAmount!,
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        qualityIn: qualityIn.value?.toBigInt().toInt(),
        qualityOut: qualityOut.value?.toBigInt().toInt(),
        flags: flag.value,
        signingPubKey: signerPublicKey);
  }

  @override
  OnChangeValidator? onChanged;

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
    }
  }

  @override
  String get name => "trust_set";

  @override
  String get fieldsName => "trust_set_fields";
  @override
  String get subject => "ripple_trust_set_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  String get helperUri => RippleConst.aboutRippleTrustSet;

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.trustSet;
}

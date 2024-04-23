import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class RippleRegularKeyValidator implements RippleTransactionValidator {
  final ValidatorField<ReceiptAddress<XRPAddress>> regularKey = ValidatorField(
    name: "regular_key",
    subject: "ripple_regular_key_field_desc",
    id: "regular_key",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
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
    return toTransaction("").validate;
  }

  @override
  List<ValidatorField> get fields => [regularKey];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return SetRegularKey(
        regularKey: regularKey.value!.networkAddress.address,
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
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
  String get name => "SetRegularKey";
  @override
  String get helperUri => RippleConst.aboutRegularKey;
  @override
  String get validatorName => "ripple_set_regular_key_fields";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}
  @override
  String get validatorDescription => "ripple_regular_key_desc";

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.setRegularKey;
}

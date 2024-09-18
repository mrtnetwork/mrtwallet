import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleRegularKeyForm implements RippleTransactionForm {
  final TransactionFormField<ReceiptAddress<XRPAddress>> regularKey =
      TransactionFormField(
    name: "regular_key",
    subject: "ripple_regular_key_field_desc",
    id: "regular_key",
    onChangeForm: (v) {
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
    return toTransaction(XRPAddressConst.accountZero).validate;
  }

  @override
  List<TransactionFormField> get fields => [regularKey];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return SetRegularKey(
      regularKey: regularKey.value!.networkAddress.address,
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
  String get name => "SetRegularKey";
  @override
  String get helperUri => RippleConst.aboutRegularKey;
  @override
  String get validatorName => "ripple_set_regular_key_fields";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}
  @override
  String get validatorDescription => "ripple_regular_key_desc";

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.setRegularKey;
}

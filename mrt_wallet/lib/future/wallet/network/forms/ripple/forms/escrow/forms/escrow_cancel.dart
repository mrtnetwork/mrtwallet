import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleEscrowCancelForm implements RippleTransactionForm {
  final TransactionFormField<ReceiptAddress> owner = TransactionFormField(
    name: "owner",
    subject: "ripple_escrow_cancel_owner",
    id: "escrow_finish_owner",
    optional: false,
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<BigRational> offerSequence = TransactionFormField(
    name: "OfferSequence",
    subject: "ripple_escrow_cancel_offer_sequence",
    optional: false,
    id: "escrow_finish_sequence",
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
  List<TransactionFormField> get fields => [owner, offerSequence];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return EscrowCancel(
      offerSequence: offerSequence.value!.toBigInt().toInt(),
      owner: owner.value!.view,
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
  String get name => "EscrowCancel";
  @override
  String get helperUri => RippleConst.aboutScrowCancel;
  @override
  String get validatorName => "ripple_escrow_cancel_fields";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  String get validatorDescription => "ripple_escrow_cancel_desc";

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.escrowCancel;
}

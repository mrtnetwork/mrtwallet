import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleEscrowFinishForm implements RippleTransactionForm {
  final TransactionFormField<ReceiptAddress> owner = TransactionFormField(
    name: "owner",
    subject: "ripple_escrow_finish_owner",
    id: "escrow_finish_owner",
    optional: false,
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<BigRational> offerSequence = TransactionFormField(
    name: "OfferSequence",
    subject: "ripple_escrow_finish_sequence",
    optional: false,
    id: "escrow_finish_sequence",
    onChangeForm: (v) {
      return v;
    },
  );

  final TransactionFormField<String> condition = TransactionFormField(
    name: "condition",
    subject: "ripple_escrow_finish_condition",
    id: "escrow_create_condition",
    onChangeForm: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final TransactionFormField<String> fulfillment = TransactionFormField(
    name: "Fulfillment",
    subject: "ripple_escrow_finish_fulfillment",
    id: "escrow_finish_fulfillment",
    onChangeForm: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
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
  List<TransactionFormField> get fields => [
        owner,
        offerSequence,
        condition,
        fulfillment,
      ];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return EscrowFinish(
      offerSequence: offerSequence.value!.toBigInt().toInt(),
      owner: owner.value!.view,
      fulfillment: fulfillment.value,
      condition: condition.value,
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
  String get name => "EscrowFinish";

  @override
  String get validatorName => "ripple_escrow_finish_fields";
  @override
  String get helperUri => RippleConst.aboutScrowfinish;

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.escrowFinish;

  @override
  String get validatorDescription => "ripple_escrow_finish_desc";
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class RippleEscrowCreateValidator implements RippleTransactionValidator {
  final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
    name: "amount",
    subject: "ripple_escrow_create_amount",
    id: "escrow_create_amount",
    optional: false,
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<ReceiptAddress> destination = ValidatorField(
    name: "destination",
    subject: "ripple_escrow_create_destionation",
    optional: false,
    id: "escrow_create_destination",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );

  final ValidatorField<DateTime> cancelAfter = ValidatorField(
    name: "CancelAfter",
    subject: "ripple_escrow_create_cancel_after",
    id: "escrow_create_cancel_after",
    onChangeValidator: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final ValidatorField<DateTime> finishAfter = ValidatorField(
    name: "FinishAfter",
    subject: "ripple_escrow_create_finish_after",
    id: "escrow_create_cancel_after",
    onChangeValidator: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final ValidatorField<String> condition = ValidatorField(
    name: "condition",
    subject: "ripple_escrow_create_condition",
    id: "escrow_create_condition",
    onChangeValidator: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final ValidatorField<BigRational> destinationTag = ValidatorField(
    name: "DestinationTag",
    subject: "ripple_escrow_create_destination_tag",
    id: "escrow_create_destination_tag",
    onChangeValidator: (v) {
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
    return toTransaction("").validate;
  }

  @override
  List<ValidatorField> get fields => [
        amount,
        destination,
        cancelAfter,
        finishAfter,
        condition,
        destinationTag
      ];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return EscrowCreate(
        amount: amount.value!.balance,
        destination: destination.value!.view,
        cancelAfterTime: cancelAfter.value,
        finishAfterTime: finishAfter.value,
        condition: condition.value,
        destinationTag: destinationTag.value?.toBigInt().toInt().toString(),
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
  String get helperUri => RippleConst.aboutScrowCreate;
  @override
  String get name => "EscrowCreate";

  @override
  String get validatorName => "ripple_escrow_create_fields";
  @override
  String get validatorDescription => "ripple_escrow_create_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.escrowCreate;
}

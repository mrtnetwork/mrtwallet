import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleEscrowCreateForm implements RippleTransactionForm {
  final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "amount",
    subject: "ripple_escrow_create_amount",
    id: "escrow_create_amount",
    optional: false,
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<ReceiptAddress<XRPAddress>> destination =
      TransactionFormField(
    name: "destination",
    subject: "ripple_escrow_create_destionation",
    optional: false,
    id: "escrow_create_destination",
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );

  final TransactionFormField<DateTime> cancelAfter = TransactionFormField(
    name: "CancelAfter",
    subject: "ripple_escrow_create_cancel_after",
    id: "escrow_create_cancel_after",
    onChangeForm: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final TransactionFormField<DateTime> finishAfter = TransactionFormField(
    name: "FinishAfter",
    subject: "ripple_escrow_create_finish_after",
    id: "escrow_create_cancel_after",
    onChangeForm: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final TransactionFormField<String> condition = TransactionFormField(
    name: "condition",
    subject: "ripple_escrow_create_condition",
    id: "escrow_create_condition",
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
        amount,
        destination,
        cancelAfter,
        finishAfter,
        condition,
      ];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return EscrowCreate(
      amount: amount.value!.balance,
      destination: destination.value!.networkAddress.toAddress(),
      cancelAfterTime: cancelAfter.value,
      finishAfterTime: finishAfter.value,
      condition: condition.value,
      destinationTag: destination.value!.networkAddress.tag?.toString(),
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
  String get helperUri => RippleConst.aboutScrowCreate;
  @override
  String get name => "EscrowCreate";

  @override
  String get validatorName => "ripple_escrow_create_fields";
  @override
  String get validatorDescription => "ripple_escrow_create_desc";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.escrowCreate;
}

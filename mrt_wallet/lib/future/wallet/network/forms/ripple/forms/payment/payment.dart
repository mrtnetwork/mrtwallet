import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class RipplePaymentForm implements RippleTransactionForm {
  RipplePaymentForm({required this.token, this.issueToken});
  final Token token;
  final RippleIssueToken? issueToken;
  late final TransactionFormField<BalanceCore> amount = TransactionFormField(
    name: "amount",
    subject: "",
    optional: false,
    id: "",
    onChangeForm: (v) {
      try {
        if (issueToken != null && v is! DecimalBalance) return null;
        if (issueToken == null && v is! IntegerBalance) return null;
        if (v!.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final TransactionFormField<ReceiptAddress<XRPAddress>> destination =
      TransactionFormField(
    name: "destination",
    subject: "",
    optional: false,
    id: "",
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<String> invoiceId = TransactionFormField(
    name: "invoiceid",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );

  final TransactionFormField<PaymentFlag> flag = TransactionFormField(
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
    if (account != null) {
      if (account.networkAddress.toString() ==
          RippleUtils.ensureClassicAddress(destination.value!.view)) {
        return "ripple_payment_send_to_self_desc";
      }
    }
    return toTransaction(XRPAddressConst.accountZero).validate;
  }

  @override
  List<TransactionFormField> get fields => [amount, destination, flag];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return Payment(
      destination: destination.value!.view,
      destinationTag: destination.value?.networkAddress.tag,
      invoiceId: invoiceId.value == null
          ? null
          : QuickBytesUtils.ensureIsHex(invoiceId.value!),
      amount: issueToken != null
          ? CurrencyAmount.issue(IssuedCurrencyAmount(
              currency: issueToken!.token.name,
              issuer: issueToken!.issuer,
              value: (amount.value!.balance as BigRational).toDecimal()))
          : CurrencyAmount.xrp(amount.value!.balance as BigInt),
      account: account.toAddress(),
      sourceTag: account.tag,
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
      flags: flag.value?.id,
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
  String get name => "Payment";

  @override
  String get validatorName => "ripple_payment_fields";
  @override
  String get helperUri => RippleConst.aboutRipplePayment;
  @override
  String get validatorDescription => "ripple_payment_desc";
  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.payment;
}

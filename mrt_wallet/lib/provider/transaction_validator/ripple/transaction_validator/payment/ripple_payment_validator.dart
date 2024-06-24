import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class RipplePaymentValidator implements RippleTransactionValidator {
  RipplePaymentValidator({required this.token, this.issueToken});
  final Token token;
  final RippleIssueToken? issueToken;
  late final ValidatorField<BalanceCore> amount = ValidatorField(
    name: "amount",
    subject: "",
    optional: false,
    id: "",
    onChangeValidator: (v) {
      try {
        if (issueToken != null && v is! DecimalBalance) return null;
        if (issueToken == null && v is! NoneDecimalBalance) return null;
        if (v!.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final ValidatorField<ReceiptAddress<XRPAddress>> destination = ValidatorField(
    name: "destination",
    subject: "",
    optional: false,
    id: "",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final ValidatorField<String> invoiceId = ValidatorField(
    name: "invoiceid",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );

  final ValidatorField<PaymentFlag> flag = ValidatorField(
    name: "trust_set_flags",
    subject: "ripple_trust_set_flags",
    id: "trust_set_flags",
    onChangeValidator: (v) {
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
  List<ValidatorField> get fields => [amount, destination, flag];

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
  OnChangeValidator? onChanged;

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
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
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.payment;
}

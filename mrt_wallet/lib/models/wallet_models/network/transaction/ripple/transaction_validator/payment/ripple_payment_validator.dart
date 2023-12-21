import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ripple_utils.dart';
import 'package:mrt_wallet/app/utility/bytes_utils/quick_bytes.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/ripple/ripple_issue_token.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RipplePaymentValidator implements RippleTransactionValidator {
  RipplePaymentValidator({this.issueToken});
  Token get token => issueToken?.token ?? NetworkCoins.xrpMainnet.token;
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
  final ValidatorField<ReceiptAddress> destination = ValidatorField(
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
  bool get isValid => validateError() == null;

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
    return toTransaction("").validate;
  }

  @override
  List<ValidatorField> get fields => [amount, destination, flag];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return Payment(
        destination: destination.value!.view,
        invoiceId: invoiceId.value == null
            ? null
            : QuickBytesUtils.ensureIsHex(invoiceId.value!),
        amount: issueToken != null
            ? CurrencyAmount.issue(IssuedCurrencyAmount(
                currency: issueToken!.token.name,
                issuer: issueToken!.issuer,
                value: (amount.value!.balance as BigRational).toDecimal()))
            : CurrencyAmount.xrp(amount.value!.balance as BigInt),
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        flags: flag.value,
        signingPubKey: signerPublicKey);
  }

  @override
  DynamicVoid? onChanged;

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
  String get fieldsName => "ripple_payment_fields";
  @override
  String get helperUri => RippleConst.aboutRipplePayment;
  @override
  String get subject => "ripple_payment_desc";
  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.payment;
}

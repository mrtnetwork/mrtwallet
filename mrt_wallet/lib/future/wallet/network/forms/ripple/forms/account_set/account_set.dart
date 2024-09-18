import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class RippleAccountSetForm implements RippleTransactionForm {
  /// does not need subject or id beacuse has own page
  final TransactionFormField<AccountSetAsfFlag> setFlag = TransactionFormField(
    name: "",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<AccountSetAsfFlag> clearFlag =
      TransactionFormField(
    name: "",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return v;
    },
  );

  final TransactionFormField<String> domain = TransactionFormField(
    name: "domain",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return StrUtils.validateLengthOrNull(v, RippleConst.maxDomainLength)
          ?.toLowerCase();
    },
  );
  final TransactionFormField<String> email = TransactionFormField(
    name: "email_hash",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return StrUtils.validateLengthOrNull(v, RippleConst.maxEmailHashLength);
    },
  );
  final TransactionFormField<String> messageKey = TransactionFormField(
    name: "ripple_message_key",
    subject: "",
    id: "",
    onChangeForm: (v) {
      if (v == null || v.isEmpty) return v;
      return RippleUtils.validateRipplePublicKey(v);
    },
  );

  final TransactionFormField<ReceiptAddress<XRPAddress>> nftokenMinter =
      TransactionFormField(
    name: "ripple_nft_token_minter",
    subject: "",
    id: "",
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<BigRational> transferRate = TransactionFormField(
    name: "ripple_transfer_rate",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return RippleUtils.validateAccoutSetTransferRate(v);
    },
  );

  final TransactionFormField<BigRational> tickSize = TransactionFormField(
    name: "ripple_tick_size",
    subject: "",
    id: "",
    onChangeForm: (v) {
      return RippleUtils.validateAccoutSetTickSize(v);
    },
  );
  String? messageKeyForm(String? v) {
    if (v == null) return "ripple_public_key".tr;
    if (v.isEmpty) return null;
    final isValid = RippleUtils.validateRipplePublicKey(v);
    if (isValid == null) return "ripple_public_key".tr;
    return null;
  }

  String? validateTransferRate(String? v) {
    final BigRational? rate = BigRational.tryParseDecimaal(v ?? "");
    final valid = RippleUtils.validateAccoutSetTransferRate(rate);
    if (valid == null) {
      return "ripple_validate_transfer_rate".tr;
    }
    return null;
  }

  String? validateTickSize(String? v) {
    final BigRational? rate = BigRational.tryParseDecimaal(v ?? "");
    final valid = RippleUtils.validateAccoutSetTickSize(rate);
    if (valid == null) {
      return "ripple_validate_tick_size".tr;
    }
    return null;
  }

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
        setFlag,
        clearFlag,
        domain,
        email,
        messageKey,
        nftokenMinter,
        transferRate,
        tickSize
      ];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return AccountSet(
      account: account.address,
      setFlag: setFlag.value,
      clearFlag: clearFlag.value,
      domain:
          domain.hasValue ? QuickBytesUtils.ensureIsHex(domain.value!) : null,
      emailHash: email.hasValue
          ? QuickBytesUtils.ensureHexWithLength(
              email.value!, RippleConst.maxEmailHashLength)
          : null,
      fee: fee,
      memos: RippleUtils.toXrplMemos(memos),
      messageKey: messageKey.value,
      nftTokenMinter: nftokenMinter.value?.networkAddress.address,
      tickSize: tickSize.value?.toBigInt().toInt(),
      transferRate: transferRate.value?.toBigInt().toInt(),
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
  String get helperUri => RippleConst.aboutRippleAccountSet;
  @override
  String get name => "account_set";

  @override
  String get validatorName => "account_set_fields";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.accountSet;

  @override
  String get validatorDescription => "account_set_desc";
}

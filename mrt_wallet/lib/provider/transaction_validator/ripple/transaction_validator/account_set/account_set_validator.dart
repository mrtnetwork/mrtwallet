import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:xrp_dart/xrp_dart.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class RippleAccountSetValidator implements RippleTransactionValidator {
  /// does not need subject or id beacuse has own page
  final ValidatorField<AccountSetAsfFlag> setFlag = ValidatorField(
    name: "",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<AccountSetAsfFlag> clearFlag = ValidatorField(
    name: "",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return v;
    },
  );

  final ValidatorField<String> domain = ValidatorField(
    name: "domain",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return AppStringUtility.validateLengthOrNull(
              v, RippleConst.maxDomainLength)
          ?.toLowerCase();
    },
  );
  final ValidatorField<String> email = ValidatorField(
    name: "email_hash",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return AppStringUtility.validateLengthOrNull(
          v, RippleConst.maxEmailHashLength);
    },
  );
  final ValidatorField<String> messageKey = ValidatorField(
    name: "ripple_message_key",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      if (v == null || v.isEmpty) return v;
      return RippleUtils.validateRipplePublicKey(v);
    },
  );

  final ValidatorField<ReceiptAddress<XRPAddress>> nftokenMinter =
      ValidatorField(
    name: "ripple_nft_token_minter",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final ValidatorField<BigRational> transferRate = ValidatorField(
    name: "ripple_transfer_rate",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return RippleUtils.validateAccoutSetTransferRate(v);
    },
  );

  final ValidatorField<BigRational> tickSize = ValidatorField(
    name: "ripple_tick_size",
    subject: "",
    id: "",
    onChangeValidator: (v) {
      return RippleUtils.validateAccoutSetTickSize(v);
    },
  );
  String? messageKeyValidator(String? v) {
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
  bool get isValid => validateError() == null;

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
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return AccountSet(
      account: account,
      setFlag: setFlag.value,
      clearFlag: clearFlag.value,
      signingPubKey: signerPublicKey,
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
  OnChangeValidator? onChanged;

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
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
  String get fieldsName => "account_set_fields";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.accountSet;

  @override
  String get subject => "account_set_desc";
}

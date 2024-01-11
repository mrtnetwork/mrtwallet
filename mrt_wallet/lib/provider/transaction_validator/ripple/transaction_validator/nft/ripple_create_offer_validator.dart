import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleCreateOfferValidator implements RippleTransactionValidator {
  RippleCreateOfferValidator({String? offerID}) {
    if (offerID != null) {
      setValue(nftokenId, offerID);
    }
  }

  final ValidatorField<String> nftokenId = ValidatorField(
    name: "token_id",
    subject: "ripple_create_nft_offer_id",
    id: "offer_token_id",
    optional: false,
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<ReceiptAddress> owner = ValidatorField(
    name: "owner",
    subject: "ripple_create_offer_owner",
    id: "offer_owner",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final ValidatorField<DateTime> expiration = ValidatorField(
    name: "expiration",
    subject: "ripple_create_offer_expiration",
    id: "offer_expiration",
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<ReceiptAddress> destination = ValidatorField(
    name: "destination",
    subject: "ripple_create_offer_destination",
    id: "offer_destination",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final ValidatorField<XRPCurrencyAmount> amount = ValidatorField(
    name: "amount",
    subject: "ripple_create_nft_offer_amount",
    optional: false,
    id: "offer_amount",
    onChangeValidator: (v) {
      try {
        if (v!.amount.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  final ValidatorField<NftTokenCreateOfferFlag> flags = ValidatorField(
    name: "NFTokenCreateOfferFlags",
    subject: "nft_offer_flag_desc",
    id: "nft_offer_flag",
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
    return toTransaction("").validate;
  }

  @override
  List<ValidatorField> get fields =>
      [nftokenId, owner, expiration, destination, amount, flags];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return NFTokenCreateOffer(
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        flags: flags.value,
        amount: amount.value!.amount,
        nftokenId: nftokenId.value!,
        destination: destination.value?.view,
        expiration: expiration.hasValue
            ? XRPHelper.datetimeToRippleTime(expiration.value!)
            : null,
        owner: owner.value?.view,
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
  String get helperUri => RippleConst.aboutNftokenCreateOffer;
  @override
  String get name => "NFTokenCreateOffer";
  @override
  String get fieldsName => "ripple_nftoken_create_offer_fields";

  @override
  String get subject => "ripple_create_nftoken_offer_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType =>
      XRPLTransactionType.nftokenCreateOffer;
}

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class RippleAcceptNFTOfferValidator implements RippleTransactionValidator {
  final ValidatorField<String> nftokenSellOffer = ValidatorField(
    name: "NFTokenSellOffer",
    subject: "ripple_accept_offer_sell_offer",
    id: "accept_offer_sell_offer",
    onChangeValidator: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );
  final ValidatorField<String> nftokenBuyOffer = ValidatorField(
    name: "NFTokenBuyOffer",
    subject: "ripple_accept_offer_buy_offer",
    id: "accept_offer_buy_offer",
    onChangeValidator: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );

  final ValidatorField<XRPCurrencyAmount> nftokenBrokerFee = ValidatorField(
    name: "amount",
    subject: "ripple_accept_offer_broker_fee",
    id: "accept_nft_broker_fee",
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
      [nftokenBrokerFee, nftokenBuyOffer, nftokenSellOffer];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return NFTokenAcceptOffer(
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        nfTokenBrokerFee: nftokenBrokerFee.value?.amount,
        nfTokenBuyOffer: nftokenBuyOffer.value,
        nfTokenSellOffer: nftokenSellOffer.value,
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
  String get name => "NFTokenAcceptOffer";
  @override
  String get fieldsName => "ripple_nftoken_accept_offer_fields";
  @override
  String get helperUri => RippleConst.aboutNftAcceptOffer;

  @override
  String get subject => "ripple_accept_offer_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType =>
      XRPLTransactionType.nftokenAcceptOffer;
}

import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ripple_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleCancelOfferValidator implements RippleTransactionValidator {
  RippleCancelOfferValidator({String? offerID}) {
    if (offerID != null) {
      setValue(nftokenOffers, [offerID, ...nftokenOffers.value ?? []]);
    }
  }
  final ValidatorField<List<String>> nftokenOffers = ValidatorField(
    name: "NFTokenOffers",
    subject: "ripple_cancel_nft_token_nftoken_offers",
    id: "cancel_nft_nft_token_offers",
    optional: false,
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
  List<ValidatorField> get fields => [nftokenOffers];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return NFTokenCancelOffer(
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        nftokenOffers: nftokenOffers.value!,
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
  String get name => "NFTokenCancelOffer";
  @override
  String get helperUri => RippleConst.abountNftokenCancelOffer;
  @override
  String get fieldsName => "ripple_nftoken_cancel_offer_fields";

  @override
  String get subject => "ripple_nftoken_cancel_offer_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {
    final remove = field.value?.removeAt(index);
    if (remove != null) {
      onChanged?.call();
    }
  }

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {
    if (value == null) return;
    if (nftokenOffers.value?.contains(value) ?? false) return;
    if (nftokenOffers
        .setValue([value as String, ...nftokenOffers.value ?? []])) {
      onChanged?.call();
    }
  }

  @override
  XRPLTransactionType get transactionType =>
      XRPLTransactionType.nftokenCancelOffer;
}

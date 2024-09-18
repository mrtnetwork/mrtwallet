import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleCancelOfferForm implements RippleTransactionForm {
  RippleCancelOfferForm({String? offerID}) {
    if (offerID != null) {
      setValue(nftokenOffers, <String>[offerID, ...nftokenOffers.value ?? []]);
    }
  }
  final TransactionFormField<List<String>> nftokenOffers = TransactionFormField(
    name: "NFTokenOffers",
    subject: "ripple_cancel_nft_token_nftoken_offers",
    id: "cancel_nft_nft_token_offers",
    optional: false,
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
    return toTransaction(XRPAddressConst.accountZero).validate;
  }

  @override
  List<TransactionFormField> get fields => [nftokenOffers];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return NFTokenCancelOffer(
      account: account.toAddress(),
      sourceTag: account.tag,
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
      nftokenOffers: nftokenOffers.value!,
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
  String get name => "NFTokenCancelOffer";
  @override
  String get helperUri => RippleConst.abountNftokenCancelOffer;
  @override
  String get validatorName => "ripple_nftoken_cancel_offer_fields";

  @override
  String get validatorDescription => "ripple_nftoken_cancel_offer_desc";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {
    final remove = field.value?.removeAt(index);
    if (remove != null) {
      onChanged?.call();
    }
  }

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {
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

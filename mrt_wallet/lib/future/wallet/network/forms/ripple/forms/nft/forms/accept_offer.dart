import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class RippleAcceptNFTOfferForm implements RippleTransactionForm {
  final TransactionFormField<String> nftokenSellOffer = TransactionFormField(
    name: "NFTokenSellOffer",
    subject: "ripple_accept_offer_sell_offer",
    id: "accept_offer_sell_offer",
    onChangeForm: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );
  final TransactionFormField<String> nftokenBuyOffer = TransactionFormField(
    name: "NFTokenBuyOffer",
    subject: "ripple_accept_offer_buy_offer",
    id: "accept_offer_buy_offer",
    onChangeForm: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );

  final TransactionFormField<XRPCurrencyAmount> nftokenBrokerFee =
      TransactionFormField(
    name: "amount",
    subject: "ripple_accept_offer_broker_fee",
    id: "accept_nft_broker_fee",
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
  List<TransactionFormField> get fields =>
      [nftokenBrokerFee, nftokenBuyOffer, nftokenSellOffer];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return NFTokenAcceptOffer(
      account: account.toAddress(),
      sourceTag: account.tag,
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
      nfTokenBrokerFee: nftokenBrokerFee.value?.amount,
      nfTokenBuyOffer: nftokenBuyOffer.value,
      nfTokenSellOffer: nftokenSellOffer.value,
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
  String get name => "NFTokenAcceptOffer";
  @override
  String get validatorName => "ripple_nftoken_accept_offer_fields";
  @override
  String get helperUri => RippleConst.aboutNftAcceptOffer;

  @override
  String get validatorDescription => "ripple_accept_offer_desc";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType =>
      XRPLTransactionType.nftokenAcceptOffer;
}

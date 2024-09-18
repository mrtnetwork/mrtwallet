import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class RippleCreateOfferForm implements RippleTransactionForm {
  RippleCreateOfferForm({String? offerID}) {
    if (offerID != null) {
      setValue(nftokenId, offerID);
    }
  }

  final TransactionFormField<String> nftokenId = TransactionFormField(
    name: "token_id",
    subject: "ripple_create_nft_offer_id",
    id: "offer_token_id",
    optional: false,
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<ReceiptAddress> owner = TransactionFormField(
    name: "owner",
    subject: "ripple_create_offer_owner",
    id: "offer_owner",
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<DateTime> expiration = TransactionFormField(
    name: "expiration",
    subject: "ripple_create_offer_expiration",
    id: "offer_expiration",
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<ReceiptAddress> destination = TransactionFormField(
    name: "destination",
    subject: "ripple_create_offer_destination",
    id: "offer_destination",
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<XRPCurrencyAmount> amount = TransactionFormField(
    name: "amount",
    subject: "ripple_create_nft_offer_amount",
    optional: false,
    id: "offer_amount",
    onChangeForm: (v) {
      try {
        if (v!.amount.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  final TransactionFormField<NftTokenCreateOfferFlag> flags =
      TransactionFormField(
    name: "NFTokenCreateOfferFlags",
    subject: "nft_offer_flag_desc",
    id: "nft_offer_flag",
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
      [nftokenId, owner, expiration, destination, amount, flags];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return NFTokenCreateOffer(
      account: account.toAddress(),
      sourceTag: account.tag,
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
      flags: flags.value?.value,
      amount: amount.value!.amount,
      nftokenId: nftokenId.value!,
      destination: destination.value?.view,
      expiration: expiration.hasValue
          ? XRPHelper.datetimeToRippleTime(expiration.value!)
          : null,
      owner: owner.value?.view,
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
  String get helperUri => RippleConst.aboutNftokenCreateOffer;
  @override
  String get name => "NFTokenCreateOffer";
  @override
  String get validatorName => "ripple_nftoken_create_offer_fields";

  @override
  String get validatorDescription => "ripple_create_nftoken_offer_desc";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType =>
      XRPLTransactionType.nftokenCreateOffer;
}

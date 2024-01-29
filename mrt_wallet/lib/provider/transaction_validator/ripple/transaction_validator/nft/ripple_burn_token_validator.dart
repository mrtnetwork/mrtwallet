import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippeBurnTokenValidator implements RippleTransactionValidator {
  RippeBurnTokenValidator({String? offerID}) {
    if (offerID != null) {
      setValue(nftokenId, offerID);
    }
  }

  final ValidatorField<String> nftokenId = ValidatorField(
    name: "token_id",
    subject: "ripple_nftoken_burn_id",
    id: "burn_token_id",
    optional: false,
    onChangeValidator: (v) {
      return QuickBytesUtils.ensureIsHash256(v);
    },
  );
  final ValidatorField<ReceiptAddress> owner = ValidatorField(
    name: "owner",
    id: "burn_owner",
    subject: "ripple_nftoken_burn_owner",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
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
  List<ValidatorField> get fields => [nftokenId, owner];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return NFTokenBurn(
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        nfTokenId: nftokenId.value!,
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
  String get name => "NFTokenBurn";

  @override
  String get fieldsName => "ripple_nftoken_burn_fields";
  @override
  String get helperUri => RippleConst.aboutNftokenBurn;
  @override
  String get subject => "ripple_nftoken_burn_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.nftokenBurn;
}

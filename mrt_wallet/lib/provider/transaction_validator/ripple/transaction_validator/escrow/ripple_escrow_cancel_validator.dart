import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/core/ripple_field_validator.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleEscrowCancelValidator implements RippleTransactionValidator {
  final ValidatorField<ReceiptAddress> owner = ValidatorField(
    name: "owner",
    subject: "ripple_escrow_cancel_owner",
    id: "escrow_finish_owner",
    optional: false,
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final ValidatorField<BigRational> offerSequence = ValidatorField(
    name: "OfferSequence",
    subject: "ripple_escrow_cancel_offer_sequence",
    optional: false,
    id: "escrow_finish_sequence",
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
  List<ValidatorField> get fields => [owner, offerSequence];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return EscrowCancel(
        offerSequence: offerSequence.value!.toBigInt().toInt(),
        owner: owner.value!.view,
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
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
  String get name => "EscrowCancel";
  @override
  String get helperUri => RippleConst.aboutScrowCancel;
  @override
  String get fieldsName => "ripple_escrow_cancel_fields";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}
  @override
  String get subject => "ripple_escrow_cancel_desc";

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.escrowCancel;
}

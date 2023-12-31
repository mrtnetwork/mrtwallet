import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ripple_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:xrp_dart/xrp_dart.dart';
class RippleSignerListValidator implements RippleTransactionValidator {
  final ValidatorField<List<XRPSignerEntries>> signerEntries = ValidatorField(
    name: "SignerEntries",
    subject: "ripple_signer_entries_desc",
    id: "signer_entries",
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<BigRational> signerQuorum = ValidatorField(
    name: "SignerQuorum",
    subject: "ripple_signer_quorum_desc",
    id: "signer_quorum",
    optional: false,
    onChangeValidator: (v) {
      if (v!.isNegative) return null;
      if (v > RippleConst.max32UnsignedRational) return null;
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
    final weight = signerEntries.value?.fold(BigRational.zero,
            (previousValue, element) => previousValue + element.weight) ??
        BigRational.zero;
    if (signerQuorum.value! > weight) {
      return "ripple_signer_quorum_validator".tr;
    }
    return toTransaction("").validate;
  }

  @override
  List<ValidatorField> get fields => [signerEntries, signerQuorum];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return SignerListSet(
        signerEntries: signerEntries.value!
            .map((e) => SignerEntry(
                account: e.address.view,
                signerWeight: e.weight.toBigInt().toInt()))
            .toList(),
        signerQuorum: signerQuorum.value!.toBigInt().toInt(),
        account: account,
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
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
  String get name => "SignerListSet";
  @override
  String get helperUri => RippleConst.aboutSignerList;
  @override
  String get fieldsName => "ripple_signer_list_fields";

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
    if (field != signerEntries) return;
    if (signerEntries.value?.contains(value) ?? false) return;
    if (signerEntries
        .setValue([value as XRPSignerEntries, ...signerEntries.value ?? []])) {
      onChanged?.call();
    }
  }

  @override
  String get subject => "ripple_set_signer_list_desc";

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.signerListSet;
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ripple_utils.dart';
import 'package:mrt_wallet/app/utility/bytes_utils/quick_bytes.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleMintTokenValidator implements RippleTransactionValidator {
  final ValidatorField<BigRational> nftokenTaxon = ValidatorField(
    name: "NFTokenTaxon",
    subject: "ripple_nftokentaxon",
    optional: false,
    id: "mint_nftokentaxon",
    onChangeValidator: (v) {
      if (v!.isNegative) return null;
      if (v > RippleConst.max32UnsignedRational) return null;
      return v;
    },
  );
  final ValidatorField<ReceiptAddress> issuer = ValidatorField(
    name: "issuer",
    subject: "ripple_mint_token_issuer",
    id: "mint_issuer",
    onChangeValidator: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final ValidatorField<BigRational> transferFee = ValidatorField(
    name: "ripple_transfer_rate",
    subject: "ripple_mint_token_transfer_rate",
    id: "mint_transfer_fee",
    onChangeValidator: (v) {
      if (v!.isNegative) return null;
      if (v > RippleConst.maxNftTokenTransferRate) return null;
      return v;
    },
  );
  final ValidatorField<String> uri = ValidatorField(
    name: "uri",
    subject: "nft_token_uri",
    id: "mint_uri",
    onChangeValidator: (v) {
      if (v!.length > RippleConst.maxDomainLength) return null;
      return v;
    },
  );
  final ValidatorField<NFTokenMintFlag> flags = ValidatorField(
    name: "NFTokenMintFlag",
    subject: "nft_flags_field_desc",
    id: "mint_flag",
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
      [nftokenTaxon, issuer, transferFee, uri, flags];

  @override
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee}) {
    return NFTokenMint(
        nftokenTaxon: nftokenTaxon.value!.toBigInt().toInt(),
        account: account,
        issuer: issuer.value?.view,
        flags: flags.value,
        uri: uri.value == null ? null : QuickBytesUtils.ensureIsHex(uri.value!),
        memos: RippleUtils.toXrplMemos(memos),
        fee: fee,
        transferFee: transferFee.value?.toBigInt().toInt(),
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
  String get name => "NFTokenMint";
  @override
  String get fieldsName => "ripple_nfttoken_fields";
  @override
  String get helperUri => RippleConst.aboutNftoken;
  @override
  String get subject => "ripple_mint_nftoken_desc";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.nftokenMint;
}

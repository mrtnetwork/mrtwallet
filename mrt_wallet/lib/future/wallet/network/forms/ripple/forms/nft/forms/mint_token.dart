import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ripple/forms/core/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class RippleMintTokenForm implements RippleTransactionForm {
  final TransactionFormField<BigRational> nftokenTaxon = TransactionFormField(
    name: "NFTokenTaxon",
    subject: "ripple_nftokentaxon",
    optional: false,
    id: "mint_nftokentaxon",
    onChangeForm: (v) {
      if (v!.isNegative) return null;
      if (v > RippleConst.max32UnsignedRational) return null;
      return v;
    },
  );
  final TransactionFormField<ReceiptAddress<XRPAddress>> issuer =
      TransactionFormField(
    name: "issuer",
    subject: "ripple_mint_token_issuer",
    id: "mint_issuer",
    onChangeForm: (v) {
      if (RippleUtils.ensureIsRippleAddress(v!.view) == null) return null;
      return v;
    },
  );
  final TransactionFormField<BigRational> transferFee = TransactionFormField(
    name: "ripple_transfer_rate",
    subject: "ripple_mint_token_transfer_rate",
    id: "mint_transfer_fee",
    onChangeForm: (v) {
      if (v!.isNegative) return null;
      if (v > RippleConst.maxNftTokenTransferRate) return null;
      return v;
    },
  );
  final TransactionFormField<String> uri = TransactionFormField(
    name: "uri",
    subject: "nft_token_uri",
    id: "mint_uri",
    onChangeForm: (v) {
      if (v!.length > RippleConst.maxDomainLength) return null;
      return v;
    },
  );
  final TransactionFormField<NFTokenMintFlag> flags = TransactionFormField(
    name: "NFTokenMintFlag",
    subject: "nft_flags_field_desc",
    id: "mint_flag",
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
      [nftokenTaxon, issuer, transferFee, uri, flags];

  @override
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee}) {
    return NFTokenMint(
      nftokenTaxon: nftokenTaxon.value!.toBigInt().toInt(),
      account: account.toAddress(),
      sourceTag: account.tag,
      issuer: issuer.value?.networkAddress.address,
      flags: flags.value?.value,
      uri: uri.value == null ? null : QuickBytesUtils.ensureIsHex(uri.value!),
      memos: RippleUtils.toXrplMemos(memos),
      fee: fee,
      transferFee: transferFee.value?.toBigInt().toInt(),
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
  String get name => "NFTokenMint";
  @override
  String get validatorName => "ripple_nfttoken_fields";
  @override
  String get helperUri => RippleConst.aboutNftoken;
  @override
  String get validatorDescription => "ripple_mint_nftoken_desc";

  @override
  void removeIndex<T>(TransactionFormField<List<T>> field, int index) {}

  @override
  void setListValue<T>(TransactionFormField<List<T>> field, T? value) {}

  @override
  XRPLTransactionType get transactionType => XRPLTransactionType.nftokenMint;
}

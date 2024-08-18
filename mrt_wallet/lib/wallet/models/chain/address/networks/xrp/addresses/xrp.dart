import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/networks/ripple.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'multisig.dart';

enum XrpAddressType {
  xAddress("x_address"),
  classic("classic_address");

  final String value;
  const XrpAddressType(this.value);
}

class IXRPAddress
    extends ChainAccount<XRPAddress, RippleIssueToken, RippleNFToken>
    with Equatable {
  IXRPAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required this.tag,
      required this.curveType,
      required List<RippleIssueToken> tokens,
      required List<RippleNFToken> nfts,
      String? accountName})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName,
        addressType =
            tag == null ? XrpAddressType.classic : XrpAddressType.xAddress;

  factory IXRPAddress.newAccount(
      {required RippleNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletXRPNetwork network}) {
    final keyAlgorithm = XRPKeyAlgorithm.values
        .firstWhere((e) => e.curveType == accountParams.curve);
    final rippleAddress = RippleUtils.publicKeyToRippleAddress(publicKey,
        algorithm: keyAlgorithm,
        tag: accountParams.tag,
        isTenstNet: !network.coinParam.mainnet);

    final addressDetails = AccountBalance(
        address: rippleAddress.toAddress(),
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return IXRPAddress._(
      coin: accountParams.coin,
      publicKey: publicKey,
      address: addressDetails,
      keyIndex: accountParams.deriveIndex,
      networkAddress: rippleAddress,
      network: network.value,
      tag: accountParams.tag,
      curveType: accountParams.curve,
      tokens: const [],
      nfts: const [],
    );
  }
  factory IXRPAddress.fromCbsorHex(WalletNetwork network, String hex) {
    return IXRPAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IXRPAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.rippleMultisigAccount)) {
      return IXRPMultisigAddress.fromCborBytesOrObject(network, obj: toCborTag);
    }

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.rippleAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(7);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));
    final XRPAddress rippleAddress = XRPAddress(cbor.elementAt(5));
    final int? tag = cbor.elementAt(6);
    final List<RippleIssueToken>? issueTokens = cbor
        .elementAt<List<dynamic>?>(8)
        ?.map((e) => RippleIssueToken.fromCborBytesOrObject(obj: e))
        .toList();
    final List<RippleNFToken>? nfts = cbor
        .elementAt<List<dynamic>?>(9)
        ?.map((e) => RippleNFToken.fromCborBytesOrObject(obj: e))
        .toList();

    final String? curveName = cbor.elementAt(10);
    final curveType = curveName == null
        ? EllipticCurveTypes.secp256k1
        : EllipticCurveTypes.fromName(curveName);
    final String? accountName = cbor.elementAt(11);
    return IXRPAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: rippleAddress,
        network: networkId,
        tag: tag,
        curveType: curveType,
        tokens: issueTokens ?? [],
        nfts: nfts ?? [],
        accountName: accountName);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final AccountBalance address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          networkAddress.toAddress(),
          tag == null ? const CborNullValue() : CborIntValue(tag!),
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          curveType.name,
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.rippleAccount);
  }

  @override
  List get variabels {
    return [tag, keyIndex, network];
  }

  @override
  final XRPAddress networkAddress;
  final XrpAddressType addressType;
  final EllipticCurveTypes curveType;
  final int? tag;

  @override
  String get type => addressType.value;

  List<RippleIssueToken> _tokens;
  @override
  List<RippleIssueToken> get tokens => _tokens;

  List<RippleNFToken> _nfts;
  @override
  List<RippleNFToken> get nfts => _nfts;

  @override
  void addToken(RippleIssueToken newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = List.unmodifiable([newToken, ..._tokens]);
  }

  @override
  void updateToken(RippleIssueToken token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    List<RippleIssueToken> existTokens = List<RippleIssueToken>.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void removeToken(RippleIssueToken token) {
    if (!tokens.contains(token)) return;
    final existTokens = List.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void addNFT(RippleNFToken newNft) {
    if (_nfts.contains(newNft)) {
      throw WalletExceptionConst.nftsAlreadyExist;
    }
    _nfts = List.unmodifiable([newNft, ..._nfts]);
  }

  @override
  void removeNFT(RippleNFToken nft) {
    if (!_nfts.contains(nft)) return;
    final existNfts = List.from(_nfts);
    existNfts.removeWhere((element) => element == nft);
    _nfts = List.unmodifiable(_nfts);
  }

  @override
  bool get multiSigAccount => false;

  String? _accountName;
  @override
  String? get accountName => _accountName;

  @override
  void setAccountName(String? name) {
    _accountName = name;
  }

  @override
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! IXRPAddress) return false;
    return networkAddress.address == other.networkAddress.address &&
        networkAddress.tag == other.networkAddress.tag &&
        multiSigAccount == other.multiSigAccount;
  }

  @override
  RippleNewAddressParams toAccountParams() {
    return RippleNewAddressParams(deriveIndex: keyIndex, coin: coin, tag: tag);
  }
}

class IXRPMultisigAddress extends IXRPAddress
    implements MultiSigCryptoAccountAddress {
  IXRPMultisigAddress._(
      {required super.address,
      required super.network,
      required super.coin,
      required super.networkAddress,
      required super.nfts,
      required super.tag,
      required super.tokens,
      required this.multiSignatureAccount,
      String? accountName})
      : super._(
            keyIndex: const MultiSigAddressIndex(),
            curveType: EllipticCurveTypes.secp256k1,
            publicKey: const [],
            accountName: accountName);
  @override
  RippleMultiSigNewAddressParams toAccountParams() {
    return RippleMultiSigNewAddressParams(
        coin: coin,
        tag: tag,
        masterAddress: networkAddress,
        multiSigAccount: multiSignatureAccount);
  }

  factory IXRPMultisigAddress.newAccount(
      {required RippleMultiSigNewAddressParams accountParams,
      required WalletXRPNetwork network}) {
    final addressDetails = AccountBalance(
        address: accountParams.tag == null
            ? accountParams.masterAddress.toString()
            : accountParams.masterAddress.toXAddress(
                tag: accountParams.tag, isTestnet: !network.coinParam.mainnet),
        balance: IntegerBalance.zero(network.coinParam.decimal));

    return IXRPMultisigAddress._(
        coin: accountParams.coin,
        multiSignatureAccount: accountParams.multiSigAccount,
        address: addressDetails,
        networkAddress: XRPAddress(addressDetails.address),
        network: network.value,
        tag: accountParams.tag,
        tokens: const [],
        nfts: const []);
  }
  factory IXRPMultisigAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue values = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.rippleMultisigAccount);
    final CoinProposal proposal = CoinProposal.fromName(values.elementAt(0));
    final CryptoCoins coin =
        CryptoCoins.getCoin(values.elementAt(1), proposal)!;

    final int networkId = values.elementAt(7);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(4));

    final XRPAddress rippleAddress = XRPAddress(values.elementAt(5));
    int? tag = values.elementAt(6);

    final List<RippleIssueToken> issueTokens = values
        .elementAt<List<dynamic>>(8)
        .map((e) => RippleIssueToken.fromCborBytesOrObject(obj: e))
        .toList();
    final List<RippleNFToken> accountNfts = values
        .elementAt<List<dynamic>>(9)
        .map((e) => RippleNFToken.fromCborBytesOrObject(obj: e))
        .toList();
    RippleMultiSignatureAddress multiSigAccount =
        RippleMultiSignatureAddress.fromCborBytesOrObject(
            obj: values.getCborTag(11));
    final String? accountName = values.elementAt(12);
    return IXRPMultisigAddress._(
        coin: coin,
        address: address,
        networkAddress: rippleAddress,
        network: networkId,
        tag: tag,
        tokens: issueTokens,
        multiSignatureAccount: multiSigAccount,
        nfts: accountNfts,
        accountName: accountName);
  }

  final RippleMultiSignatureAddress multiSignatureAccount;
  @override
  List<int> get publicKey => throw UnimplementedError();
  @override
  EllipticCurveTypes get curveType => throw UnimplementedError();

  @override
  List get variabels {
    return [tag, keyIndex, network, multiSignatureAccount];
  }

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          const CborNullValue(),
          const CborNullValue(),
          address.toCbor(),
          networkAddress.toAddress(),
          tag == null ? const CborNullValue() : CborIntValue(tag!),
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          const CborNullValue(),
          multiSignatureAccount.toCbor(),
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.rippleMultisigAccount);
  }

  @override
  bool get multiSigAccount => true;

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAccount.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();
}

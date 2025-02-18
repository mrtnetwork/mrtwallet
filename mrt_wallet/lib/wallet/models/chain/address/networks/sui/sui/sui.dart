import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
// import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/sui.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/networks/sui/models/types.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:on_chain/sui/sui.dart';

import 'multisig.dart';

class ISuiAddress extends ChainAccount<SuiAddress, SuiToken, NFTCore>
    with Equatable {
  ISuiAddress._(
      {required this.keyIndex,
      required this.coin,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<SuiToken> tokens,
      required List<NFTCore> nfts,
      required List<int> publicKey,
      required this.keyScheme,
      String? accountName})
      : _tokens = tokens.immutable,
        _nfts = nfts.immutable,
        _accountName = accountName,
        publicKey = publicKey.asImmutableBytes;

  factory ISuiAddress.newAccount(
      {required SuiNewAddressParams accountParams,
      required SuiAddress address,
      required WalletSuiNetwork network,
      required List<int> publicKey}) {
    final addressDetauls = AccountBalance(
        address: address.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ISuiAddress._(
        coin: accountParams.coin,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: address,
        network: network.value,
        tokens: const [],
        nfts: const [],
        keyScheme: accountParams.keyScheme,
        publicKey: publicKey);
  }

  factory ISuiAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(cborTag.tags, CborTagsConst.suiMultisigAccount)) {
      return ISuiMultiSigAddress.deserialize(network, obj: cborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.suiAccount);

    final CoinProposal proposal = CoinProposal.fromName(values.elementAs(0));
    final CryptoCoins coin =
        CryptoCoins.getCoin(values.elementAs(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: values.getCborTag(2));
    final int networkId = values.elementAs(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(4));

    final SuiAddress ethAddress = SuiAddress(values.elementAs(5));
    final tokens = values
        .elementAsListOf<CborTagValue>(7)
        .map((e) => SuiToken.fromCborBytesOrObject(obj: e))
        .toList();
    final String? accountName = values.elementAs(9);
    final SuiSupportKeyScheme keyScheme =
        SuiSupportKeyScheme.fromValue(values.elementAs(10));
    final List<int> publicKey = values.elementAs(11);
    return ISuiAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: ethAddress,
        network: networkId,
        tokens: tokens,
        nfts: [],
        accountName: accountName,
        keyScheme: keyScheme,
        publicKey: publicKey);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final AccountBalance address;

  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  final SuiSupportKeyScheme keyScheme;

  final List<int> publicKey;

  @override
  final int network;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          const CborNullValue(),
          address.toCbor(),
          networkAddress.address,
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          keyScheme.value,
          CborBytesValue(publicKey)
        ]),
        CborTagsConst.suiAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, keyScheme];
  }

  @override
  final SuiAddress networkAddress;

  @override
  String? get type => keyScheme.name;

  List<SuiToken> _tokens;
  @override
  List<SuiToken> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(SuiToken newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = [newToken, ..._tokens].immutable;
  }

  @override
  void updateToken(SuiToken token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    List<SuiToken> existTokens = _tokens.clone();
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = existTokens.immutable;
  }

  @override
  void removeToken(SuiToken token) {
    if (!tokens.contains(token)) return;
    final existTokens = _tokens.clone();
    existTokens.removeWhere((element) => element == token);
    _tokens = existTokens.immutable;
  }

  @override
  void addNFT(NFTCore newNft) {}

  @override
  void removeNFT(NFTCore nft) {}

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
    if (other is! ISuiAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  SuiNewAddressParams toAccountParams() {
    return SuiNewAddressParams(
        deriveIndex: keyIndex, coin: coin, keyScheme: keyScheme);
  }

  SuiAccountPublicKey toSuiPublicKey() {
    final SuiCryptoPublicKey publicKey = SuiCryptoPublicKey.fromBytes(
        keyBytes: this.publicKey, algorithm: keyScheme.suiKeyAlgorithm);
    switch (keyScheme) {
      case SuiSupportKeyScheme.ed25519:
        return SuiEd25519AccountPublicKey(publicKey.cast());
      case SuiSupportKeyScheme.secp256k1:
        return SuiSecp256k1AccountPublicKey(publicKey.cast());
      case SuiSupportKeyScheme.secp256r1:
        return SuiSecp256r1AccountPublicKey(publicKey.cast());
      default:
        throw WalletException("invalid_key_scheme");
    }
  }

  SuiBaseSignature createTransactionAuthenticated(
      List<SuiGenericSignature> signatures) {
    if (signatures.length != 1) {
      throw WalletException("invalid_signature");
    }
    final SuiCryptoPublicKey publicKey = SuiCryptoPublicKey.fromBytes(
        keyBytes: this.publicKey, algorithm: keyScheme.suiKeyAlgorithm);
    switch (keyScheme) {
      case SuiSupportKeyScheme.ed25519:
        return SuiEd25519Signature(
            publicKey: publicKey.cast(), signature: signatures.first);
      case SuiSupportKeyScheme.secp256k1:
        return SuiSecp256k1Signature(
            publicKey: publicKey.cast(), signature: signatures.first);
      case SuiSupportKeyScheme.secp256r1:
        return SuiSecp256r1Signature(
            publicKey: publicKey.cast(), signature: signatures.first);
      default:
        throw WalletException("invalid_key_scheme");
    }
  }
}

class ISuiMultiSigAddress extends ISuiAddress
    implements MultiSigCryptoAccountAddress {
  factory ISuiMultiSigAddress.newAccount(
      {required WalletSuiNetwork network,
      required SuiMultiSigNewAddressParams accountParam}) {
    try {
      final addressDetauls = AccountBalance(
          address: accountParam.address.address,
          balance: IntegerBalance.zero(network.coinParam.decimal));
      return ISuiMultiSigAddress._(
          coin: accountParam.coin,
          address: addressDetauls,
          networkAddress: accountParam.address,
          multiSignatureAddress: accountParam.multiSignatureAddress,
          network: network.value,
          keyIndex: const MultiSigAddressIndex());
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  factory ISuiMultiSigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.suiMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAt(0));
    final SuiMultisigAccountInfo multiSignatureAddress =
        SuiMultisigAccountInfo.deserialize(object: values.getCborTag(1));
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(2));
    final SuiAddress networkAddress = SuiAddress(address.address);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final tokens = values
        .elementAsListOf<CborTagValue>(4)
        .map((e) => SuiToken.fromCborBytesOrObject(obj: e))
        .toList();
    final String? name = values.elementAt(6);
    return ISuiMultiSigAddress._(
        coin: coin,
        address: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        accountName: name,
        networkAddress: networkAddress,
        tokens: tokens);
  }
  ISuiMultiSigAddress._({
    required super.coin,
    required super.address,
    required this.multiSignatureAddress,
    required super.network,
    super.keyIndex = const MultiSigAddressIndex(),
    super.accountName,
    super.nfts = const [],
    super.tokens = const [],
    required super.networkAddress,
  }) : super._(publicKey: const [], keyScheme: SuiSupportKeyScheme.multisig);

  @override
  List<int> get publicKey =>
      throw WalletExceptionConst.featureUnavailableForMultiSignature;

  final SuiMultisigAccountInfo multiSignatureAddress;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.suiMultisigAccount);
  }

  @override
  List get variabels => [multiSignatureAddress];

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAddress.publicKeys
          .map((e) => (BytesUtils.toHexString(e.publicKey), e.keyIndex))
          .toList();

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  SuiNewAddressParams toAccountParams() {
    return SuiMultiSigNewAddressParams(
        coin: coin,
        multiSignatureAddress: multiSignatureAddress,
        address: networkAddress);
  }

  @override
  SuiAccountPublicKey toSuiPublicKey() {
    return multiSignatureAddress.toSuiMutlisigPublicKey();
  }

  @override
  SuiBaseSignature createTransactionAuthenticated(
      List<SuiGenericSignature> signatures) {
    return multiSignatureAddress.createTransactionAuthenticated(signatures);
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByPublicKey;
}

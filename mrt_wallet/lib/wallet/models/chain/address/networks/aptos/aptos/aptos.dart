import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/coins/serialization/extension.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';

import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/networks/aptos/models/types.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:on_chain/aptos/src/aptos.dart';

import 'multisig.dart';

class IAptosAddress extends ChainAccount<AptosAddress, AptosFATokens, NFTCore>
    with Equatable {
  IAptosAddress._(
      {required this.keyIndex,
      required this.coin,
      required this.address,
      required this.network,
      required this.networkAddress,
      required this.keyScheme,
      required List<AptosFATokens> tokens,
      required List<NFTCore> nfts,
      required List<int> publicKey,
      String? accountName})
      : _tokens = tokens.immutable,
        _nfts = nfts.immutable,
        _accountName = accountName,
        publicKey = publicKey.asImmutableBytes;

  factory IAptosAddress.newAccount({
    required AptosNewAddressParams accountParams,
    required AptosAddress address,
    required WalletAptosNetwork network,
    required List<int> publicKey,
  }) {
    final addressDetauls = AccountBalance(
        address: address.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return IAptosAddress._(
        coin: accountParams.coin,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        keyScheme: accountParams.keyScheme,
        networkAddress: address,
        network: network.value,
        tokens: const [],
        nfts: const [],
        publicKey: publicKey);
  }
  factory IAptosAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return IAptosAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IAptosAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(
        cborTag.tags, CborTagsConst.aptosMultisigAccount)) {
      return IAptosMultiSigAddress.deserialize(network, obj: cborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: cborTag, tags: CborTagsConst.aptoAccount);
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

    final AptosAddress networkAddress = AptosAddress(values.elementAs(5));
    final tokens = values
        .elementAsListOf<CborTagValue>(7)
        .map((e) => AptosFATokens.fromCborBytesOrObject(obj: e))
        .toList();
    final String? accountName = values.elementAs(9);
    final AptosSupportKeyScheme keyScheme =
        AptosSupportKeyScheme.fromValue(values.elementAs(10));
    final List<int> publicKey = values.elementAs(11);
    return IAptosAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: networkAddress,
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

  @override
  final int network;

  final AptosSupportKeyScheme keyScheme;
//
  final List<int> publicKey;

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
        CborTagsConst.aptoAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, keyScheme];
  }

  @override
  final AptosAddress networkAddress;

  @override
  String? get type => keyScheme.name;

  List<AptosFATokens> _tokens;
  @override
  List<AptosFATokens> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(AptosFATokens newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = [newToken, ..._tokens].immutable;
  }

  @override
  void updateToken(AptosFATokens token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    List<AptosFATokens> existTokens = _tokens.clone();
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = existTokens.immutable;
  }

  @override
  void removeToken(AptosFATokens token) {
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
    if (other is! IAptosAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  AptosNewAddressParams toAccountParams() {
    return AptosNewAddressParams(
        deriveIndex: keyIndex, coin: coin, keyScheme: keyScheme);
  }

  /// create transaction authenticated.
  AptosAccountAuthenticator createAccountAuthenticated(
      List<AptosAnySignature> signatures) {
    if (signatures.length != 1) {
      throw WalletException("invalid_signature");
    }
    final signature = signatures[0];
    switch (keyScheme) {
      case AptosSupportKeyScheme.ed25519:
        return AptosAccountAuthenticatorEd25519(
            publicKey: AptosED25519PublicKey.fromBytes(publicKey),
            signature: AptosEd25519Signature(signature.signatureBytes()));
      case AptosSupportKeyScheme.signleKeyEd25519:
      case AptosSupportKeyScheme.signleKeySecp256k1:
        return AptosAccountAuthenticatorSingleKey(
            publicKey: AptosCryptoPublicKey.fromBytes(
                publicKeyBytes: publicKey, algorithm: keyScheme.curve),
            signature: signature);
      default:
        throw WalletException("invalid_key_scheme");
    }
  }

  AptosAccountPublicKey aptosPublicKey() {
    switch (keyScheme) {
      case AptosSupportKeyScheme.ed25519:
        return AptosEd25519AccountPublicKey(
            AptosED25519PublicKey.fromBytes(publicKey));
      case AptosSupportKeyScheme.signleKeyEd25519:
      case AptosSupportKeyScheme.signleKeySecp256k1:
        return AptosSingleKeyAccountPublicKey(AptosCryptoPublicKey.fromBytes(
            publicKeyBytes: publicKey, algorithm: keyScheme.curve));
      default:
        throw WalletException("invalid_key_scheme");
    }
  }
}

class IAptosMultiSigAddress extends IAptosAddress
    implements MultiSigCryptoAccountAddress {
  factory IAptosMultiSigAddress.newAccount(
      {required WalletAptosNetwork network,
      required AptosMultiSigNewAddressParams accountParam}) {
    try {
      final addressDetauls = AccountBalance(
          address: accountParam.address.address,
          balance: IntegerBalance.zero(network.coinParam.decimal));
      return IAptosMultiSigAddress._(
          coin: accountParam.coin,
          address: addressDetauls,
          networkAddress: accountParam.address,
          multiSignatureAddress: accountParam.multiSignatureAddress,
          network: network.value,
          keyIndex: const MultiSigAddressIndex(),
          keyScheme: accountParam.keyScheme);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  factory IAptosMultiSigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.aptosMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAt(0));
    final AptosMultisigAccountInfo multiSignatureAddress =
        AptosMultisigAccountInfo.deserialize(object: values.getCborTag(1));
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(2));
    final AptosAddress networkAddress = AptosAddress(address.address);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final tokens = values
        .elementAsListOf<CborTagValue>(4)
        .map((e) => AptosFATokens.fromCborBytesOrObject(obj: e))
        .toList();
    final String? name = values.elementAt(6);
    final keyScheme = AptosSupportKeyScheme.fromValue(values.elementAs(7));
    if (keyScheme != multiSignatureAddress.keyScheme) {
      throw WalletExceptionConst.invalidAccountDetails_(
          messsage: "mis match multisig account key scheme.");
    }
    return IAptosMultiSigAddress._(
        coin: coin,
        address: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        accountName: name,
        networkAddress: networkAddress,
        tokens: tokens,
        keyScheme: keyScheme);
  }
  IAptosMultiSigAddress._({
    required super.coin,
    required super.address,
    required this.multiSignatureAddress,
    required super.network,
    required super.keyScheme,
    super.keyIndex = const MultiSigAddressIndex(),
    super.accountName,
    super.nfts = const [],
    super.tokens = const [],
    required super.networkAddress,
  }) : super._(publicKey: const []);

  @override
  List<int> get publicKey =>
      throw WalletExceptionConst.featureUnavailableForMultiSignature;

  final AptosMultisigAccountInfo multiSignatureAddress;

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
          accountName ?? const CborNullValue(),
          keyScheme.value
        ]),
        CborTagsConst.aptosMultisigAccount);
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
  AptosNewAddressParams toAccountParams() {
    return AptosMultiSigNewAddressParams(
        coin: coin,
        multiSignatureAddress: multiSignatureAddress,
        address: networkAddress);
  }

  /// create transaction authenticated.
  @override
  AptosAccountAuthenticator createAccountAuthenticated(
      List<AptosAnySignature> signatures) {
    return multiSignatureAddress.createAccountAuthenticated(signatures);
  }

  @override
  AptosAccountPublicKey aptosPublicKey() {
    return multiSignatureAddress.toAptosMutlisigPublicKey();
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByPublicKey;
}

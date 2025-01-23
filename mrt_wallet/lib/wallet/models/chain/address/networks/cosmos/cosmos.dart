import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';

import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

class ICosmosAddress extends ChainAccount<CosmosBaseAddress, CW20Token, NFTCore>
    with Equatable {
  ICosmosAddress._({
    required this.keyIndex,
    required this.coin,
    required List<int> publicKey,
    required this.address,
    required this.network,
    required this.networkAddress,
    required List<CW20Token> tokens,
    required List<NFTCore> nfts,
    String? accountName,
    required this.algorithm,
  })  : _tokens = tokens.immutable,
        _nfts = nfts.immutable,
        _accountName = accountName,
        publicKey = publicKey.asImmutableBytes;

  factory ICosmosAddress.newAccount(
      {required CosmosNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletCosmosNetwork network}) {
    final cosmosAddr = accountParams.toAddress(
        publicKey: publicKey, hrp: network.coinParam.hrp);
    final addressDetauls = AccountBalance(
        address: cosmosAddr.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ICosmosAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: cosmosAddr,
        network: network.value,
        tokens: const [],
        nfts: const [],
        algorithm: accountParams.algorithm);
  }
  factory ICosmosAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return ICosmosAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ICosmosAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue values = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.cosmosAccount);
    final CoinProposal proposal = CoinProposal.fromName(values.elementAs(0));
    final CryptoCoins coin =
        CryptoCoins.getCoin(values.elementAs(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: values.getCborTag(2));
    final List<int> publicKey = values.elementAs(3);
    final int networkId = values.elementAs(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(4));
    final CosmosBaseAddress cosmosAddr = CosmosBaseAddress(values.elementAs(5),
        forceHrp: network.toNetwork<WalletCosmosNetwork>().coinParam.hrp);
    final String? accountName = values.elementAs(9);
    final tokens = values
        .elementAsListOf<CborTagValue>(7)
        .map((e) => CW20Token.fromCborBytesOrObject(obj: e))
        .toList();
    final algorithm = values.elemetMybeAs<CosmosKeysAlgs, String>(
            10, (p0) => CosmosKeysAlgs.fromName(p0)) ??
        CosmosKeysAlgs.secp256k1;
    return ICosmosAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: cosmosAddr,
        network: networkId,
        tokens: tokens,
        nfts: [],
        accountName: accountName,
        algorithm: algorithm);
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

  final CosmosKeysAlgs algorithm;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          networkAddress.address,
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName,
          algorithm.name
        ]),
        CborTagsConst.cosmosAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final CosmosBaseAddress networkAddress;

  @override
  String? type;

  List<CW20Token> _tokens;
  @override
  List<CW20Token> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(CW20Token newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = [newToken, ..._tokens].immutable;
  }

  @override
  void updateToken(CW20Token token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    List<CW20Token> existTokens = _tokens.clone();
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = existTokens.immutable;
  }

  @override
  void removeToken(CW20Token token) {
    if (!tokens.contains(token)) return;
    final existTokens = _tokens.clone();
    existTokens.removeWhere((element) => element == token);
    _tokens = existTokens.imutable;
  }

  @override
  void addNFT(NFTCore newNft) {}

  @override
  void removeNFT(NFTCore nft) {}

  SignerInfo get signerInfo => SignerInfo(
      publicKey:
          CosmosPublicKey.fromBytes(keyBytes: publicKey, algorithm: algorithm),
      modeInfo: const ModeInfo(ModeInfoSignle(SignMode.signModeDirect)),
      sequence: BigInt.zero);

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
    if (other is! ICosmosAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  CosmosNewAddressParams toAccountParams() {
    return CosmosNewAddressParams(
        deriveIndex: keyIndex, coin: coin, algorithm: algorithm);
  }
}

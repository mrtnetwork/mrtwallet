import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/erc20.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';

class IEthAddress extends ChainAccount<ETHAddress, ETHERC20Token, NFTCore>
    with Equatable {
  IEthAddress._(
      {required this.keyIndex,
      required this.coin,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<ETHERC20Token> tokens,
      required List<NFTCore> nfts,
      String? accountName})
      : _tokens = List<ETHERC20Token>.unmodifiable(tokens),
        _nfts = List<NFTCore>.unmodifiable(nfts),
        _accountName = accountName;

  factory IEthAddress.newAccount(
      {required EthereumNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletNetwork network}) {
    final ethAddress = ETHAddress.fromPublicKey(publicKey);
    final addressDetauls = AccountBalance(
        address: ethAddress.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return IEthAddress._(
      coin: accountParams.coin,
      address: addressDetauls,
      keyIndex: accountParams.deriveIndex,
      networkAddress: ethAddress,
      network: network.value,
      tokens: const [],
      nfts: const [],
    );
  }
  factory IEthAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return IEthAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IEthAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.ethAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));

    final ETHAddress ethAddress = ETHAddress(cbor.elementAt(5));

    final List<ETHERC20Token> erc20Tokens = [];
    final List<dynamic>? tokens = cbor.elementAt(7);
    if (tokens != null) {
      for (final i in tokens) {
        erc20Tokens.add(ETHERC20Token.fromCborBytesOrObject(obj: i));
      }
    }

    final String? accountName = cbor.elementAt(9);
    return IEthAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: ethAddress,
        network: networkId,
        tokens: erc20Tokens,
        nfts: [],
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
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.ethAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final ETHAddress networkAddress;

  @override
  String? get type => null;

  List<ETHERC20Token> _tokens;
  @override
  List<ETHERC20Token> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(ETHERC20Token newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = List.unmodifiable([newToken, ..._tokens]);
  }

  @override
  void removeToken(ETHERC20Token token) {
    if (!tokens.contains(token)) return;

    final existTokens = List.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void addNFT(NFTCore newNft) {}

  @override
  void removeNFT(NFTCore nft) {}
  @override
  @override
  void updateToken(TokenCore<BigInt> token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    if (token is! ETHERC20Token) {
      throw WalletExceptionConst.invalidArgruments(
          "ETHERC20Token", "${token.runtimeType}");
    }
    List<ETHERC20Token> existTokens = List<ETHERC20Token>.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = List.unmodifiable(existTokens);
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
    return other.networkAddress.address == networkAddress.address;
  }

  @override
  EthereumNewAddressParams toAccountParams() {
    return EthereumNewAddressParams(deriveIndex: keyIndex, coin: coin);
  }
}

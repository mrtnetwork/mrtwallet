import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';

import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart';

import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';

class ITonAddress extends ChainAccount<TonAddress, TonJettonToken, NFTCore>
    with Equatable {
  ITonAddress._({
    required this.keyIndex,
    required this.coin,
    required List<int> publicKey,
    required this.address,
    required this.network,
    required this.networkAddress,
    required this.context,
    required List<TokenCore<BigInt>> tokens,
    required List<NFTCore> nfts,
    String? accountName,
  })  : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory ITonAddress.newAccount(
      {required TonNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletTonNetwork network}) {
    final tonAddress = accountParams.toAddress(
        publicKey: publicKey, chain: network.coinParam.chainType);
    final addressDetauls = AccountBalance(
        address: tonAddress.toFriendlyAddress(
            bounceable: accountParams.context.bouncable),
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ITonAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: tonAddress,
        network: network.value,
        context: accountParams.context,
        tokens: const [],
        nfts: const []);
  }
  factory ITonAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return ITonAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ITonAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.tonAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));
    final TonAddress tonAddress = TonAddress(cbor.elementAt(5));
    final int networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    TonAccountContext context;
    final String? version = cbor.elemetAs(7);
    final int? subWalletId = cbor.elemetAs(8);
    final List<TonJettonToken> tokens = (cbor.elementAt<List<dynamic>>(9))
        .map((e) => TonJettonToken.fromCborBytesOrObject(obj: e))
        .toList();
    final String? accountName = cbor.elementAt(11);
    final bool? bouncable = cbor.elemetAs(12);
    final CborTagValue? contextObject = cbor.elemetAs(13);
    if (contextObject != null) {
      context = TonAccountContext.deserialize(object: contextObject);
    } else if (version != null && bouncable != null) {
      context = TonAccountContext.merge(
          version: WalletVersion.fromValue(version),
          bouncable: bouncable,
          subwalletId: subWalletId);
    } else {
      throw WalletExceptionConst.invalidAccountDetails;
    }

    return ITonAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: tonAddress,
        network: networkId,
        tokens: tokens,
        nfts: [],
        accountName: accountName,
        context: context);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  final TonAccountContext context;

  @override
  final AccountBalance address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  final List<int> publicKey;

  // final bool bouncable;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          networkAddress.toFriendlyAddress(),
          network,
          const CborNullValue(),
          const CborNullValue(),
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          const CborNullValue(),
          context.toCbor()
        ]),
        CborTagsConst.tonAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, context];
  }

  @override
  final TonAddress networkAddress;

  @override
  late final String? type =
      "${networkAddress.type.name} (${context.version.name})";

  List<TonJettonToken> _tokens;
  @override
  List<TonJettonToken> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TonJettonToken newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = List.unmodifiable([newToken, ..._tokens]);
  }

  @override
  void removeToken(TonJettonToken token) {
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
  void updateToken(TonJettonToken token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    List<TonJettonToken> existTokens = List<TonJettonToken>.from(_tokens);
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
  late final String orginalAddress = networkAddress.toRawAddress();

  VersionedWalletContract toWalletContract() {
    return context.toWalletContract(
        publicKey: publicKey,
        chain: TonChain.fromWorkchain(networkAddress.workChain));
  }

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ITonAddress) return false;
    return context == other.context &&
        BytesUtils.bytesEqual(other.networkAddress.hash, networkAddress.hash);
  }

  @override
  TonNewAddressParams toAccountParams() {
    return TonNewAddressParams(
        deriveIndex: keyIndex, coin: coin, context: context);
  }
}

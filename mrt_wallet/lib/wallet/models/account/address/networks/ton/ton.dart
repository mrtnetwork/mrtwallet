import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';

import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wroker/utils/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:mrt_wallet/wallet/models/account/address/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';

class ITonAddress extends CryptoAddress<BigInt, TonAddress> with Equatable {
  ITonAddress._({
    required this.keyIndex,
    required this.coin,
    required List<int> publicKey,
    required this.address,
    required this.network,
    required this.networkAddress,
    required this.subWalletId,
    required this.version,
    required List<TokenCore<BigInt>> tokens,
    required List<NFTCore> nfts,
    required this.bouncable,
    String? accountName,
  })  : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory ITonAddress.newAccount(
      {required TonNewAddressParam accountParams,
      required List<int> publicKey,
      required WalletTonNetwork network}) {
    final tonAddress = accountParams.toAddress(
        publicKey: publicKey, workChain: network.coinParam.workchain);
    final addressDetauls = IntegerAddressBalance(
        address:
            tonAddress.toFriendlyAddress(bounceable: accountParams.bouncable),
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ITonAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: tonAddress,
        network: network.value,
        version: accountParams.version,
        subWalletId: accountParams.subWalletId,
        tokens: const [],
        nfts: const [],
        bouncable: accountParams.bouncable);
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
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final IntegerAddressBalance address =
        IntegerAddressBalance.fromCborBytesOrObject(network.coinParam.decimal,
            obj: cbor.getCborTag(4));
    final TonAddress tonAddress = TonAddress(cbor.elementAt(5));
    final int networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final WalletVersion version = WalletVersion.fromValue(cbor.elementAt(7));
    final int? subWalletId = cbor.elementAt(8);
    final List<TonJettonToken> tokens = (cbor.elementAt<List<dynamic>>(9))
        .map((e) => TonJettonToken.fromCborBytesOrObject(obj: e))
        .toList();
    final String? accountName = cbor.elementAt(11);

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
        version: version,
        subWalletId: subWalletId,
        bouncable: cbor.elementAt(12));
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  final WalletVersion version;
  final int? subWalletId;

  @override
  final AddressBalanceCore<BigInt> address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  final List<int> publicKey;

  final bool bouncable;

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
          CborStringValue(version.name),
          subWalletId ?? const CborNullValue(),
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          bouncable
        ]),
        CborTagsConst.tonAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final TonAddress networkAddress;

  @override
  late final String? type = "${networkAddress.type.name} (${version.name})";

  List<TonJettonToken> _tokens;
  @override
  List<TonJettonToken> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TokenCore<BigInt> newToken) {
    if (newToken is! TonJettonToken) {
      throw WalletExceptionConst.invalidArgruments(
          "TonJettonToken", "${newToken.runtimeType}");
    }
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = List.unmodifiable([newToken, ..._tokens]);
  }

  @override
  void removeToken(TokenCore<BigInt> token) {
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
  void updateToken(TokenCore<BigInt> token, Token updatedToken) {
    if (!tokens.contains(token)) return;
    if (token is! TonJettonToken) {
      throw WalletExceptionConst.invalidArgruments(
          "TonJettonToken", "${token.runtimeType}");
    }
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
  // @override
  // List<AddressDerivationIndex> get keyIndexes => [keyIndex];

  WalletContract toWalletContract() {
    return TonUtils.fromVersion(
        publicKey: publicKey,
        workChain: networkAddress.workChain,
        version: version,
        subWalletId: subWalletId,
        bouncable: bouncable);
  }

  @override
  bool isEqual(CryptoAddress<BigInt, TonAddress> other) {
    if (other is! ITonAddress) return false;
    return bouncable == other.bouncable &&
        BytesUtils.bytesEqual(other.networkAddress.hash, networkAddress.hash);
  }

  @override
  TonNewAddressParam toAccountParams() {
    return TonNewAddressParam(
        deriveIndex: keyIndex,
        coin: coin,
        version: version,
        bouncable: bouncable,
        subWalletId: subWalletId);
  }
}

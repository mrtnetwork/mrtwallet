import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';

import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class ISubstrateAddress
    extends ChainAccount<SubstrateAddress, TokenCore, NFTCore> with Equatable {
  ISubstrateAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<TokenCore> tokens,
      required List<NFTCore> nfts,
      String? accountName,
      required this.ss58Format})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName;

  factory ISubstrateAddress.newAccount(
      {required SubstrateNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletPolkadotNetwork network}) {
    final addr = accountParams.toAddress(
        publicKey: publicKey, ss58Format: network.coinParam.ss58Format);
    final addressDetauls = AccountBalance(
        address: addr.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ISubstrateAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: addr,
        network: network.value,
        tokens: const [],
        nfts: const [],
        ss58Format: network.coinParam.ss58Format);
  }
  factory ISubstrateAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.substrateAccount);
    final CryptoCoins coin = CustomCoins.getCoin(
      name: cbor.elementAt(1),
      proposal: cbor.elementAt(0),
    );
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));
    final int ss58Format = cbor.elementAt(10);
    final SubstrateAddress addr =
        SubstrateAddress(cbor.elementAt(5), ss58Format: ss58Format);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = cbor.elementAt(9);
    return ISubstrateAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: addr,
        network: networkId,
        tokens: [],
        nfts: [],
        accountName: accountName,
        ss58Format: ss58Format);
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

  final int ss58Format;

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
          accountName ?? const CborNullValue(),
          ss58Format
        ]),
        CborTagsConst.substrateAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final SubstrateAddress networkAddress;

  @override
  String? type;

  List<TokenCore> _tokens;
  @override
  List<TokenCore> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TokenCore newToken) {}

  @override
  void removeToken(TokenCore token) {
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
  void updateToken(TokenCore token, Token updatedToken) {}

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
    if (other is! ISubstrateAddress) return false;
    return other.networkAddress.address == networkAddress.address &&
        other.networkAddress.ss58Format == networkAddress.ss58Format;
  }

  @override
  SubstrateNewAddressParams toAccountParams() {
    return SubstrateNewAddressParams(deriveIndex: keyIndex);
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/coins/serialization/extension.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';
import 'package:mrt_wallet/wallet/models/nfts/nfts.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class IMoneroAddress extends ChainAccount<MoneroAddress, TokenCore, NFTCore>
    with Equatable {
  factory IMoneroAddress.newAccount(
      {required MoneroNewAddressParams accountParams,
      required WalletMoneroNetwork network}) {
    final address = accountParams.addrDetails!.toAddress(network);

    final addrDetails = AccountBalance(
        address: address.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return IMoneroAddress(
        coin: accountParams.coin,
        address: addrDetails,
        keyIndex: accountParams.deriveIndex.cast(),
        networkAddress: address,
        network: network.value,
        addrDetails: accountParams.addrDetails!,
        utxos: []);
  }

  factory IMoneroAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.moneroAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: values.getCborTag(1));
    final addrDetails =
        MoneroViewAccountDetails.deserialize(object: values.getCborTag(2));
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: values.getCborTag(3));
    final networkAddress = MoneroAddress(address.toAddress);
    final int networkId = values.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? name = values.elementAs(5);
    final List<MoneroOutputDetails> utxos = values
        .elementAsListOf<CborTagValue>(6)
        .map((e) => MoneroOutputDetails.deserialize(cbor: e))
        .toList();
    return IMoneroAddress(
        coin: coin,
        address: address,
        keyIndex: keyIndex.cast(),
        networkAddress: networkAddress,
        network: network.value,
        accountName: name,
        addrDetails: addrDetails,
        utxos: utxos);
  }
  IMoneroAddress(
      {required this.keyIndex,
      required this.coin,
      required this.networkAddress,
      required this.address,
      required this.network,
      required this.addrDetails,
      required List<MoneroOutputDetails> utxos,
      String? accountName})
      : _accountName = accountName,
        _utxos = utxos.immutable;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          addrDetails.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          CborListValue.fixedLength(utxos.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.moneroAccount);
  }

  @override
  final CryptoCoins coin;
  final MoneroViewAccountDetails addrDetails;

  @override
  final MoneroAddress networkAddress;
  MoneroAddress get primaryAddress => addrDetails.viewKey.primaryAddress;

  @override
  final AccountBalance address;

  @override
  final Bip32AddressIndex keyIndex;
  List<MoneroOutputDetails> _utxos;
  List<MoneroOutputDetails> get utxos => _utxos;
  // final MoneroDefaultAccountChainTracker chainInfo;
  @override
  bool get multiSigAccount => false;

  @override
  final int network;

  @override
  List get variabels => [addrDetails, keyIndex, network];

  @override
  String accountToString() {
    return "${networkAddress.type.name}\n${address.toAddress}";
  }

  @override
  String get type => networkAddress.type.name;

  @override
  List<TokenCore<BigInt>> get tokens => const [];

  @override
  void addToken(TokenCore newToken) {
    throw WalletExceptionConst.networkTokenUnsuported;
  }

  @override
  void removeToken(TokenCore token) {
    throw WalletExceptionConst.networkTokenUnsuported;
  }

  @override
  void addNFT(NFTCore newNft) {
    throw WalletExceptionConst.networkNFTsUnsuported;
  }

  @override
  List<NFTCore> get nfts => throw WalletExceptionConst.networkNFTsUnsuported;

  @override
  void removeNFT(NFTCore nft) {
    throw WalletExceptionConst.networkNFTsUnsuported;
  }

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
  void updateToken(TokenCore token, Token updatedToken) {}

  @override
  bool isEqual(ChainAccount other) {
    if (other is! IMoneroAddress) return false;
    return networkAddress == other.networkAddress;
  }

  @override
  MoneroNewAddressParams toAccountParams() {
    return MoneroNewAddressParams(
        deriveIndex: keyIndex,
        major: addrDetails.index.major,
        minor: addrDetails.index.minor,
        addrDetails: addrDetails,
        coin: coin,
        network: addrDetails.viewKey.network);
  }

  bool updateUtxos(List<MoneroOutputDetails> utxos) {
    final indexUtxos = utxos.where((e) => e.index == addrDetails.index);
    if (indexUtxos.isEmpty) return false;
    final unspent = indexUtxos.where((e) => e.status.isUnspent);
    final spent = indexUtxos.where((e) => e.status.isSpent);
    final allUtxos =
        [...this.utxos, ...unspent].where((e) => !spent.contains(e));
    _utxos = allUtxos.toSet().toImutableList;
    return true;
  }

  void replaceUtxos(List<MoneroOutputDetails> utxos) {
    final indexUtxos = utxos.where((e) => e.index == addrDetails.index);
    _utxos = indexUtxos.toSet().toImutableList;
  }
}

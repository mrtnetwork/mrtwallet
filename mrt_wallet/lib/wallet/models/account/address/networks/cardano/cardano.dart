import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/derivation.dart';

import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/coins/coins.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/address_details.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/utils/cardano/cardano_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/wallet/models/account/address/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';

class ICardanoAddress
    with Equatable
    implements Bip32AddressCore<BigInt, ADAAddress> {
  ICardanoAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<TokenCore> tokens,
      required List<NFTCore> nfts,
      required this.addressDetails,
      AddressDerivationIndex? rewardKeyIndex,
      String? accountName})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = List.unmodifiable(tokens),
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName,
        _rewardKeyIndex = rewardKeyIndex,
        rewardAddress = CardanoUtils.extractRewardAddress(networkAddress);

  factory ICardanoAddress.newAccount(
      {required CardanoNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletCardanoNetwork network}) {
    final cardanoAddr = accountParams.toAddress();
    final addressDetauls = IntegerAddressBalance(
        address: cardanoAddr.address,
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ICardanoAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: cardanoAddr,
        network: network.value,
        tokens: const [],
        nfts: const [],
        addressDetails: accountParams.addressDetails!,
        rewardKeyIndex: accountParams.rewardKeyIndex);
  }
  factory ICardanoAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return ICardanoAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ICardanoAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.cardanoAccount);
    final CryptoProposal proposal = CustomProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CustomCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final IntegerAddressBalance address =
        IntegerAddressBalance.fromCborBytesOrObject(network.coinParam.decimal,
            obj: cbor.getCborTag(4));

    final ADAAddress adaAddress = ADAAddress.fromAddress(cbor.elementAt(5));
    final CardanoAddrDetails addrDetails =
        CardanoAddrDetails.fromCborBytesOrObject(obj: cbor.getCborTag(7));
    if (addrDetails.toAddress(coin).address != adaAddress.address) {
      throw WalletException("Incorrect ADA addresss.");
    }

    final String? accountName = cbor.elementAt(10);
    final CborTagValue? rewardIndexCbor = cbor.getCborTag(11);
    final rewardIndex = rewardIndexCbor == null
        ? null
        : AddressDerivationIndex.fromCborBytesOrObject(obj: rewardIndexCbor);
    if (adaAddress.addressType == ADAAddressType.base && rewardIndex == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return ICardanoAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: adaAddress,
        network: networkId,
        addressDetails: addrDetails,
        tokens: [],
        nfts: [],
        accountName: accountName,
        rewardKeyIndex: rewardIndex);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final AddressBalanceCore<BigInt> address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  @override
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
          networkAddress.address,
          network,
          addressDetails.toCbor(),
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          rewardKeyIndex?.toCbor() ?? const CborNullValue()
        ]),
        CborTagsConst.cardanoAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, networkAddress.addressType];
  }

  final CardanoAddrDetails addressDetails;

  @override
  final ADAAddress networkAddress;

  final ADARewardAddress? rewardAddress;

  final AddressDerivationIndex? _rewardKeyIndex;

  AddressDerivationIndex? get rewardKeyIndex => _rewardKeyIndex;

  bool get isBaseAddress => networkAddress.addressType == ADAAddressType.base;

  @override
  String? get type => networkAddress.addressType.name;

  List<TokenCore<BigInt>> _tokens;
  @override
  List<TokenCore<BigInt>> get tokens => _tokens;

  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TokenCore<BigInt> newToken) {}

  @override
  void removeToken(TokenCore<BigInt> token) {
    if (!tokens.contains(token)) return;
    final existTokens = List.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void updateToken(TokenCore<BigInt> token, Token updatedToken) {}
  @override
  void addNFT(NFTCore newNft) {}

  @override
  void removeNFT(NFTCore nft) {}

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
  List<AddressDerivationIndex> get keyIndexes =>
      [keyIndex, if (rewardKeyIndex != null) rewardKeyIndex!];

  @override
  bool isEqual(Bip32AddressCore<BigInt, ADAAddress> other) {
    if (other is! ICardanoAddress) return false;
    return networkAddress.address == other.networkAddress.address &&
        rewardAddress?.address == other.rewardAddress?.address;
  }
}

import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:bitcoin_base/bitcoin_base.dart'
    show BitcoinBaseAddress, BitcoinAddressType;
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

import 'bitcoin_multi_sig_core.dart';

class IBitcoinAddress
    with Equatable
    implements Bip32AddressCore<BigInt, BitcoinBaseAddress> {
  factory IBitcoinAddress.newAccount(
      {required BitcoinNewAddressParams accountParams,
      required List<int> publicKey,
      required AppNetworkImpl network}) {
    final bitcoinAddress = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey, accountParams.coin, accountParams.bitcoinAddressType);

    final addressDetauls = NoneDecimalNetworkAddressDetails(
        address: bitcoinAddress.toAddress(network
            .toNetwork<AppBitcoinNetwork>()
            .coinParam
            .transacationNetwork),
        balance: NoneDecimalBalance.zero(network.coinParam.decimal));

    return IBitcoinAddress(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: bitcoinAddress,
        addressType: accountParams.bitcoinAddressType,
        network: network.value);
  }
  factory IBitcoinAddress.fromCbsorHex(AppNetworkImpl network, String hex) {
    return IBitcoinAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.bitcoinMultiSigAccount)) {
      return IBitcoinMultiSigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }
    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, WalletModelCborTagsConst.bitcoinAccount);
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final NoneDecimalNetworkAddressDetails address =
        NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
            network.coinParam.decimal,
            obj: cbor.getCborTag(4));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAt(5));
    final bitcoinAddress = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey, coin, bitcoinAddressType);
    if (bitcoinAddress.toAddress(
            (network as AppBitcoinNetwork).coinParam.transacationNetwork) !=
        address.toAddress) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final String? name = cbor.elementAt(7);
    return IBitcoinAddress(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: bitcoinAddress,
        addressType: bitcoinAddressType,
        network: network.value,
        accountName: name);
  }
  IBitcoinAddress(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.networkAddress,
      required this.address,
      required this.addressType,
      required this.network,
      String? accountName})
      : publicKey = List.unmodifiable(publicKey),
        _accountName = accountName;

  @override
  final CryptoCoins coin;
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
          addressType.value,
          network,
          accountName ?? const CborNullValue()
        ]),
        WalletModelCborTagsConst.bitcoinAccount);
  }

  @override
  final BitcoinBaseAddress networkAddress;
  final BitcoinAddressType addressType;

  @override
  final NetworkAddressDetailsCore<BigInt> address;

  @override
  final AddressDerivationIndex keyIndex;
  @override
  bool get multiSigAccount => false;

  @override
  final int network;

  @override
  List get variabels => [addressType, keyIndex, network];

  @override
  List<String> get signers => [BytesUtils.toHexString(publicKey)];

  @override
  String accountToString() {
    return "${addressType.value}\n${address.toAddress}";
  }

  @override
  String get type => addressType.value;

  @override
  List<TokenCore<BigInt>> get tokens =>
      throw WalletExceptionConst.networkTokenUnsuported;

  @override
  void addToken(TokenCore<BigInt> newToken) {
    throw WalletExceptionConst.networkTokenUnsuported;
  }

  @override
  void removeToken(TokenCore<BigInt> token) {
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
  String get orginalAddress => address.toAddress;
}

class IBitcoinMultiSigAddress extends IBitcoinAddress
    with BitcoinMultiSigBase
    implements MultiSigCryptoAccountAddress {
  factory IBitcoinMultiSigAddress.newAccount({
    required AppBitcoinNetwork network,
    required BitcoinMultiSigNewAddressParams accountParam,
  }) {
    try {
      final toBitcoinAddress = accountParam.multiSignatureAddress.fromType(
          network: network.coinParam.transacationNetwork,
          addressType: accountParam.bitcoinAddressType);
      final addressDetauls = NoneDecimalNetworkAddressDetails(
          address:
              toBitcoinAddress.toAddress(network.coinParam.transacationNetwork),
          balance: NoneDecimalBalance.zero(network.coinParam.decimal));

      return IBitcoinMultiSigAddress._(
          coin: accountParam.coin,
          address: addressDetauls,
          multiSignatureAddress: accountParam.multiSignatureAddress,
          bitcoinAddress: toBitcoinAddress,
          addressType: accountParam.bitcoinAddressType,
          network: network.value,
          keyIndex: const MultiSigAddressIndex());
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  factory IBitcoinMultiSigAddress.fromCborHex(
      AppNetworkImpl network, String hex) {
    return IBitcoinMultiSigAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinMultiSigAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitcoinMultiSigAccount);
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final BitcoinMultiSignatureAddress multiSignatureAddress =
        BitcoinMultiSignatureAddress.fromCborBytesOrObject(
            obj: cbor.getCborTag(2));
    final int networkId = cbor.elementAt(5);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final NoneDecimalNetworkAddressDetails address =
        NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
            network.coinParam.decimal,
            obj: cbor.getCborTag(3));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAt(4));
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(6));
    final String? name = cbor.elementAt(7);

    return IBitcoinMultiSigAddress._(
        coin: coin,
        address: address,
        bitcoinAddress: multiSignatureAddress.fromType(
            network: network
                .toNetwork<AppBitcoinNetwork>()
                .coinParam
                .transacationNetwork,
            addressType: bitcoinAddressType),
        addressType: bitcoinAddressType,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        keyIndex: keyIndex,
        accountName: name);
  }
  IBitcoinMultiSigAddress._(
      {required CryptoCoins coin,
      required BitcoinBaseAddress bitcoinAddress,
      required NetworkAddressDetailsCore<BigInt> address,
      required BitcoinAddressType addressType,
      required this.multiSignatureAddress,
      required super.network,
      required super.keyIndex,
      String? accountName})
      : super(
            coin: coin,
            publicKey: const [],
            networkAddress: bitcoinAddress,
            address: address,
            addressType: addressType,
            accountName: accountName);

  @override
  List<int> get publicKey => throw UnimplementedError();

  @override
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          addressType.value,
          network,
          keyIndex.toCbor(),
          accountName ?? const CborNullValue()
        ]),
        WalletModelCborTagsConst.bitcoinMultiSigAccount);
  }

  @override
  bool get multiSigAccount => true;
  @override
  List get variabels => [
        addressType,
        keyIndex,
        network,
        multiSignatureAddress.multiSigScript.toHex()
      ];

  @override
  List<String> get signers =>
      multiSignatureAddress.signers.map((e) => e.publicKey).toList();

  @override
  List<(String, AddressDerivationIndex)> get keyDetails =>
      multiSignatureAddress.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();
}

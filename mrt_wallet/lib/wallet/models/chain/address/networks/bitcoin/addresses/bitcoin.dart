import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/nfts.dart';

import 'package:bitcoin_base/bitcoin_base.dart'
    show BitcoinBaseAddress, BitcoinAddressType;
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/crypto/utils/address/utils.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'multisig.dart';

class IBitcoinAddress
    extends ChainAccount<BitcoinBaseAddress, TokenCore, NFTCore>
    with Equatable {
  factory IBitcoinAddress.newAccount(
      {required BitcoinNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletNetwork network}) {
    final bitcoinAddress = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey: publicKey,
        coin: accountParams.coin,
        addressType: accountParams.bitcoinAddressType,
        keyType: accountParams.keyType);

    final addressDetauls = AccountBalance(
        address: bitcoinAddress.toAddress(network
            .toNetwork<WalletBitcoinNetwork>()
            .coinParam
            .transacationNetwork),
        balance: IntegerBalance.zero(network.coinParam.decimal));

    return IBitcoinAddress(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: bitcoinAddress,
        addressType: accountParams.bitcoinAddressType,
        network: network.value,
        keyType: accountParams.keyType);
  }
  factory IBitcoinAddress.fromCbsorHex(WalletNetwork network, String hex) {
    return IBitcoinAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.bitcoinMultiSigAccount)) {
      return IBitcoinMultiSigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }
    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.bitcoinAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAt(5));
    final keyType = PubKeyModes.fromValue(cbor.elementAs(8),
        defaultValue: PubKeyModes.compressed);
    final btcNetwork =
        network.toNetwork<WalletBitcoinNetwork>().coinParam.transacationNetwork;
    final bitcoinAddress = BlockchainAddressUtils.toBitcoinAddress(
        address.toAddress, btcNetwork,
        p2shAddressType: bitcoinAddressType);
    if (bitcoinAddress.toAddress(btcNetwork) != address.toAddress ||
        bitcoinAddress.type != bitcoinAddressType) {
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
        accountName: name,
        keyType: keyType);
  }
  IBitcoinAddress(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.networkAddress,
      required this.address,
      required this.addressType,
      required this.network,
      String? accountName,
      required this.keyType})
      : publicKey = List.unmodifiable(publicKey),
        _accountName = accountName;

  @override
  final CryptoCoins coin;
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
          accountName ?? const CborNullValue(),
          keyType.value
        ]),
        CborTagsConst.bitcoinAccount);
  }

  @override
  final BitcoinBaseAddress networkAddress;
  final BitcoinAddressType addressType;
  final PubKeyModes keyType;

  @override
  final AccountBalance address;

  @override
  final AddressDerivationIndex keyIndex;
  @override
  bool get multiSigAccount => false;

  @override
  final int network;

  @override
  List get variabels => [addressType, keyIndex, network];

  List<String> get signers => [BytesUtils.toHexString(publicKey)];

  @override
  String accountToString() {
    return "${addressType.value}\n${address.toAddress}";
  }

  @override
  String get type => addressType.value;

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
  String get orginalAddress => address.toAddress;

  @override
  void updateToken(TokenCore token, Token updatedToken) {}

  @override
  bool isEqual(ChainAccount other) {
    return network == other.network && orginalAddress == other.orginalAddress;
  }

  @override
  NewAccountParams toAccountParams() {
    return BitcoinNewAddressParams(
        deriveIndex: keyIndex,
        bitcoinAddressType: addressType,
        coin: coin,
        keyType: keyType);
  }
}

class IBitcoinMultiSigAddress extends IBitcoinAddress
    with BitcoinMultiSigBase
    implements MultiSigCryptoAccountAddress {
  factory IBitcoinMultiSigAddress.newAccount({
    required WalletBitcoinNetwork network,
    required BitcoinMultiSigNewAddressParams accountParam,
  }) {
    try {
      final toBitcoinAddress = accountParam.multiSignatureAddress.fromType(
          network: network.coinParam.transacationNetwork,
          addressType: accountParam.bitcoinAddressType);
      final addressDetauls = AccountBalance(
          address:
              toBitcoinAddress.toAddress(network.coinParam.transacationNetwork),
          balance: IntegerBalance.zero(network.coinParam.decimal));

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
      WalletNetwork network, String hex) {
    return IBitcoinMultiSigAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinMultiSigAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.bitcoinMultiSigAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final BitcoinMultiSignatureAddress multiSignatureAddress =
        BitcoinMultiSignatureAddress.fromCborBytesOrObject(
            obj: cbor.getCborTag(2));
    final int networkId = cbor.elementAt(5);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
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
                .toNetwork<WalletBitcoinNetwork>()
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
      {required super.coin,
      required BitcoinBaseAddress bitcoinAddress,
      required super.address,
      required super.addressType,
      required this.multiSignatureAddress,
      required super.network,
      required super.keyIndex,
      super.accountName})
      : super(
            publicKey: const [],
            networkAddress: bitcoinAddress,
            keyType: PubKeyModes.uncompressed);

  @override
  List<int> get publicKey => throw UnimplementedError();
  @override
  PubKeyModes get keyType => throw UnimplementedError();
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
        CborTagsConst.bitcoinMultiSigAccount);
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
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAddress.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  BitcoinMultiSigNewAddressParams toAccountParams() {
    return BitcoinMultiSigNewAddressParams(
        multiSignatureAddress: multiSignatureAddress,
        bitcoinAddressType: addressType,
        coin: coin);
  }
}

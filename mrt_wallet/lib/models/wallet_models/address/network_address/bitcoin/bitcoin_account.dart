import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/compare/compare.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:bitcoin_base/bitcoin_base.dart'
    show ECPublic, BitcoinAddress, BitcoinAddressType, BitcoinNetwork;
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class IBitcoinAddress with Equatable implements Bip32AddressCore {
  static BitcoinAddress _toBitcoinAddress(
      List<int> publicKey, CryptoCoins coin, BitcoinAddressType addressType) {
    final bitcoinPublicKey = ECPublic.fromBytes(publicKey);
    BitcoinAddress address;

    switch (coin.proposal) {
      case BipProposal.bip44:
        address = bitcoinPublicKey.toAddress();
        break;
      case BipProposal.bip49:
        switch (addressType) {
          case BitcoinAddressType.p2wshInP2sh:
            address = bitcoinPublicKey.toP2wshInP2sh();
            break;
          case BitcoinAddressType.p2wpkhInP2sh:
            address = bitcoinPublicKey.toP2wpkhInP2sh();
            break;
          case BitcoinAddressType.p2pkhInP2sh:
            address = bitcoinPublicKey.toP2pkhInP2sh();
            break;
          default:
            address = bitcoinPublicKey.toP2pkInP2sh();
            break;
        }
        break;
      case BipProposal.bip84:
        if (addressType == BitcoinAddressType.p2wsh) {
          address = bitcoinPublicKey.toP2wshAddress();
        } else {
          address = bitcoinPublicKey.toSegwitAddress();
        }

        break;
      default:
        address = bitcoinPublicKey.toTaprootAddress();
        break;
    }
    if (address.type != addressType) {
      throw WalletExceptionConst.invalidBitcoinAddressType;
    }

    return address;
  }

  factory IBitcoinAddress.newAccount(
      {required BitcoinNewAddressParams accountParams,
      required List<int> publicKey,
      required AppBitcoinNetwork network}) {
    final bitcoinAddress = _toBitcoinAddress(
        publicKey, accountParams.coin, accountParams.bitcoinAddressType);
    BitcoinNetwork bitcoinNetwork;
    switch (network) {
      case AppBitcoinNetwork.bitcoinMainnet:
        bitcoinNetwork = BitcoinNetwork.mainnet;
        break;
      case AppBitcoinNetwork.bitcoinTestnet:
        bitcoinNetwork = BitcoinNetwork.testnet;
        break;
      default:
        throw WalletExceptionConst.incorrectNetwork;
    }
    final addressDetauls = CryptoAddressDetails(
        address: bitcoinAddress.toAddress(bitcoinNetwork),
        balance: CurrencyBalance.zero(network.coinParam.decimal));

    return IBitcoinAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        bitcoinAddress: bitcoinAddress,
        addressType: accountParams.bitcoinAddressType,
        network: network);
  }
  factory IBitcoinAddress.fromCbsorHex(String hex) {
    return IBitcoinAddress.fromCborBytesOrObject(
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinAddress.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
      if (bytesEqual(
          toCborTag.tags, WalletModelCborTagsConst.bitcoinMultiSigAccount)) {
        return IBitcoinMultiSigAddress.fromCborBytesOrObject(obj: toCborTag);
      }

      final CborListValue cbor = CborSerializable.decodeCborTags(
          null, toCborTag, WalletModelCborTagsConst.bitcoinAccoint);
      final CryptoProposal proposal =
          CryptoProposal.fromName(cbor.value[0].value);
      final CryptoCoins coin =
          CryptoCoins.getCoin(cbor.value[1].value, proposal)!;
      final keyIndex =
          AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.value[2]);
      final List<int> publicKey = cbor.value[3].value;
      final network = AppBitcoinNetwork.fromValue(cbor.value[6].value);
      final CryptoAddressDetails address =
          CryptoAddressDetails.fromCborBytesOrObject(network.coinParam.decimal,
              obj: cbor.value[4]);

      final BitcoinAddressType bitcoinAddressType =
          BitcoinAddressType.fromNameOrValue(cbor.value[5].value);
      final bitcoinAddress =
          _toBitcoinAddress(publicKey, coin, bitcoinAddressType);

      return IBitcoinAddress._(
          coin: coin,
          publicKey: publicKey,
          address: address,
          keyIndex: keyIndex,
          bitcoinAddress: bitcoinAddress,
          addressType: bitcoinAddressType,
          network: network);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  IBitcoinAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.bitcoinAddress,
      required this.address,
      required this.addressType,
      required this.network})
      : publicKey = List.unmodifiable(publicKey);

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
          network.value
        ]),
        WalletModelCborTagsConst.bitcoinAccoint);
  }

  final BitcoinAddress bitcoinAddress;
  final BitcoinAddressType addressType;

  @override
  final CryptoAddressDetailsCore address;

  @override
  final AddressDerivationIndex keyIndex;
  bool get isMultiSigAccounts => false;

  @override
  final AppBitcoinNetwork network;

  @override
  List get variabels => [addressType, keyIndex, network];

  @override
  List<String> get signers => [BytesUtils.toHexString(publicKey)];

  @override
  String accountToString() {
    return "${addressType.value}\n${address.toAddress}";
  }
}

class IBitcoinMultiSigAddress extends IBitcoinAddress {
  factory IBitcoinMultiSigAddress.newAccount({
    required BitcoinMultiSignatureAddress multiSignatureAddress,
    required AppBitcoinNetwork network,
    required CryptoCoins coin,
    required BitcoinAddressType bitcoinAddressType,
  }) {
    try {
      BitcoinNetwork bitcoinNetwork;
      switch (network) {
        case AppBitcoinNetwork.bitcoinMainnet:
          bitcoinNetwork = BitcoinNetwork.mainnet;
          break;
        case AppBitcoinNetwork.bitcoinTestnet:
          bitcoinNetwork = BitcoinNetwork.testnet;
          break;
        default:
          throw WalletExceptionConst.incorrectNetwork;
      }
      BitcoinAddress? bitcoinAddress;
      switch (bitcoinAddressType) {
        case BitcoinAddressType.p2wsh:
          bitcoinAddress = multiSignatureAddress.toP2wshAddress();
          break;
        case BitcoinAddressType.p2wshInP2sh:
          bitcoinAddress = multiSignatureAddress.toP2wshInP2shAddress();
        default:
      }
      final addressDetauls = CryptoAddressDetails(
          address: bitcoinAddress!.toAddress(bitcoinNetwork),
          balance: CurrencyBalance.zero(network.coinParam.decimal));

      return IBitcoinMultiSigAddress._(
          coin: coin,
          address: addressDetauls,
          multiSignatureAddress: multiSignatureAddress,
          bitcoinAddress: bitcoinAddress,
          addressType: bitcoinAddressType,
          network: network,
          keyIndex: const MultiSigAddressIndex());
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  factory IBitcoinMultiSigAddress.fromCborHex(String hex) {
    return IBitcoinMultiSigAddress.fromCborBytesOrObject(
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinMultiSigAddress.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.bitcoinMultiSigAccount);
      final CryptoProposal proposal =
          CryptoProposal.fromName(cbor.value[0].value);
      final CryptoCoins coin =
          CryptoCoins.getCoin(cbor.value[1].value, proposal)!;
      final BitcoinMultiSignatureAddress multiSignatureAddress =
          BitcoinMultiSignatureAddress.fromCborBytesOrObject(
              obj: cbor.value[2]);
      final network = AppBitcoinNetwork.fromValue(cbor.value[5].value);
      final CryptoAddressDetails address =
          CryptoAddressDetails.fromCborBytesOrObject(network.coinParam.decimal,
              obj: cbor.value[3]);
      final BitcoinAddressType bitcoinAddressType =
          BitcoinAddressType.fromNameOrValue(cbor.value[4].value);

      BitcoinAddress? bitcoinAddress;
      switch (bitcoinAddressType) {
        case BitcoinAddressType.p2wsh:
          bitcoinAddress = multiSignatureAddress.toP2wshAddress();
          break;
        case BitcoinAddressType.p2wshInP2sh:
          bitcoinAddress = multiSignatureAddress.toP2wshInP2shAddress();
        default:
      }

      final keyIndex =
          AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.value[6]);
      return IBitcoinMultiSigAddress._(
          coin: coin,
          address: address,
          bitcoinAddress: bitcoinAddress!,
          addressType: bitcoinAddressType,
          multiSignatureAddress: multiSignatureAddress,
          network: network,
          keyIndex: keyIndex);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  IBitcoinMultiSigAddress._(
      {required CryptoCoins coin,
      required BitcoinAddress bitcoinAddress,
      required CryptoAddressDetailsCore address,
      required BitcoinAddressType addressType,
      required this.multiSignatureAddress,
      required super.network,
      required super.keyIndex})
      : super._(
            coin: coin,
            publicKey: const [],
            bitcoinAddress: bitcoinAddress,
            address: address,
            addressType: addressType);

  @override
  List<int> get publicKey => throw UnimplementedError();

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
          network.value,
          keyIndex.toCbor(),
        ]),
        WalletModelCborTagsConst.bitcoinMultiSigAccount);
  }

  @override
  bool get isMultiSigAccounts => true;
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
}

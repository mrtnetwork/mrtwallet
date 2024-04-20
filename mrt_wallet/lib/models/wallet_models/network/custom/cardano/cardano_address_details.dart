import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/keys/master_key.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/ada/src/address/address.dart';

class CardanoAddrDetails with CborSerializable {
  final List<int> publicKey;
  final List<int>? stakePubkey;
  final List<int>? chainCode;
  final List<int>? hdPathKey;
  final String? hdPath;
  final ADAAddressType addressType;
  final SeedGenerationType seedGeneration;

  factory CardanoAddrDetails.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cardanoAccountDetails);
    return CardanoAddrDetails._(
        publicKey: cbor.elementAt(0),
        addressType: ADAAddressType.fromHeader(cbor.elementAt(1)),
        stakePubkey: cbor.elementAt(2),
        chainCode: cbor.elementAt(3),
        hdPathKey: cbor.elementAt(4),
        hdPath: cbor.elementAt(5),
        seedGeneration: SeedGenerationType.fromName(cbor.elementAt<String>(6)));
  }
  CardanoAddrDetails._({
    required List<int> publicKey,
    required this.addressType,
    required this.seedGeneration,
    List<int>? stakePubkey,
    List<int>? chainCode,
    List<int>? hdPathKey,
    this.hdPath,
  })  : publicKey = BytesUtils.toBytes(publicKey, unmodifiable: true),
        stakePubkey = BytesUtils.tryToBytes(stakePubkey, unmodifiable: true),
        chainCode = BytesUtils.tryToBytes(chainCode, unmodifiable: true),
        hdPathKey = BytesUtils.tryToBytes(hdPathKey, unmodifiable: true);
  factory CardanoAddrDetails.shelley({
    required List<int> publicKey,
    required ADAAddressType addressType,
    required SeedGenerationType seedGeneration,
    List<int>? stakePubkey,
  }) {
    if (addressType == ADAAddressType.byron ||
        addressType == ADAAddressType.pointer) {
      throw const MessageException("Unsupported address type.");
    }
    if (addressType == ADAAddressType.base && stakePubkey == null) {
      throw const MessageException(
          "Stake public key is required for base address.");
    }
    if (addressType != ADAAddressType.base && stakePubkey != null) {
      throw const MessageException(
          "Stake public key must be provided for base address type, please set it to null.");
    }
    return CardanoAddrDetails._(
        publicKey: publicKey,
        addressType: addressType,
        stakePubkey: stakePubkey,
        seedGeneration: seedGeneration);
  }
  factory CardanoAddrDetails.byron(
      {required List<int> publicKey,
      required List<int> chainCode,
      required SeedGenerationType seedGeneration,
      List<int>? hdPathKey,
      String? hdPath}) {
    if (hdPath != null && hdPathKey == null ||
        hdPath == null && hdPathKey != null) {
      throw const MessageException(
          "hdPath and hdPathKey should be used together.");
    }
    return CardanoAddrDetails._(
        publicKey: publicKey,
        addressType: ADAAddressType.byron,
        hdPathKey: hdPathKey,
        chainCode: chainCode,
        hdPath: hdPath,
        seedGeneration: seedGeneration);
  }

  ADAAddress toAddress(CryptoCoins coin) {
    final adaNetwork =
        coin.conf.isTestnet ? ADANetwork.testnetPreprod : ADANetwork.mainnet;
    switch (addressType) {
      case ADAAddressType.base:
        return ADABaseAddress.fromPublicKey(
            basePubkeyBytes: publicKey,
            stakePubkeyBytes: stakePubkey!,
            network: adaNetwork);
      case ADAAddressType.enterprise:
        return ADAEnterpriseAddress.fromPublicKey(
            pubkeyBytes: publicKey, network: adaNetwork);
      case ADAAddressType.reward:
        return ADARewardAddress.fromPublicKey(
            pubkeyBytes: publicKey, network: adaNetwork);
      case ADAAddressType.byron:
        return ADAByronAddress.fromPublicKey(
            publicKey: publicKey,
            chaincode: chainCode!,
            hdPath: hdPath,
            hdPathKey: hdPathKey,
            network: adaNetwork);
      default:
        throw const MessageException("Invalid address type.");
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(publicKey),
          CborIntValue(addressType.header),
          stakePubkey == null
              ? const CborNullValue()
              : CborBytesValue(stakePubkey!),
          chainCode == null
              ? const CborNullValue()
              : CborBytesValue(chainCode!),
          hdPathKey == null
              ? const CborNullValue()
              : CborBytesValue(hdPathKey!),
          hdPath == null ? const CborNullValue() : CborStringValue(hdPath!),
          CborStringValue(seedGeneration.name)
        ]),
        WalletModelCborTagsConst.cardanoAccountDetails);
  }
}

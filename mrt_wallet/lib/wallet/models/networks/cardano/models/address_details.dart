import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:on_chain/ada/src/address/address.dart';
import 'package:on_chain/ada/src/models/ada_models.dart';

class CardanoAddrDetails with Equatable, CborSerializable {
  final List<int> publicKey;
  final List<int>? stakePubkey;
  final List<int>? chainCode;
  final List<int>? hdPathKey;
  final String? hdPath;
  late final String? hdPathKeyHex = BytesUtils.tryToHexString(hdPathKey);
  final ADAAddressType addressType;
  bool get isLegacy => hdPath != null;

  PolicyID policyId() {
    final keyHash = Ed25519KeyHash.fromPubkey(publicKey);
    final mintScript = NativeScriptScriptPubkey(keyHash);
    return PolicyID(mintScript.toHash().data);
  }

  NativeScript toNativeScript() {
    final keyHash = Ed25519KeyHash.fromPubkey(publicKey);
    return NativeScriptScriptPubkey(keyHash);
  }

  factory CardanoAddrDetails.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cardanoAccountDetails);
    return CardanoAddrDetails._(
        publicKey: cbor.elementAt(0),
        addressType: ADAAddressType.fromHeader(cbor.elementAt(1)),
        stakePubkey: cbor.elementAt(2),
        chainCode: cbor.elementAt(3),
        hdPathKey: cbor.elementAt(4),
        hdPath: cbor.elementAt(5));
  }
  CardanoAddrDetails._({
    required List<int> publicKey,
    required this.addressType,
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
    required SeedTypes seedGeneration,
    List<int>? stakePubkey,
  }) {
    if (addressType == ADAAddressType.byron ||
        addressType == ADAAddressType.pointer) {
      throw WalletException("Unsupported address type.");
    }
    if (addressType == ADAAddressType.base && stakePubkey == null) {
      throw WalletException("Stake public key is required for base address.");
    }
    if (addressType != ADAAddressType.base && stakePubkey != null) {
      throw WalletException(
          "Stake public key must be provided for base address type, please set it to null.");
    }
    return CardanoAddrDetails._(
        publicKey: publicKey,
        addressType: addressType,
        stakePubkey: stakePubkey);
  }
  factory CardanoAddrDetails.byron(
      {required List<int> publicKey,
      required List<int> chainCode,
      required SeedTypes seedGeneration,
      List<int>? hdPathKey,
      String? hdPath}) {
    if (hdPath != null && hdPathKey == null ||
        hdPath == null && hdPathKey != null) {
      throw WalletException("hdPath and hdPathKey should be used together.");
    }
    return CardanoAddrDetails._(
        publicKey: publicKey,
        addressType: ADAAddressType.byron,
        hdPathKey: hdPathKey,
        chainCode: chainCode,
        hdPath: hdPath);
  }

  ADAAddress toAddress(CryptoCoins coin, bool testnet) {
    final adaNetwork = testnet ? ADANetwork.testnetPreprod : ADANetwork.mainnet;
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
        throw WalletException("Invalid address type.");
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
        ]),
        CborTagsConst.cardanoAccountDetails);
  }

  @override
  List get variabels =>
      [publicKey, hdPath, hdPathKeyHex, chainCode, addressType];
}

import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

import 'setting.dart';

class WalletMasterKeys with CborSerializable {
  WalletMasterKeys._(
      this.mnemonic, List<int> seedBytes, this.customKeys, this.setting)
      : seed = List<int>.unmodifiable(seedBytes);
  WalletMasterKeys addKey(WalletCustomKeys newKey) {
    return WalletMasterKeys._(
        mnemonic, seed, List.unmodifiable([newKey, ...customKeys]), setting);
  }

  WalletMasterKeys removeKey(String keyId) {
    final accounts = customKeys.where((element) => element.checksum != keyId);
    return WalletMasterKeys._(
        mnemonic, seed, List.unmodifiable(accounts), setting);
  }

  WalletMasterKeys updateSetting(WalletSetting newSetting) {
    return WalletMasterKeys._(mnemonic, seed, customKeys, newSetting);
  }

  final WalletSetting setting;
  final Mnemonic mnemonic;
  final List<int> seed;
  static Future<WalletMasterKeys> setup(String mnemonic, String passphrase,
      {List<WalletCustomKeys> customKeys = const []}) async {
    final seed =
        await BlockchainUtils.mnemonicToSeed(mnemonic, passphrase: passphrase);
    return WalletMasterKeys._(Mnemonic.fromString(mnemonic), seed,
        List.unmodifiable(customKeys), WalletSetting.defaultSetting());
  }

  factory WalletMasterKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.mnemonic);
      final String mnemonic = cbor.value[0].value;
      final List<int> seed = cbor.value[1].value;
      final CborListValue customKeys = cbor.value[2];
      final WalletSetting setting =
          WalletSetting.fromCborBytesOrObject(obj: cbor.value[3]);
      return WalletMasterKeys._(
          Mnemonic.fromString(mnemonic),
          seed,
          List<WalletCustomKeys>.unmodifiable(customKeys.value
              .map((e) => WalletCustomKeys.fromCborBytesOrObject(obj: e))
              .toList()),
          setting);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  List<String> get toList => mnemonic.toList();
  final List<WalletCustomKeys> customKeys;
  @override
  CborTagValue toCbor([bool withSeed = true]) {
    return CborTagValue(
        CborListValue.fixedLength([
          mnemonic.toStr(),
          if (withSeed) CborBytesValue(seed) else const CborBytesValue([]),
          CborListValue.fixedLength(customKeys.map((e) => e.toCbor()).toList()),
          setting.toCbor()
        ]),
        WalletModelCborTagsConst.mnemonic);
  }

  WalletCustomKeys? getKeyById(String keyId) {
    try {
      return customKeys.firstWhere((element) => element.checksum == keyId);
    } on StateError {
      return null;
    }
  }
}

class WalletCustomKeys with CborSerializable, Equatable {
  WalletCustomKeys(
      {required this.checksum,
      required this.extendedPrivateKey,
      required this.type,
      required this.publicKey,
      required this.name,
      DateTime? created})
      : created = created ?? DateTime.now();
  final String checksum;
  final String extendedPrivateKey;
  final String publicKey;
  final String? name;
  final DateTime created;

  final EllipticCurveTypes type;
  factory WalletCustomKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.walletCustomKey);
      final String checksum = cbor.getIndex(0);
      final String extendedPrivateKey = cbor.getIndex(1);
      final String publicKey = cbor.getIndex(2);
      final String curveName = cbor.getIndex(3);
      final curve = EllipticCurveTypes.fromName(curveName);
      final DateTime created = cbor.getIndex(4);
      final String? name = cbor.getIndex(5);
      return WalletCustomKeys(
          checksum: checksum,
          extendedPrivateKey: extendedPrivateKey,
          type: curve,
          publicKey: publicKey,
          created: created,
          name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          checksum,
          extendedPrivateKey,
          publicKey,
          type.name,
          CborEpochIntValue(created),
          name
        ]),
        WalletModelCborTagsConst.walletCustomKey);
  }

  @override
  List get variabels => [checksum, extendedPrivateKey, type, publicKey];

  Bip32Base toBip32() {
    switch (type) {
      case EllipticCurveTypes.ed25519:
        return Bip32Slip10Ed25519.fromExtendedKey(extendedPrivateKey);
      default:
        return Bip32Slip10Secp256k1.fromExtendedKey(extendedPrivateKey);
    }
  }
}

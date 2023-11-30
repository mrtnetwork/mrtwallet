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

  WalletMasterKeys updateSetting(WalletSetting newSetting) {
    return WalletMasterKeys._(mnemonic, seed, customKeys, newSetting);
  }

  final WalletSetting setting;
  final Mnemonic mnemonic;
  final List<int> seed;
  static Future<WalletMasterKeys> setup(
      String mnemonic, String passphrase) async {
    // BlockchainUtils.validateMnemonic(mnemonic);
    final seed =
        await BlockchainUtils.mnemonicToSeed(mnemonic, passphrase: passphrase);
    return WalletMasterKeys._(Mnemonic.fromString(mnemonic), seed, const [],
        WalletSetting.defaultSetting());
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
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          mnemonic.toStr(),
          CborBytesValue(seed),
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
      DateTime? created})
      : created = created ?? DateTime.now();
  final String checksum;
  final String extendedPrivateKey;
  final String publicKey;
  final DateTime created;

  final EllipticCurveTypes type;
  factory WalletCustomKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.walletCustomKey);
      final String checksum = cbor.value[0].value;
      final String extendedPrivateKey = cbor.value[1].value;
      final String publicKey = cbor.value[2].value;
      final String curveName = cbor.value[3].value;
      final curve = EllipticCurveTypes.fromName(curveName);
      final DateTime created = cbor.value[4].value;
      return WalletCustomKeys(
          checksum: checksum,
          extendedPrivateKey: extendedPrivateKey,
          type: curve,
          publicKey: publicKey,
          created: created);
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
          CborEpochIntValue(created)
        ]),
        WalletModelCborTagsConst.walletCustomKey);
  }

  @override
  List get variabels => [checksum, extendedPrivateKey, type, publicKey];
}

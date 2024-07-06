import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/chain/handler/chain.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

enum MrtBackupTypes {
  wallet(CborTagsConst.mrtBackupWallet, "wallets"),
  mnemonic(CborTagsConst.mrtBackupMnemonic, "mnemonic"),
  privatekey(CborTagsConst.mrtBackupPrivateKey, "private_key"),
  wif(CborTagsConst.mrtBackupWif, "wif"),
  keystore([], "keystore"),
  extendedKey(CborTagsConst.mrtBackupExtendedKey, "extended_private_key");

  final List<int> tag;
  final String value;
  const MrtBackupTypes(this.tag, this.value);

  static MrtBackupTypes fromValue(List<int> tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag));
  }

  SecretWalletEncoding get encoding {
    switch (this) {
      case MrtBackupTypes.keystore:
        return SecretWalletEncoding.json;
      default:
        return SecretWalletEncoding.cbor;
    }
  }

  bool get isPrivateKey =>
      this == MrtBackupTypes.privatekey || this == MrtBackupTypes.keystore;

  List<int> toEncryptionBytes(String data) {
    switch (this) {
      case MrtBackupTypes.mnemonic:
        return StringUtils.encode(value);
      case MrtBackupTypes.keystore:
      case MrtBackupTypes.privatekey:
      case MrtBackupTypes.wallet:
        return BytesUtils.fromHexString(data);
      default:
        return Base58Decoder.checkDecode(data);
    }
  }

  String fromDecyrptBytes(List<int> decryptedKeyBytes) {
    switch (this) {
      case MrtBackupTypes.mnemonic:
        return StringUtils.decode(decryptedKeyBytes);
      case MrtBackupTypes.privatekey:
      case MrtBackupTypes.wallet:
      case MrtBackupTypes.keystore:
        return BytesUtils.toHexString(decryptedKeyBytes);

      default:
        return Base58Encoder.checkEncode(decryptedKeyBytes);
    }
  }
}

abstract class MRTBackup {
  abstract final MrtBackupTypes type;
  abstract final DateTime created;
  abstract final String key;
  abstract final bool isEncrypted;
  factory MRTBackup.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final type = MrtBackupTypes.fromValue(tag.tags);
    if (type == MrtBackupTypes.wallet) {
      return MRTWalletBackup.fromCborBytesOrObject(obj: tag);
    }
    return MRTKeyBackup.fromCborBytesOrObject(obj: tag);
  }
  MRTBackup decrypt(List<int> decryptedKey);
}

class MRTWalletBackup implements MRTBackup {
  MRTWalletBackup._(
      {required this.key,
      required List<ChainHandler> chains,
      DateTime? created,
      this.isEncrypted = true})
      : chains = List.unmodifiable(chains),
        created = created ?? DateTime.now();
  factory MRTWalletBackup(
      {required String key,
      required List<ChainHandler> chains,
      DateTime? created}) {
    return MRTWalletBackup._(key: key, chains: chains, created: created);
  }
  factory MRTWalletBackup.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: MrtBackupTypes.wallet.tag);
    return MRTWalletBackup(
        key: values.elementAt(0),
        chains: values
            .elementAt<List<dynamic>>(1)
            .map((e) => ChainHandler.fromCborBytesOrObject(obj: e))
            .toList(),
        created: values.elementAt(2));
  }

  @override
  final String key;
  final List<ChainHandler> chains;
  @override
  final DateTime created;

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(key),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList()),
          CborEpochIntValue(created),
        ]),
        type.tag);
  }

  @override
  MrtBackupTypes get type => MrtBackupTypes.wallet;

  @override
  final bool isEncrypted;

  @override
  MRTBackup decrypt(List<int> decryptedKeyBytes) {
    return MRTWalletBackup._(
      key: type.fromDecyrptBytes(decryptedKeyBytes),
      created: created,
      isEncrypted: false,
      chains: chains,
    );
  }
}

class MRTKeyBackup implements MRTBackup {
  MRTKeyBackup._(
      {required this.key,
      required this.type,
      required this.created,
      this.isEncrypted = true});
  factory MRTKeyBackup(
      {required String key, required MrtBackupTypes type, DateTime? created}) {
    if (type == MrtBackupTypes.wallet) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return MRTKeyBackup._(
        key: key, type: type, created: created ?? DateTime.now());
  }
  factory MRTKeyBackup.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final CborListValue values = CborSerializable.cborTagValue(object: tag);
    return MRTKeyBackup(
        key: values.elementAt(0),
        created: values.elementAt(1),
        type: MrtBackupTypes.fromValue(tag.tags));
  }

  @override
  final String key;
  @override
  final DateTime created;

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborStringValue(key), CborEpochIntValue(created)]),
        type.tag);
  }

  @override
  final MrtBackupTypes type;

  @override
  final bool isEncrypted;

  @override
  MRTBackup decrypt(List<int> decryptedKeyBytes) {
    return MRTKeyBackup._(
      key: type.fromDecyrptBytes(decryptedKeyBytes),
      type: type,
      created: created,
      isEncrypted: false,
    );
  }
}

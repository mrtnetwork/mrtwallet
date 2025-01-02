import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/backup/core/mrt_backup.dart';
import 'package:mrt_wallet/wallet/models/backup/types/backup_types.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class MRTWalletBackupChainRepository with CborSerializable {
  final String value;
  final int storageID;
  final int networkID;
  final String? identifier;

  const MRTWalletBackupChainRepository(
      {required this.storageID,
      required this.identifier,
      required this.value,
      required this.networkID});
  factory MRTWalletBackupChainRepository.deserlize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.mrtWalletBackupStorageIds);

    return MRTWalletBackupChainRepository(
        value: values.elementAs(0),
        storageID: values.elementAs(1),
        identifier: values.elementAs(2),
        networkID: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([value, storageID, identifier, networkID]),
        CborTagsConst.mrtWalletBackupStorageIds);
  }
}

class MRTWalletChainBackup with CborSerializable {
  final Chain chain;
  final List<MRTWalletBackupChainRepository> repositories;
  MRTWalletChainBackup(
      {required this.chain,
      List<MRTWalletBackupChainRepository> repositories = const []})
      : repositories = repositories.immutable;
  factory MRTWalletChainBackup.deserlize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.mrtWalletBackupChains);

    return MRTWalletChainBackup(
        chain: Chain.deserialize(obj: values.getCborTag(0)),
        repositories: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MRTWalletBackupChainRepository.deserlize(obj: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          chain.toCbor(),
          CborListValue.fixedLength(
              repositories.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.mrtWalletBackupChains);
  }
}

abstract class MRTWalletBackup implements MRTBackup {
  List<MRTWalletChainBackup> get chains;
}

class MRTWalletBackupV1 implements MRTWalletBackup {
  MRTWalletBackupV1._(
      {required this.key,
      required List<MRTWalletChainBackup> chains,
      DateTime? created,
      this.isEncrypted = true})
      : chains = List.unmodifiable(chains),
        created = created ?? DateTime.now();
  factory MRTWalletBackupV1(
      {required String key,
      required List<MRTWalletChainBackup> chains,
      DateTime? created}) {
    return MRTWalletBackupV1._(key: key, chains: chains, created: created);
  }
  factory MRTWalletBackupV1.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: MrtBackupTypes.wallet.tag);

    return MRTWalletBackupV1(
        key: values.elementAs(0),
        chains: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MRTWalletChainBackup(chain: Chain.deserialize(obj: e)))
            .toList(),
        created: values.elementAt(2));
  }

  @override
  final String key;

  @override
  final List<MRTWalletChainBackup> chains;

  @override
  final DateTime created;

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(key),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList()),
          CborEpochIntValue(created)
        ]),
        type.tag);
  }

  @override
  MrtBackupTypes get type => MrtBackupTypes.wallet;

  @override
  final bool isEncrypted;

  @override
  MRTBackup decrypt(List<int> decryptedKeyBytes) {
    return MRTWalletBackupV1._(
        key: type.fromDecyrptBytes(decryptedKeyBytes),
        created: created,
        isEncrypted: false,
        chains: chains);
  }
}

class MRTWalletBackupV2 implements MRTWalletBackup {
  @override
  final List<MRTWalletChainBackup> chains;
  MRTWalletBackupV2._(
      {required this.key,
      required List<MRTWalletChainBackup> chains,
      DateTime? created,
      this.isEncrypted = true})
      : chains = List.unmodifiable(chains),
        created = created ?? DateTime.now();
  factory MRTWalletBackupV2(
      {required String key,
      required List<MRTWalletChainBackup> chains,
      DateTime? created}) {
    return MRTWalletBackupV2._(key: key, chains: chains, created: created);
  }
  factory MRTWalletBackupV2.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: MrtBackupTypes.walletV2.tag);

    /// id: "backup"
    return MRTWalletBackupV2(
        key: values.elementAt(0),
        chains: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MRTWalletChainBackup.deserlize(obj: e))
            .toList(),
        created: values.elementAt(2));
  }

  @override
  final String key;

  @override
  final DateTime created;

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(key),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList()),
          CborEpochIntValue(created)
        ]),
        type.tag);
  }

  @override
  MrtBackupTypes get type => MrtBackupTypes.walletV2;

  @override
  final bool isEncrypted;

  @override
  MRTBackup decrypt(List<int> decryptedKeyBytes) {
    return MRTWalletBackupV2._(
        key: type.fromDecyrptBytes(decryptedKeyBytes),
        created: created,
        isEncrypted: false,
        chains: chains);
  }
}

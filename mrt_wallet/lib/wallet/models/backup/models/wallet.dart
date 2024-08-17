import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/backup/core/mrt_backup.dart';
import 'package:mrt_wallet/wallet/models/backup/types/backup_types.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class MRTWalletBackup implements MRTBackup {
  MRTWalletBackup._(
      {required this.key,
      required List<Chain> chains,
      DateTime? created,
      this.isEncrypted = true})
      : chains = List.unmodifiable(chains),
        created = created ?? DateTime.now();
  factory MRTWalletBackup(
      {required String key, required List<Chain> chains, DateTime? created}) {
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
            .map((e) => Chain.deserialize(obj: e, id: "backup"))
            .toList(),
        created: values.elementAt(2));
  }

  @override
  final String key;
  final List<Chain> chains;
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

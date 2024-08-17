import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/backup/core/mrt_backup.dart';
import 'package:mrt_wallet/wallet/models/backup/types/backup_types.dart';

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

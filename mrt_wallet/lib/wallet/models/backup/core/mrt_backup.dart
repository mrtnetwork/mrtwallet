import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/models/backup/models/keys.dart';
import 'package:mrt_wallet/wallet/models/backup/models/wallet.dart';
import 'package:mrt_wallet/wallet/models/backup/types/backup_types.dart';

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

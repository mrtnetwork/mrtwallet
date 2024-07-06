import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/chain/handler/chain.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wroker/keys/models/master_key.dart';

abstract class WalletBackupCore with CborSerializable {
  abstract final WalletMasterKeys masterKeys;
  abstract final List<ChainHandler> chains;
}

class WalletBackupV2 implements WalletBackupCore {
  WalletBackupV2(
      {required this.masterKeys,
      required List<ChainHandler> chains,
      required this.created})
      : chains = List.unmodifiable(chains);
  @override
  final WalletMasterKeys masterKeys;
  @override
  final List<ChainHandler> chains;
  final DateTime? created;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterKeys.toCbor(false),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList()),
          if (created != null) CborEpochIntValue(created!),
        ]),
        CborTagsConst.backupV2);
  }
}

class WalletBackupV3 implements WalletBackupCore {
  WalletBackupV3(
      {required this.encryptedMasterKey,
      required List<ChainHandler> chains,
      required this.created})
      : chains = List.unmodifiable(chains);
  factory WalletBackupV3.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.backupV3);
    return WalletBackupV3(
        encryptedMasterKey: values.elementAt(0),
        chains: values
            .elementAt<List<dynamic>>(1)
            .map((e) => ChainHandler.fromCborBytesOrObject(obj: e))
            .toList(),
        created: values.elementAt(1));
  }

  final String encryptedMasterKey;
  @override
  final List<ChainHandler> chains;
  final DateTime created;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(encryptedMasterKey),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList()),
          CborEpochIntValue(created),
        ]),
        CborTagsConst.backupV3);
  }

  @override
  WalletMasterKeys get masterKeys => throw UnimplementedError();
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/chain/handler/chain.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
import 'package:mrt_wallet/wroker/keys/models/master_key.dart';

abstract class WalletBackupCore with CborSerializable {
  abstract final WalletMasterKeys masterKeys;
  abstract final List<ChainHandler> chains;
  // abstract final HDWallet wallet;
}

class WalletBackupV2 implements WalletBackupCore {
  WalletBackupV2(
      {required this.masterKeys,
      required List<ChainHandler> chains,
      required this.wallet,
      required this.created})
      : chains = List.unmodifiable(chains);
  @override
  final WalletMasterKeys masterKeys;
  @override
  final List<ChainHandler> chains;
  final DateTime? created;

  final HDWallet wallet;

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

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

abstract class WalletBackupCore with CborSerializable {}

class WalletBackup implements WalletBackupCore {
  const WalletBackup(
      {required this.masterKeys,
      required this.accounts,
      required this.version});
  final WalletMasterKeys masterKeys;
  final List<NetworkAccountCore> accounts;
  final int version;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterKeys.toCbor(false),
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          version
        ]),
        WalletModelCborTagsConst.backup);
  }

  static Future<WalletBackup> fromBackup(
      CborTagValue cborTag, String passhphrase) async {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          null, cborTag, WalletModelCborTagsConst.backup);
      final WalletMasterKeys backupkey =
          WalletMasterKeys.fromCborBytesOrObject(obj: cbor.value[0]);
      final WalletMasterKeys key = await WalletMasterKeys.setup(
          backupkey.mnemonic.toStr(), passhphrase,
          customKeys: backupkey.customKeys);
      final accountList = cbor.elementAt(1);
      final List<Bip32NetworkAccount> accs = [];
      for (final i in accountList) {
        i as CborTagValue;
        final int networkId = i.value.value[0].value;
        final network = ChainUtils.defaultCoins.values
            .firstWhere((element) => element.value == networkId);
        final account =
            Bip32NetworkAccount.fromCborBytesOrObject(network, obj: i);
        accs.add(account);
      }
      return WalletBackup(accounts: [], masterKeys: key, version: 0);
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }
}

class WalletBackupV2 implements WalletBackupCore {
  WalletBackupV2({
    required this.masterKeys,
    required List<AppChain> chains,
  }) : chains = List.unmodifiable(chains);
  final WalletMasterKeys masterKeys;
  final List<AppChain> chains;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterKeys.toCbor(false),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.backupV2);
  }

  static Future<WalletBackupV2> fromBackup(
      List<int> cborBytes, String passhphrase) async {
    try {
      /// tryversion 1
      try {
        final obj = CborObject.fromCbor(
                BytesUtils.fromHexString(StringUtils.decode(cborBytes)))
            as CborTagValue;
        final v1 = await WalletBackup.fromBackup(obj, passhphrase);
        final v1Chains =
            v1.accounts.map((e) => AppChain.fromAccount(e)).toList();
        return WalletBackupV2(chains: v1Chains, masterKeys: v1.masterKeys);
        // ignore: empty_catches
      } catch (e) {}
      final obj = CborObject.fromCbor(cborBytes);
      final CborListValue cbor = CborSerializable.decodeCborTags(
          null, obj, WalletModelCborTagsConst.backupV2);
      final WalletMasterKeys backupkey =
          WalletMasterKeys.fromCborBytesOrObject(obj: cbor.value[0]);
      final WalletMasterKeys key = await WalletMasterKeys.setup(
          backupkey.mnemonic.toStr(), passhphrase,
          customKeys: backupkey.customKeys);
      final List<dynamic> accountList = cbor.elementAt(1);
      final List<AppChain> chains = [];
      for (final i in accountList) {
        final appChain = AppChain.fromCborBytesOrObject(obj: i);
        chains.add(appChain);
      }
      return WalletBackupV2(chains: chains, masterKeys: key);
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }
}

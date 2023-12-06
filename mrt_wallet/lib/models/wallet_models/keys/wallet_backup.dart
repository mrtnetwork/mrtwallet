import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class WalletBackup with CborSerializable {
  const WalletBackup({required this.masterKeys, required this.accounts});
  final WalletMasterKeys masterKeys;
  final List<NetworkAccountCore> accounts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterKeys.toCbor(false),
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.backup);
  }

  static Future<WalletBackup> fromBackup(
      String cborHex, String passhphrase) async {
    try {
      final obj = CborObject.fromCborHex(cborHex);
      final CborListValue cbor = CborSerializable.decodeCborTags(
          null, obj, WalletModelCborTagsConst.backup);
      final WalletMasterKeys backupkey =
          WalletMasterKeys.fromCborBytesOrObject(obj: cbor.value[0]);
      final WalletMasterKeys key = await WalletMasterKeys.setup(
          backupkey.mnemonic.toStr(), passhphrase,
          customKeys: backupkey.customKeys);
      final CborListValue accountList = cbor.value[1];
      final accs = accountList.value
          .map((e) => Bip32NetworkAccount.fromCborBytesOrObject(obj: e))
          .toList();

      return WalletBackup(accounts: accs, masterKeys: key);
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }
}

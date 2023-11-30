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
          masterKeys.toCbor(),
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.backup);
  }

  factory WalletBackup.fromCborHex(String cborHex) {
    final obj = CborObject.fromCborHex(cborHex);
    return WalletBackup.fromCborBytesOrObject(obj: obj);
  }
  factory WalletBackup.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.backup);
      final WalletMasterKeys keys =
          WalletMasterKeys.fromCborBytesOrObject(obj: cbor.value[0]);
      final CborListValue accountList = cbor.value[1];
      final accs = accountList.value
          .map((e) => Bip32NetworkAccount.fromCborBytesOrObject(obj: e))
          .toList();

      return WalletBackup(accounts: accs, masterKeys: keys);
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/compare/compare.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

abstract class AddressDerivationIndex with CborSerializable, Equatable {
  const AddressDerivationIndex();
  String get path;
  static AddressDerivationIndex fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final cbor = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (bytesEqual(cbor.tags, WalletModelCborTagsConst.accoutKeyIndex)) {
      return Bip32AddressIndex.fromCborBytesOrObject(obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.multiSigAccountKeyIndex)) {
      return const MultiSigAddressIndex();
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.importedAccountKeyIndex)) {
      return ImportedAddressIndex.fromCborBytesOrObject(obj: cbor);
    } else {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  T derive<T>(T derivator);
}

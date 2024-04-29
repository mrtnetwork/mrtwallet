import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

enum AddressDerivationType {
  bip32,
  multisig;

  bool get isMultiSig => this == AddressDerivationType.multisig;
}

abstract class AddressDerivationIndex with CborSerializable, Equatable {
  String? get hdPath;
  // String get hdPath;
  CryptoCoins get currencyCoin;
  AddressDerivationType get derivationType;
  bool get isImportedKey;
  String get name;
  // bool get is;

  const AddressDerivationIndex();
  static AddressDerivationIndex fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final cbor = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (bytesEqual(cbor.tags, WalletModelCborTagsConst.accoutKeyIndex)) {
      return Bip32AddressIndex.fromCborBytesOrObject(obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.multiSigAccountKeyIndex)) {
      return const MultiSigAddressIndex();
    } else {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  T derive<T extends Bip32Base>(T derivator,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex});

  SeedGenerationType get seedGeneration;
}

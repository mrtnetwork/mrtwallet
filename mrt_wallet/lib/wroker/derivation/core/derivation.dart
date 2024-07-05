import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/keys/models/seed.dart';
import 'package:mrt_wallet/wroker/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/wroker/derivation/derivation/multisig.dart';

enum AddressDerivationType {
  bip32,
  multisig;

  bool get isMultiSig => this == AddressDerivationType.multisig;
}

abstract class AddressDerivationIndex with CborSerializable, Equatable {
  String? get hdPath;
  CryptoCoins get currencyCoin;
  AddressDerivationType get derivationType;
  abstract final String? importedKeyId;
  bool get isImportedKey => importedKeyId != null;
  String get name;
  bool get isMultiSig => derivationType.isMultiSig;

  const AddressDerivationIndex();
  static AddressDerivationIndex fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final cbor = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(cbor.tags, CryptoKeyConst.accoutKeyIndex)) {
      return Bip32AddressIndex.fromCborBytesOrObject(obj: cbor);
    } else if (BytesUtils.bytesEqual(
        cbor.tags, CryptoKeyConst.multiSigAccountKeyIndex)) {
      return const MultiSigAddressIndex();
    } else {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  T derive<T extends Bip32Base>(T derivator,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex});

  SeedTypes get seedGeneration;
}

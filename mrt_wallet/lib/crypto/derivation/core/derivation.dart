import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/substrate.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/multisig.dart';

enum AddressDerivationType {
  bip32(CryptoKeyConst.accoutKeyIndex),
  substrate(CryptoKeyConst.substrateKeyIndex),
  multisig(CryptoKeyConst.multiSigAccountKeyIndex);

  final List<int> tag;
  const AddressDerivationType(this.tag);
  bool get isMultiSig => this == AddressDerivationType.multisig;

  static AddressDerivationType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidAccountDetails);
  }
}

abstract class AddressDerivationIndex with CborSerializable, Equatable {
  String? get hdPath;
  CryptoCoins get currencyCoin;
  AddressDerivationType get derivationType;
  abstract final String? importedKeyId;
  bool get isImportedKey => importedKeyId != null;
  String get name;
  bool get isSubstrate => derivationType == AddressDerivationType.substrate;
  bool get isBip32 => derivationType == AddressDerivationType.bip32;
  bool get isMultiSig => derivationType.isMultiSig;

  /// change address index key (use imported key)
  AddressDerivationIndex asImportedKey(String importKeyId);

  const AddressDerivationIndex();
  static AddressDerivationIndex fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final cbor = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    final key = AddressDerivationType.fromTag(cbor.tags);
    switch (key) {
      case AddressDerivationType.bip32:
        return Bip32AddressIndex.fromCborBytesOrObject(obj: cbor);
      case AddressDerivationType.substrate:
        return SubstrateAddressIndex.fromCborBytesOrObject(obj: cbor);
      case AddressDerivationType.multisig:
        return const MultiSigAddressIndex();
      default:
        throw UnimplementedError("Unsuported key index.");
    }
  }

  PrivateKeyData derive(PrivateKeyData masterKey,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex});

  SeedTypes get seedGeneration;

  T cast<T extends AddressDerivationIndex>() {
    if (this is! T) {
      throw WalletExceptionConst.invalidArgruments(
          "$T", runtimeType.toString());
    }
    return this as T;
  }
}

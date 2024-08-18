import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/crypto/derivation/core/derivation.dart';

class SubstrateAddressIndex extends AddressDerivationIndex {
  @override
  final String? importedKeyId;
  final String? keyName;
  final String? substratePath;

  @override
  String? get hdPath => substratePath;

  @override
  final SeedTypes seedGeneration;

  @override
  final SubstrateCoins currencyCoin;

  SubstrateAddressIndex._(
      {required this.currencyCoin,
      this.importedKeyId,
      this.keyName,
      required this.substratePath})
      : seedGeneration = SeedTypes.bip39Entropy;

  factory SubstrateAddressIndex.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.substrateKeyIndex);
    return SubstrateAddressIndex._(
        currencyCoin: CustomCoins.getCoin(
          name: cbor.elementAt(1),
          proposal: cbor.elementAt(0),
        ),
        substratePath: cbor.elementAt(2),
        importedKeyId: cbor.elementAt(3),
        keyName: cbor.elementAt(4));
  }
  factory SubstrateAddressIndex(
      {required SubstrateCoins currencyCoin,
      String? substratePath,
      String? keyName}) {
    if (substratePath != null) {
      final path = SubstratePathParser.parse(substratePath);
      substratePath = path.elems.isEmpty ? null : path.toStr();
    }

    return SubstrateAddressIndex._(
        currencyCoin: currencyCoin,
        keyName: keyName,
        substratePath: substratePath);
  }

  factory SubstrateAddressIndex.fromPath(
      {required String substratePath, required SubstrateCoins currencyCoin}) {
    return SubstrateAddressIndex(
        currencyCoin: currencyCoin,
        keyName: null,
        substratePath: substratePath);
  }

  @override
  AddressDerivationIndex asImportedKey(String importKeyId) {
    return SubstrateAddressIndex._(
        currencyCoin: currencyCoin,
        importedKeyId: importKeyId,
        keyName: keyName,
        substratePath: substratePath);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          CborStringValue(currencyCoin.proposal.specName),
          CborStringValue(currencyCoin.coinName),
          hdPath ?? const CborNullValue(),
          importedKeyId,
          keyName
        ]),
        CryptoKeyConst.substrateKeyIndex);
  }

  @override
  List get variabels => [currencyCoin.conf.type, importedKeyId, substratePath];

  @override
  String toString() {
    return hdPath ?? "non_derivation";
  }

  @override
  AddressDerivationType get derivationType {
    return AddressDerivationType.substrate;
  }

  @override
  String get name => keyName ?? "main_key";

  @override
  PrivateKeyData derive(PrivateKeyData masterKey,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (substratePath == null) return masterKey;
    final substrate =
        Substrate.fromPrivateKey(masterKey.privateKeyBytes(), currencyCoin);
    final derive = substrate.derivePath(substratePath!);
    return PrivateKeyData(
        coin: masterKey.coin,
        keyName: masterKey.keyName,
        key: derive.priveKey.privKey);
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:on_chain/sui/sui.dart';

class SuiMultisigAccountPublicKeyInfo with CborSerializable, Equatable {
  final List<int> publicKey;
  final int weight;
  final SuiSupportKeyScheme keyScheme;
  final Bip32AddressIndex keyIndex;
  SuiMultisigAccountPublicKeyInfo._(
      {required List<int> publicKey,
      required this.weight,
      required this.keyScheme,
      required this.keyIndex})
      : publicKey = publicKey.asImmutableBytes;
  factory SuiMultisigAccountPublicKeyInfo.create(
      {required List<int> publicKey,
      required int wieght,
      required SuiSupportKeyScheme keyScheme,
      required Bip32AddressIndex keyIndex}) {
    try {
      SuiMultisigPublicKeyInfo(
          publicKey: SuiCryptoPublicKey.fromBytes(
              keyBytes: publicKey, algorithm: keyScheme.suiKeyAlgorithm),
          weight: wieght);
      return SuiMultisigAccountPublicKeyInfo._(
          publicKey: publicKey,
          weight: wieght,
          keyScheme: keyScheme,
          keyIndex: keyIndex);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails_(messsage: e.toString());
    }
  }
  factory SuiMultisigAccountPublicKeyInfo.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.suiMultisigAccountPublicKey);
    return SuiMultisigAccountPublicKeyInfo._(
        publicKey: values.elementAs(0),
        weight: values.elementAs(1),
        keyScheme: SuiSupportKeyScheme.fromValue(values.elementAs(2)),
        keyIndex:
            Bip32AddressIndex.fromCborBytesOrObject(obj: values.getCborTag(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        [CborBytesValue(publicKey), weight, keyScheme.value, keyIndex.toCbor()],
        CborTagsConst.suiMultisigAccountPublicKey);
  }

  String toHex() {
    return BlockchainUtils.toPublicKeyHex(publicKey, keyIndex.currencyCoin);
  }

  @override
  List get variabels => [keyIndex, weight, keyScheme];
}

class SuiMultisigAccountInfo with CborSerializable {
  final List<SuiMultisigAccountPublicKeyInfo> publicKeys;
  final int threshold;
  SuiMultisigAccountInfo._(
      {required List<SuiMultisigAccountPublicKeyInfo> publicKeys,
      required this.threshold})
      : publicKeys = publicKeys.immutable;
  factory SuiMultisigAccountInfo.create(
      {required List<SuiMultisigAccountPublicKeyInfo> publicKeys,
      required int threshold}) {
    try {
      SuiMultisigAccount(
          privateKeys: [],
          publicKey: SuiMultisigAccountPublicKey(
              publicKeys: publicKeys
                  .map((e) => SuiMultisigPublicKeyInfo(
                      publicKey: SuiCryptoPublicKey.fromBytes(
                          keyBytes: e.publicKey,
                          algorithm: e.keyScheme.suiKeyAlgorithm),
                      weight: e.weight))
                  .toList(),
              threshold: threshold));
      return SuiMultisigAccountInfo._(
          publicKeys: publicKeys, threshold: threshold);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails_(messsage: e.toString());
    }
  }
  factory SuiMultisigAccountInfo.deserialize(
      {List<int>? bytes, String? hex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: CborTagsConst.suiMultisigAccountInfo);
    return SuiMultisigAccountInfo._(
        publicKeys: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => SuiMultisigAccountPublicKeyInfo.deserialize(object: e))
            .toList(),
        threshold: values.elementAs(1));
  }

  SuiMultisigAccountPublicKey toSuiMutlisigPublicKey() {
    return SuiMultisigAccountPublicKey(
        publicKeys: publicKeys
            .map((e) => SuiMultisigPublicKeyInfo(
                publicKey: SuiCryptoPublicKey.fromBytes(
                    keyBytes: e.publicKey,
                    algorithm: e.keyScheme.suiKeyAlgorithm),
                weight: e.weight))
            .toList(),
        threshold: threshold);
  }

  SuiBaseSignature createTransactionAuthenticated(
      List<SuiGenericSignature> signatures) {
    int bitmap = 0;
    int weight = 0;
    for (int i = 0; i < publicKeys.length; i++) {
      final publicKey = publicKeys[i];
      bitmap |= 1 << i;
      weight += publicKey.weight;
      if (weight >= threshold) break;
    }
    return SuiMultisigSignature(
        publicKey: toSuiMutlisigPublicKey(),
        signatures: signatures,
        bitmap: bitmap);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborListValue.fixedLength(publicKeys.map((e) => e.toCbor()).toList()),
      threshold
    ], CborTagsConst.suiMultisigAccountInfo);
  }
}

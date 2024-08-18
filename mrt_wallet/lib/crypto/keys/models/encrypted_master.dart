import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'encrypted_imported.dart';

class EncryptedMasterKey with CborSerializable {
  EncryptedMasterKey({
    required this.checksum,
    required List<int> keyBytes,
    required List<EncryptedCustomKey> customKeys,
  })  : masterKey = List<int>.unmodifiable(keyBytes),
        customKeys = List<EncryptedCustomKey>.unmodifiable(customKeys);
  factory EncryptedMasterKey.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.encryptedMasterKey);
    final List<EncryptedCustomKey> customKeys =
        (cbor.elementAt<List<dynamic>>(2))
            .map((e) => EncryptedCustomKey.fromCborBytesOrObject(obj: e))
            .toList();
    return EncryptedMasterKey(
      checksum: cbor.elementAt(0),
      keyBytes: cbor.elementAt(1),
      customKeys: customKeys,
    );
  }

  final String checksum;
  final List<int> masterKey;
  final List<EncryptedCustomKey> customKeys;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(checksum),
          CborBytesValue(masterKey),
          CborListValue.fixedLength(customKeys.map((e) => e.toCbor()).toList()),
        ]),
        CryptoKeyConst.encryptedMasterKey);
  }
}

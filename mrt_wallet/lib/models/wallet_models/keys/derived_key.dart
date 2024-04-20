import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class DerivedKey with CborSerializable {
  final String extendedKey;
  final String id;
  DerivedKey({required this.extendedKey, required this.id});
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([extendedKey, id]),
        WalletModelCborTagsConst.derivedKeys);
  }

  factory DerivedKey.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.derivedKeys);
      final String extendedKey = cbor.elementAt(0);
      final String id = cbor.elementAt(1);

      return DerivedKey(extendedKey: extendedKey, id: id);
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }

  @override
  String toString() {
    return "DerivedKey{id: $id, extended_key: ${extendedKey.substring(0, 5)}...}";
  }
}

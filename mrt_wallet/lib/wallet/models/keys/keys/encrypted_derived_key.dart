import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class EncryptedDerivedKey with CborSerializable {
  final String id;
  EncryptedDerivedKey({required this.id});
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([id]), CborTagsConst.derivedKeys);
  }

  factory EncryptedDerivedKey.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.derivedKeys);
      final String id = cbor.elementAt(0);

      return EncryptedDerivedKey(id: id);
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }
}

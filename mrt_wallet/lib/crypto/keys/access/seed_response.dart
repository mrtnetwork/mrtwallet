import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'key_data.dart';

class AccessMnemonicResponse implements CryptoKeyData {
  final Mnemonic mnemonic;
  const AccessMnemonicResponse(this.mnemonic);

  factory AccessMnemonicResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessMnemonicResponse);
    return AccessMnemonicResponse(Mnemonic.fromString(cbor.elementAt(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([mnemonic.toStr()]),
        CryptoKeyConst.accessMnemonicResponse);
  }

  @override
  String get keyName => "mnemonic";
}

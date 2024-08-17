import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/extention_wallet.dart';

class ExtentionKey with CborSerializable {
  final String key;
  final String nonce;
  List<int> get keyBytes => BytesUtils.fromHexString(key);
  List<int> get nonceBytes => BytesUtils.fromHexString(nonce);
  ExtentionKey({required List<int> key, required List<int> nonce})
      : key = BytesUtils.toHexString(key),
        nonce = BytesUtils.toHexString(nonce);
  ExtentionKey.fromHex(this.key, this.nonce);
  factory ExtentionKey.generate() {
    return ExtentionKey(
        key: QuickCrypto.generateRandom(),
        nonce: QuickCrypto.generateRandom(12));
  }
  factory ExtentionKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: ExtentionSessionStorageConst.keyTag);
    return ExtentionKey.fromHex(values.elementAt(0), values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([key, nonce]),
        ExtentionSessionStorageConst.keyTag);
  }
}

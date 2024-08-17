import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/extention_wallet.dart';

class ExtentionWalletKey with CborSerializable {
  final String key;
  const ExtentionWalletKey(this.key);

  factory ExtentionWalletKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: ExtentionSessionStorageConst.historyTag);
    return ExtentionWalletKey(values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.dynamicLength([key]),
        ExtentionSessionStorageConst.historyTag);
  }
}

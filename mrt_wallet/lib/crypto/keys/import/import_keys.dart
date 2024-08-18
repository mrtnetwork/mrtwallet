import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';

class ImportCustomKeys with CborSerializable {
  final String privateKey;
  final String publicKey;
  final CryptoCoins coin;
  const ImportCustomKeys(
      {required this.privateKey, required this.publicKey, required this.coin});
  ImportCustomKeys.fromBytes(
      {required List<int> privateKey,
      required List<int> publicKey,
      required this.coin})
      : privateKey = BytesUtils.toHexString(privateKey),
        publicKey = BytesUtils.toHexString(publicKey);
  factory ImportCustomKeys.deserialize({List<int>? bytes, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoKeyConst.importCustomKeys);
    return ImportCustomKeys(
        privateKey: values.elementAt(0),
        publicKey: values.elementAt(1),
        coin: CustomCoins.getSerializationCoin(values.elementAt(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([privateKey, publicKey, coin.toCbor()]),
        CryptoKeyConst.importCustomKeys);
  }
}

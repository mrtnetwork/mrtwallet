import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/utils/utils.dart';

class ImportCustomKeys {
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
}

import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/keys/access/key_response.dart';

class AccessPubliKeyResponse implements AccessKeyResponse {
  final String extendedKey;
  final String comprossed;
  final String? uncomprossed;
  final String keyName;
  const AccessPubliKeyResponse._(
      this.extendedKey, this.comprossed, this.uncomprossed, this.keyName);
  factory AccessPubliKeyResponse.fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    final comperesed = BytesUtils.toHexString(account.publicKey.compressed);
    final uncompresed = BytesUtils.toHexString(account.publicKey.uncompressed);
    return AccessPubliKeyResponse._(account.publicKey.toExtended, comperesed,
        uncompresed == comperesed ? null : uncompresed, keyName);
  }
}

import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/bip/wif/wif.dart';
import 'package:mrt_wallet/models/wallet_models/keys/access_key_response/access_key_response.dart';

class AccessPrivateKeyResponse implements AccessKeyResponse {
  final Bip32Base account;
  final CryptoCoins coin;
  final String privateKey;
  final String extendedKey;
  final String? wif;
  final String keyName;
  const AccessPrivateKeyResponse._(this.account, this.privateKey,
      this.extendedKey, this.coin, this.wif, this.keyName);
  factory AccessPrivateKeyResponse.fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    final wifKey = coin.conf.wifNetVer != null
        ? WifEncoder.encode(account.privateKey.raw,
            netVer: coin.conf.wifNetVer!)
        : null;
    return AccessPrivateKeyResponse._(account, account.privateKey.toHex(),
        account.privateKey.toExtended, coin, wifKey, keyName);
  }
}

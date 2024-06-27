import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/keys/import/key_types.dart';
import 'package:mrt_wallet/wallet/utils/ripple/ripple.dart';

class EncryptedCustomKey with Equatable {
  final String publicKey;
  final String id;
  final CryptoCoins coin;
  final DateTime created;
  final String? name;
  final CustomKeyType keyType;
  const EncryptedCustomKey(
      {required this.publicKey,
      required this.coin,
      required this.id,
      required this.created,
      required this.name,
      required this.keyType});

  @override
  List get variabels => [publicKey, id, coin, keyType.name];

  String networkPubKey(WalletNetwork network) {
    if (network is WalletXRPNetwork) {
      return RippleUtils.toRipplePublicKey(publicKey);
    }
    return publicKey;
  }
}

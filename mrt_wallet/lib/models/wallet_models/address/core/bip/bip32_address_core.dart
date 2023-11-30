import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class Bip32AddressCore implements CryptoAddress {
  abstract final List<int> publicKey;
}

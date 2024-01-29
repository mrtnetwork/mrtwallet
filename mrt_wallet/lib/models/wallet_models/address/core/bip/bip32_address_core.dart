import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class Bip32AddressCore<T, X>
    implements CryptoAccountAddress<BigInt, T, X> {
  abstract final List<int> publicKey;
}

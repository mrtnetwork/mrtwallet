import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class Bip32AddressCore<N, T, X>
    implements CryptoAccountAddress<N, T, X> {
  abstract final List<int> publicKey;
}

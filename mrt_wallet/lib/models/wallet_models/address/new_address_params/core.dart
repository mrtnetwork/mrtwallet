import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class NewAccountParams<T extends NewAccountParams<T>> {
  const NewAccountParams();
  abstract final CryptoCoins coin;
  abstract final AddressDerivationIndex deriveIndex;
  bool get isMultiSig;

  Bip32AddressCore toAccount(AppNetworkImpl network, List<int> publicKey);
}

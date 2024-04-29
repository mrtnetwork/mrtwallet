import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class NewAccountParams<T extends NewAccountParams<T>> {
  NewAccountParams();

  CryptoCoins get coin => deriveIndex.currencyCoin;
  abstract final AddressDerivationIndex deriveIndex;

  bool get isMultiSig;
}

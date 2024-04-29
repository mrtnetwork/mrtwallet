import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SolanaNewAddressParam implements NewAccountParams<SolanaNewAddressParam> {
  SolanaNewAddressParam({required this.deriveIndex});
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;
}

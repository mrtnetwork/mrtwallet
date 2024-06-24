import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SolanaNewAddressParam implements NewAccountParams<SolanaNewAddressParam> {
  SolanaNewAddressParam({required this.deriveIndex, required this.coin});
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;

  @override
  Bip32AddressCore toAccount(AppNetworkImpl network, List<int> publicKey) {
    return ISolanaAddress.newAccount(
      accountParams: this,
      publicKey: publicKey,
      network: network as APPSolanaNetwork,
    );
  }
}

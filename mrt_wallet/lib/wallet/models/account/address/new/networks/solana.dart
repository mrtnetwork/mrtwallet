import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class SolanaNewAddressParam implements NewAccountParams {
  SolanaNewAddressParam({required this.deriveIndex, required this.coin});
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;

  @override
  ISolanaAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ISolanaAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletSolanaNetwork);
  }
}

import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/ethereum/ethereum.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class EthereumNewAddressParam implements NewAccountParams {
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  const EthereumNewAddressParam({
    required this.deriveIndex,
    required this.coin,
    List<int>? publicKey,
  });

  @override
  IEthAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IEthAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletEthereumNetwork);
  }
}

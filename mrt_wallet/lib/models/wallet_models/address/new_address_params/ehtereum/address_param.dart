import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class EthereumNewAddressParam
    implements NewAccountParams<EthereumNewAddressParam> {
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
  Bip32AddressCore toAccount(AppNetworkImpl network, List<int> publicKey) {
    return IEthAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as APPEVMNetwork);
  }
}

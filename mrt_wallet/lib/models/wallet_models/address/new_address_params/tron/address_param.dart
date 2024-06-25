import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/on_chain.dart';

class TronNewAddressParam implements NewAccountParams<SolanaNewAddressParam> {
  TronNewAddressParam({required this.deriveIndex, required this.coin});

  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;

  @override
  ITronAddress toAccount(AppNetworkImpl network, List<int> publicKey) {
    return ITronAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as APPTVMNetwork);
  }
}

class TronMultisigNewAddressParam implements TronNewAddressParam {
  const TronMultisigNewAddressParam(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin,
      this.deriveIndex = const MultiSigAddressIndex()});
  @override
  bool get isMultiSig => true;

  final TronAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex;

  final TronMultiSignatureAddress multiSigAccount;
  @override
  final CryptoCoins coin;

  @override
  ITronMultisigAddress toAccount(AppNetworkImpl network, List<int> publicKey) {
    return ITronMultisigAddress.newAccount(
        accountParams: this, network: network as APPTVMNetwork);
  }
}

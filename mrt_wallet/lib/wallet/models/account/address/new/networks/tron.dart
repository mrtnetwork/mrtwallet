import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/tron/addresses/multisig.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/tron/addresses/tron.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:on_chain/on_chain.dart';

class TronNewAddressParam implements NewAccountParams {
  TronNewAddressParam({required this.deriveIndex, required this.coin});

  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;

  @override
  ITronAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ITronAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletTronNetwork);
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
  ITronMultisigAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ITronMultisigAddress.newAccount(
        accountParams: this, network: network as WalletTronNetwork);
  }
}

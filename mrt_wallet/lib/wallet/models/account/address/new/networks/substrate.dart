import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wroker/utils/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateNewAddressParams implements NewAccountParams {
  @override
  bool get isMultiSig => false;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  @override
  final AddressDerivationIndex deriveIndex;

  const SubstrateNewAddressParams({required this.deriveIndex});

  SubstrateAddress toAddress(
      {required List<int> publicKey, required int ss58Format}) {
    return SubstrateUtils.toAddress(
        publicKey: publicKey,
        ss58Format: ss58Format,
        curve: deriveIndex.currencyCoin.conf.type);
  }

  @override
  ISubstrateAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ISubstrateAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletPolkadotNetwork);
  }
}

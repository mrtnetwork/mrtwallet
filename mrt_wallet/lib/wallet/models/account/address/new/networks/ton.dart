import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:mrt_wallet/wroker/utils/ton/ton.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:ton_dart/ton_dart.dart';

class TonNewAddressParam implements NewAccountParams {
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;
  final WalletVersion version;
  final int? subWalletId;
  @override
  final AddressDerivationIndex deriveIndex;

  final bool bouncable;

  const TonNewAddressParam(
      {required this.deriveIndex,
      required this.version,
      required this.bouncable,
      required this.coin,
      this.subWalletId});

  TonAddress toAddress({required List<int> publicKey, required int workChain}) {
    final wallet = TonUtils.fromVersion(
        publicKey: publicKey,
        workChain: workChain,
        version: version,
        subWalletId: subWalletId,
        bouncable: bouncable);
    return wallet.address;
  }

  @override
  ITonAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ITonAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletTonNetwork);
  }
}

import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ton/ton_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/ton/ton_address.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/new_address_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:ton_dart/ton_dart.dart';

class TonNewAddressParam implements NewAccountParams<TonNewAddressParam> {
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
  ITonAddress toAccount(AppNetworkImpl network, List<int> publicKey) {
    return ITonAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as APPTonNetwork);
  }
}

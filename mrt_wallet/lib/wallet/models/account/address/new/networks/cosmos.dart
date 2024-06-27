import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class CosmosNewAddressParams implements NewAccountParams {
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex deriveIndex;

  const CosmosNewAddressParams({
    required this.deriveIndex,
    required this.coin,
  });

  CosmosBaseAddress toAddress(
      {required List<int> publicKey, required String hrp}) {
    if (deriveIndex.currencyCoin.conf.type == EllipticCurveTypes.nist256p1) {
      return CosmosBaseAddress.fromBytes(
          CosmosAddrUtils.secp256r1PubKeyToAddress(publicKey),
          hrp: hrp);
    }
    return CosmosBaseAddress.fromBytes(
        CosmosAddrUtils.secp256k1PubKeyToAddress(publicKey),
        hrp: hrp);
  }

  @override
  ICosmosAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ICosmosAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletCosmosNetwork);
  }
}

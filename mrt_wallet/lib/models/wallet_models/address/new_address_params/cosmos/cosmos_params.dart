import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/new_address_params.dart';

class CosmosNewAddressParams implements NewAccountParams {
  const CosmosNewAddressParams({required this.coin, required this.deriveIndex});
  CosmosNewAddressParams copyWith(
      {CryptoCoins? coin, AddressDerivationIndex? deriveIndex}) {
    return CosmosNewAddressParams(
        coin: coin ?? this.coin, deriveIndex: deriveIndex ?? this.deriveIndex);
  }

  @override
  final CryptoCoins coin;
  @override
  final AddressDerivationIndex deriveIndex;

  CosmosBaseAddress toAddress(
      {required List<int> publicKey, required String hrp}) {
    if (coin.conf.type == EllipticCurveTypes.nist256p1) {
      return CosmosBaseAddress.fromBytes(
          CosmosAddrUtils.secp256r1PubKeyToAddress(publicKey),
          hrp: hrp);
    }
    return CosmosBaseAddress.fromBytes(
        CosmosAddrUtils.secp256k1PubKeyToAddress(publicKey),
        hrp: hrp);
  }

  @override
  bool get isMultiSig => false;
}

import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/new_address_params.dart';
import 'package:mrt_wallet/models/wallet_models/keys/master_key.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/cardano_address_details.dart';
import 'package:on_chain/on_chain.dart';

class CardanoNewAddressParams implements NewAccountParams {
  const CardanoNewAddressParams(
      {required this.coin,
      required this.addressType,
      required this.deriveIndex,
      this.addressDetails,
      this.byronLegacy});
  CardanoNewAddressParams copyWith(
      {CryptoCoins? coin,
      ADAAddressType? addressType,
      AddressDerivationIndex? deriveIndex,
      CardanoAddrDetails? addressDetails,
      SeedGenerationType? seedGeneration}) {
    return CardanoNewAddressParams(
        coin: coin ?? this.coin,
        addressType: addressType ?? this.addressType,
        deriveIndex: deriveIndex ?? this.deriveIndex,
        addressDetails: addressDetails ?? this.addressDetails);
  }

  @override
  final CryptoCoins coin;
  final ADAAddressType addressType;
  @override
  final AddressDerivationIndex deriveIndex;
  final bool? byronLegacy;
  final CardanoAddrDetails? addressDetails;
  ADAAddress toAddress() {
    return addressDetails!.toAddress(coin);
  }

  bool get needStakeKey => addressType == ADAAddressType.base;

  @override
  bool get isMultiSig => false;
}

import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/new_address_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/address_details.dart';
import 'package:on_chain/on_chain.dart';

class CardanoNewAddressParams
    implements NewAccountParams<CardanoNewAddressParams> {
  final ADAAddressType addressType;
  @override
  final AddressDerivationIndex deriveIndex;
  final AddressDerivationIndex? rewardKeyIndex;
  final CardanoAddrDetails? addressDetails;
  final String? customHdPath;
  final List<int>? customHdPathKey;

  bool get needStakeKey => addressType == ADAAddressType.base;
  @override
  bool get isMultiSig => false;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  CardanoNewAddressParams(
      {required this.addressType,
      required this.deriveIndex,
      required this.rewardKeyIndex,
      this.addressDetails,
      this.customHdPath,
      List<int>? customHdPathKey})
      : customHdPathKey =
            BytesUtils.tryToBytes(customHdPathKey, unmodifiable: true);

  ADAAddress toAddress() {
    return addressDetails!.toAddress(deriveIndex.currencyCoin);
  }

  CardanoNewAddressParams copyWith({
    ADAAddressType? addressType,
    AddressDerivationIndex? deriveIndex,
    CardanoAddrDetails? addressDetails,
    AddressDerivationIndex? rewardKeyIndex,
    List<int>? publicKey,
    String? customHdPath,
    List<int>? customHdPathKey,
  }) {
    return CardanoNewAddressParams(
        addressType: addressType ?? this.addressType,
        deriveIndex: deriveIndex ?? this.deriveIndex,
        addressDetails: addressDetails ?? this.addressDetails,
        rewardKeyIndex: rewardKeyIndex ?? this.rewardKeyIndex,
        customHdPath: customHdPath,
        customHdPathKey: customHdPathKey);
  }
}

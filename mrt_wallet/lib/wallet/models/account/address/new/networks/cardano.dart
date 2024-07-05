import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/cardano/cardano.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/address_details.dart';
import 'package:on_chain/on_chain.dart';

class CardanoNewAddressParams implements NewAccountParams {
  final ADAAddressType addressType;
  @override
  final AddressDerivationIndex deriveIndex;
  final Bip32AddressIndex? rewardKeyIndex;
  final CardanoAddrDetails? addressDetails;
  final String? customHdPath;
  final List<int>? customHdPathKey;

  bool get needStakeKey => addressType == ADAAddressType.base;
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;

  CardanoNewAddressParams(
      {required this.addressType,
      required this.deriveIndex,
      required this.rewardKeyIndex,
      required this.coin,
      this.addressDetails,
      this.customHdPath,
      List<int>? customHdPathKey})
      : customHdPathKey =
            BytesUtils.tryToBytes(customHdPathKey, unmodifiable: true);

  ADAAddress toAddress() {
    return addressDetails!.toAddress(deriveIndex.currencyCoin);
  }

  CardanoNewAddressParams copyWith(
      {ADAAddressType? addressType,
      AddressDerivationIndex? deriveIndex,
      CardanoAddrDetails? addressDetails,
      Bip32AddressIndex? rewardKeyIndex,
      List<int>? publicKey,
      String? customHdPath,
      List<int>? customHdPathKey,
      CryptoCoins? coin}) {
    return CardanoNewAddressParams(
        addressType: addressType ?? this.addressType,
        deriveIndex: deriveIndex ?? this.deriveIndex,
        addressDetails: addressDetails ?? this.addressDetails,
        rewardKeyIndex: rewardKeyIndex ?? this.rewardKeyIndex,
        customHdPath: customHdPath,
        customHdPathKey: customHdPathKey,
        coin: coin ?? this.coin);
  }

  @override
  ICardanoAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ICardanoAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletCardanoNetwork);
  }
}

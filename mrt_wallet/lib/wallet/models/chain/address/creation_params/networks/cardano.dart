import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cardano/cardano.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/address_details.dart';
import 'package:on_chain/on_chain.dart';

class CardanoNewAddressParams implements NewAccountParams<ADAAddress> {
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

  factory CardanoNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.cardanoNewAddressParams.tag);
    return CardanoNewAddressParams(
        addressType: ADAAddressType.fromHeader(values.elementAt(0)),
        deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(1)),
        rewardKeyIndex: values.getCborTag(2)?.to<Bip32AddressIndex, CborObject>(
            (e) => Bip32AddressIndex.fromCborBytesOrObject(obj: e)),
        addressDetails: values
            .getCborTag(3)
            ?.to((e) => CardanoAddrDetails.fromCborBytesOrObject(obj: e)),
        customHdPath: values.elementAt(4),
        customHdPathKey: values.elementAt(5),
        coin: CustomCoins.getSerializationCoin(values.elementAt(6)));
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

  ADAAddress toAddress(WalletCardanoNetwork network) {
    return addressDetails!
        .toAddress(deriveIndex.currencyCoin, !network.coinParam.mainnet);
  }

  @override
  ICardanoAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ICardanoAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletCardanoNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          addressType.header,
          deriveIndex.toCbor(),
          rewardKeyIndex?.toCbor(),
          addressDetails?.toCbor(),
          customHdPath,
          customHdPathKey == null
              ? const CborNullValue()
              : CborBytesValue(customHdPathKey!),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.cardanoNewAddressParams;
}

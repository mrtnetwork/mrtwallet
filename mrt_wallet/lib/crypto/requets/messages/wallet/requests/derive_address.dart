import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/cardano.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/address_details.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_public_key.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/derive_address_response.dart';

class WalletRequestDeriveAddress<NETWORKADDRESS>
    implements
        WalletRequest<CryptoDeriveAddressResponse<NETWORKADDRESS>,
            MessageArgsTwoBytes> {
  final NewAccountParams<NETWORKADDRESS> addressParams;
  WalletRequestDeriveAddress({required this.addressParams});

  factory WalletRequestDeriveAddress.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.deriveAddress.tag);
    final addrParams =
        NewAccountParams.deserialize(object: values.getCborTag(0));
    if (addrParams is! NewAccountParams<NETWORKADDRESS>) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return WalletRequestDeriveAddress(addressParams: addrParams);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([addressParams.toCbor()]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.deriveAddress;

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      _deriveCardanoAddress<NETWORKADDRESS>(
          CardanoNewAddressParams params, WalletMasterKeys wallet) {
    final bool byronLegacy = params.coin.proposal == CustomProposal.cip0019;
    AccessCryptoPrivateKeyRequest keyRequest = AccessCryptoPrivateKeyRequest(
        index: params.deriveIndex as Bip32AddressIndex,
        maxLevel: (byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex)
            .value);
    final bip = wallet.readPublicKeys([keyRequest]).first;
    final CardanoAddrDetails addrDetails;
    switch (params.addressType) {
      case ADAAddressType.base:
        keyRequest = AccessCryptoPrivateKeyRequest(
          index: params.rewardKeyIndex!,
        );
        final stake = wallet.readPublicKeys([keyRequest]).first;
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.keyBytes(),
            stakePubkey: stake.keyBytes(),
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.enterprise:
      case ADAAddressType.reward:
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.keyBytes(),
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.byron:
        if (byronLegacy) {
          final adaPubKey = (bip as AdaLegacyPublicKeyData);
          addrDetails = CardanoAddrDetails.byron(
              publicKey: bip.keyBytes(),
              chainCode: adaPubKey.chainCodeBytes(),
              seedGeneration: params.deriveIndex.seedGeneration,
              hdPathKey: params.customHdPathKey ?? adaPubKey.hdPathKeyBytes(),
              hdPath: params.customHdPath ?? params.deriveIndex.hdPath);
          break;
        }

        addrDetails = CardanoAddrDetails.byron(
            publicKey: bip.keyBytes(),
            chainCode: bip.chainCodeBytes()!,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      default:
        throw UnimplementedError();
    }
    return CryptoDeriveAddressResponse(
        accountParams: params.copyWith(addressDetails: addrDetails)
            as NewAccountParams<NETWORKADDRESS>,
        publicKey: addrDetails.publicKey);
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      _deriveAddress<NETWORKADDRESS>(
          NewAccountParams<NETWORKADDRESS> addressParams,
          WalletMasterKeys wallet) {
    final keyRequest =
        AccessCryptoPrivateKeyRequest(index: addressParams.deriveIndex);
    final pubKey = wallet.readPublicKeys([keyRequest]).first;
    return CryptoDeriveAddressResponse(
        accountParams: addressParams, publicKey: pubKey.keyBytes());
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      deriveAddress<NETWORKADDRESS>(
          NewAccountParams<NETWORKADDRESS> addressParams,
          WalletMasterKeys wallet) {
    if (addressParams.type == NewAccountParamsType.cardanoNewAddressParams) {
      return _deriveCardanoAddress(
          addressParams as CardanoNewAddressParams, wallet);
    }
    return _deriveAddress(addressParams, wallet);
  }

  @override
  MessageArgsTwoBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final deriveAddr = deriveAddress(addressParams, wallet);
    return MessageArgsTwoBytes(
        keyOne: deriveAddr.accountParams.toCbor().encode(),
        keyTwo: deriveAddr.publicKey);
  }

  @override
  CryptoDeriveAddressResponse<NETWORKADDRESS> parsResult(
      MessageArgsTwoBytes result) {
    return CryptoDeriveAddressResponse(
        accountParams: NewAccountParams.deserialize(bytes: result.keyOne),
        publicKey: result.keyTwo);
  }

  @override
  CryptoDeriveAddressResponse<NETWORKADDRESS> result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return deriveAddress<NETWORKADDRESS>(addressParams, wallet);
  }
}

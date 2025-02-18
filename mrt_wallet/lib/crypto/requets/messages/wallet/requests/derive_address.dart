import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/aptos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/cardano.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/monero.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/sui.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/address_details.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/derive_address_response.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/models/account_related.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';
import 'package:on_chain/sui/src/address/address/address.dart';

class WalletRequestDeriveAddress<NETWORKADDRESS> extends WalletRequest<
    CryptoDeriveAddressResponse<NETWORKADDRESS>, MessageArgsTwoBytes> {
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
      _deriveMoneroAddress<NETWORKADDRESS>(
          MoneroNewAddressParams addressParams, WalletMasterKeys wallet) {
    final keyRequest =
        AccessCryptoPrivateKeyRequest(index: addressParams.deriveIndex);
    final pubKey =
        wallet.readPublicKeys([keyRequest]).first.cast<MoneroPublicKeyData>();
    final addrDetails = MoneroViewAccountDetails(
        viewKey: MoneroViewPrimaryAccountDetails(
            viewPrivateKey: pubKey.viewPrivateKey,
            spendPublicKey: pubKey.spendPublicKey,
            network: addressParams.network),
        major: addressParams.major,
        minor: addressParams.minor);
    return CryptoDeriveAddressResponse(
        accountParams: addressParams.copyWith(addrDetails: addrDetails)
            as NewAccountParams<NETWORKADDRESS>,

        /// pubKey.spendPublicKey.compressed
        publicKey: pubKey);
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      _deriveCardanoAddress<NETWORKADDRESS>(
          CardanoNewAddressParams params, WalletMasterKeys wallet) {
    final bool byronLegacy = params.coin.proposal == CustomProposal.cip0019;
    AccessCryptoPrivateKeyRequest keyRequest = AccessCryptoPrivateKeyRequest(
        index: params.deriveIndex.cast(),
        maxLevel: (byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex)
            .value);
    final bip = wallet.readPublicKeys([keyRequest]).first;
    final CardanoAddrDetails addrDetails;
    switch (params.addressType) {
      case ADAAddressType.base:
        keyRequest =
            AccessCryptoPrivateKeyRequest(index: params.rewardKeyIndex!);
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
        publicKey: bip);
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      _deriveAptosAddress<NETWORKADDRESS>(
          AptosNewAddressParams addressParams, WalletMasterKeys wallet) {
    if (addressParams.coin.conf.type != addressParams.keyScheme.curve) {
      throw WalletExceptionConst.invalidData(
          messsage: "Invalid aptos address derivation coin.");
    }
    final keyRequest =
        AccessCryptoPrivateKeyRequest(index: addressParams.deriveIndex);
    final publicKey = wallet.readPublicKeys([keyRequest]).first;
    String address;
    switch (addressParams.coin) {
      case Bip44Coins.aptos:
        address = AptosAddrEncoder().encodeKey(publicKey.keyBytes());
        break;
      case Bip44Coins.aptosEd25519SingleKey:
      case Bip44Coins.aptosSecp256k1SingleKey:
        final key = IPublicKey.fromBytes(
            publicKey.keyBytes(), addressParams.coin.conf.type);
        address = AptosAddrEncoder().encodeSingleKey(key);
      default:
        throw WalletExceptionConst.invalidData(
            messsage: "Invalid aptos address derivation coin.");
    }
    addressParams = addressParams.updateAddress(AptosAddress(address));
    return CryptoDeriveAddressResponse(
        accountParams: addressParams as NewAccountParams<NETWORKADDRESS>,
        publicKey: publicKey);
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      _deriveSuiAddress<NETWORKADDRESS>(
          SuiNewAddressParams addressParams, WalletMasterKeys wallet) {
    final keyRequest =
        AccessCryptoPrivateKeyRequest(index: addressParams.deriveIndex);
    final publicKey = wallet.readPublicKeys([keyRequest]).first;
    String address;
    switch (addressParams.coin.conf.type) {
      case EllipticCurveTypes.ed25519:
        address = SuiAddrEncoder().encodeKey(publicKey.keyBytes());
        break;
      case EllipticCurveTypes.secp256k1:
        address = SuiSecp256k1AddrEncoder().encodeKey(publicKey.keyBytes());
        break;
      case EllipticCurveTypes.nist256p1Hybrid:
        address = SuiSecp256r1AddrEncoder().encodeKey(publicKey.keyBytes());
        break;
      default:
        throw WalletExceptionConst.invalidData(
            messsage: "Invalid sui key algorithm.");
    }
    addressParams = addressParams.updateAddress(SuiAddress(address));
    return CryptoDeriveAddressResponse(
        accountParams: addressParams as NewAccountParams<NETWORKADDRESS>,
        publicKey: publicKey);
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      _deriveAddress<NETWORKADDRESS>(
          NewAccountParams<NETWORKADDRESS> addressParams,
          WalletMasterKeys wallet) {
    final keyRequest =
        AccessCryptoPrivateKeyRequest(index: addressParams.deriveIndex);
    final pubKey = wallet.readPublicKeys([keyRequest]).first;
    return CryptoDeriveAddressResponse(
        accountParams: addressParams, publicKey: pubKey);
  }

  static CryptoDeriveAddressResponse<NETWORKADDRESS>
      deriveAddress<NETWORKADDRESS>(
          NewAccountParams<NETWORKADDRESS> addressParams,
          WalletMasterKeys wallet) {
    switch (addressParams.type) {
      case NewAccountParamsType.cardanoNewAddressParams:
        return _deriveCardanoAddress(
            addressParams as CardanoNewAddressParams, wallet);
      case NewAccountParamsType.moneroNewAddressParams:
        return _deriveMoneroAddress(
            addressParams as MoneroNewAddressParams, wallet);
      case NewAccountParamsType.aptosNewAddressParams:
        return _deriveAptosAddress(
            addressParams as AptosNewAddressParams, wallet);
      case NewAccountParamsType.suiNewAddressParams:
        return _deriveSuiAddress(addressParams as SuiNewAddressParams, wallet);
      default:
        return _deriveAddress(addressParams, wallet);
    }
  }

  @override
  MessageArgsTwoBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final deriveAddr = deriveAddress(addressParams, wallet);
    return MessageArgsTwoBytes(
        keyOne: deriveAddr.accountParams.toCbor().encode(),
        keyTwo: deriveAddr.publicKey.toCbor().encode());
  }

  @override
  CryptoDeriveAddressResponse<NETWORKADDRESS> parsResult(
      MessageArgsTwoBytes result) {
    return CryptoDeriveAddressResponse(
        accountParams: NewAccountParams.deserialize(bytes: result.keyOne),
        publicKey:
            CryptoPublicKeyData.fromCborBytesOrObject(bytes: result.keyTwo));
  }

  @override
  CryptoDeriveAddressResponse<NETWORKADDRESS> result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return deriveAddress<NETWORKADDRESS>(addressParams, wallet);
  }
}

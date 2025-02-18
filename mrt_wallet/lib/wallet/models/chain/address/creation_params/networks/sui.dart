import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/sui/sui/multisig.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/sui/sui/sui.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/sui/models/types.dart';
import 'package:on_chain/sui/sui.dart';

class SuiNewAddressParams implements NewAccountParams<SuiAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  final SuiAddress? address;
  final SuiSupportKeyScheme keyScheme;
  SuiNewAddressParams(
      {required this.deriveIndex,
      required this.coin,
      this.address,
      required this.keyScheme});

  SuiNewAddressParams updateAddress(SuiAddress address) {
    assert(this.address == null, "Address must be null.");
    return SuiNewAddressParams(
        deriveIndex: deriveIndex,
        coin: coin,
        address: address,
        keyScheme: keyScheme);
  }

  factory SuiNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.suiNewAddressParams.tag);
    return SuiNewAddressParams(
        deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        coin: CustomCoins.getSerializationCoin(values.elementAs(1)),
        address: values.elemetMybeAs<SuiAddress, CborStringValue>(
            2, (e) => SuiAddress(e.value)),
        keyScheme: SuiSupportKeyScheme.fromValue(values.elementAs(3)));
  }

  @override
  ISuiAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (address == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return ISuiAddress.newAccount(
        accountParams: this,
        network: network.toNetwork(),
        address: address!,
        publicKey: publicKey.keyBytes());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          deriveIndex.toCbor(),
          coin.toCbor(),
          address?.address,
          keyScheme.value
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.suiNewAddressParams;
}

class SuiMultiSigNewAddressParams implements SuiNewAddressParams {
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;
  final SuiMultisigAccountInfo multiSignatureAddress;
  @override
  final SuiAddress address;

  SuiMultiSigNewAddressParams({
    required this.multiSignatureAddress,
    required this.coin,
    required this.address,
  }) : deriveIndex = const MultiSigAddressIndex();

  factory SuiMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.suiMultisigNewAddressParams.tag);
    return SuiMultiSigNewAddressParams(
        coin: CustomCoins.getSerializationCoin(values.elementAt(0)),
        multiSignatureAddress:
            SuiMultisigAccountInfo.deserialize(object: values.elementAs(1)),
        address: SuiAddress(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.address,
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.suiMultisigNewAddressParams;

  @override
  SuiSupportKeyScheme get keyScheme => SuiSupportKeyScheme.multisig;

  @override
  SuiNewAddressParams updateAddress(SuiAddress address) {
    return SuiMultiSigNewAddressParams(
        multiSignatureAddress: multiSignatureAddress,
        coin: coin,
        address: address);
  }

  @override
  ISuiAddress toAccount(WalletNetwork<NetworkCoinParams<APIProvider>> network,
      CryptoPublicKeyData? publicKey) {
    return ISuiMultiSigAddress.newAccount(
        network: network.toNetwork(), accountParam: this);
  }
}

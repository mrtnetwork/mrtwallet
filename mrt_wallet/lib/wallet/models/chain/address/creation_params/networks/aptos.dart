import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/aptos/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/aptos/aptos/multisig.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/aptos/models/types.dart';
import 'package:on_chain/aptos/src/address/address.dart';

class AptosNewAddressParams implements NewAccountParams<AptosAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  final AptosSupportKeyScheme keyScheme;
  final AptosAddress? address;
  AptosNewAddressParams(
      {required this.deriveIndex,
      required this.coin,
      this.address,
      required this.keyScheme});

  AptosNewAddressParams updateAddress(AptosAddress address) {
    assert(this.address == null, "Address must be null.");
    return AptosNewAddressParams(
        deriveIndex: deriveIndex,
        coin: coin,
        address: address,
        keyScheme: keyScheme);
  }

  factory AptosNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.aptosNewAddressParams.tag);
    return AptosNewAddressParams(
        deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        coin: CustomCoins.getSerializationCoin(values.elementAs(1)),
        address: values.elemetMybeAs<AptosAddress, CborStringValue>(
            2, (e) => AptosAddress(e.value)),
        keyScheme: AptosSupportKeyScheme.fromValue(values.elementAs(3)));
  }

  @override
  IAptosAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (address == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return IAptosAddress.newAccount(
        accountParams: this,
        address: address!,
        network: network.toNetwork(),
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
  NewAccountParamsType get type => NewAccountParamsType.aptosNewAddressParams;
}

class AptosMultiSigNewAddressParams implements AptosNewAddressParams {
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;
  final AptosMultisigAccountInfo multiSignatureAddress;
  @override
  final AptosAddress address;

  AptosMultiSigNewAddressParams({
    required this.multiSignatureAddress,
    required this.coin,
    required this.address,
  }) : deriveIndex = const MultiSigAddressIndex();

  factory AptosMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.aptosMultisigNewAddressParams.tag);
    return AptosMultiSigNewAddressParams(
        coin: CustomCoins.getSerializationCoin(values.elementAt(0)),
        multiSignatureAddress:
            AptosMultisigAccountInfo.deserialize(object: values.elementAs(1)),
        address: AptosAddress(values.elementAs(2)));
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
      NewAccountParamsType.aptosMultisigNewAddressParams;

  @override
  AptosSupportKeyScheme get keyScheme => multiSignatureAddress.keyScheme;

  @override
  AptosNewAddressParams updateAddress(AptosAddress address) {
    throw UnimplementedError();
  }

  @override
  IAptosAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    return IAptosMultiSigAddress.newAccount(
        network: network.toNetwork(), accountParam: this);
  }
}

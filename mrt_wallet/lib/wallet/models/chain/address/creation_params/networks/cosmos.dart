import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class CosmosNewAddressParams implements NewAccountParams<CosmosBaseAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex deriveIndex;

  final CosmosKeysAlgs algorithm;

  const CosmosNewAddressParams(
      {required this.deriveIndex, required this.coin, required this.algorithm});
  factory CosmosNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.cosmosNewAddressParams.tag);
    return CosmosNewAddressParams(
        deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        coin: CustomCoins.getSerializationCoin(values.elementAt(1)),
        algorithm: CosmosKeysAlgs.fromName(values.elementAs(2)));
  }

  CosmosBaseAddress toAddress(
      {required List<int> publicKey, required String hrp}) {
    return CosmosBaseAddress.fromPublicKey(
        pubkeyBytes: publicKey, algorithm: algorithm, hrp: hrp);
  }

  CosmosPublicKey toPublicKey(List<int> publicKey) {
    return CosmosPublicKey.fromBytes(keyBytes: publicKey, algorithm: algorithm);
  }

  @override
  ICosmosAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    return ICosmosAddress.newAccount(
        accountParams: this,
        publicKey: publicKey.keyBytes(),
        network: network.toNetwork());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [deriveIndex.toCbor(), coin.toCbor(), algorithm.name]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.cosmosNewAddressParams;
}

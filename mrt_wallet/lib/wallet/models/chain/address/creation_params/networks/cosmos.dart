import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
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

  const CosmosNewAddressParams({required this.deriveIndex, required this.coin});
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
    );
  }

  CosmosBaseAddress toAddress(
      {required List<int> publicKey, required String hrp}) {
    if (deriveIndex.currencyCoin.conf.type == EllipticCurveTypes.nist256p1) {
      return CosmosBaseAddress.fromBytes(
          CosmosAddrUtils.secp256r1PubKeyToAddress(publicKey),
          hrp: hrp);
    }
    return CosmosBaseAddress.fromBytes(
        CosmosAddrUtils.secp256k1PubKeyToAddress(publicKey),
        hrp: hrp);
  }

  @override
  ICosmosAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return ICosmosAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletCosmosNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.cosmosNewAddressParams;
}

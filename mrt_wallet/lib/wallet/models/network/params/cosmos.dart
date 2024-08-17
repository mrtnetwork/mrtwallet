import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CosmosNetworkParams extends NetworkCoinParams<CosmosAPIProvider> {
  final String hrp;

  final List<CosmosNativeCoin> nativeCoins;

  final CosmosNativeCoin mainCoin;

  final CosmosNetworkTypes networkType;

  factory CosmosNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosNetworkParams);

    return CosmosNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => CosmosAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4),
        hrp: cbor.elementAt(5),
        coins: (cbor.elementAt(6) as List)
            .map((e) => CosmosNativeCoin.fromCborBytesOrObject(obj: e))
            .toList(),
        mainCoin:
            CosmosNativeCoin.fromCborBytesOrObject(obj: cbor.getCborTag(7)),
        networkType: CosmosNetworkTypes.fromValue(cbor.elementAt(8)),
        bip32CoinType: cbor.elementAt(9));
  }
  CosmosNetworkParams({
    required super.transactionExplorer,
    required super.addressExplorer,
    required super.token,
    required super.providers,
    required super.mainnet,
    required this.hrp,
    required List<CosmosNativeCoin> coins,
    required this.mainCoin,
    required this.networkType,
    super.bip32CoinType,
  }) : nativeCoins = List<CosmosNativeCoin>.unmodifiable(coins);

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          mainnet,
          CborStringValue(hrp),
          nativeCoins.map((e) => e.toCbor()).toList(),
          mainCoin.toCbor(),
          networkType.value,
          bip32CoinType
        ]),
        CborTagsConst.cosmosNetworkParams);
  }

  @override
  NetworkCoinParams<CosmosAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return CosmosNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<CosmosAPIProvider>(),
        mainnet: mainnet,
        hrp: hrp,
        coins: nativeCoins,
        mainCoin: mainCoin,
        networkType: networkType);
  }
}

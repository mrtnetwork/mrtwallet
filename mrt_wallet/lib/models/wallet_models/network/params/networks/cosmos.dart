import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/custom.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/api/networks/cosmos/api_provider/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class CosmosNetworkParams extends NetworkCoinParams<CosmosAPIProviderService> {
  final String hrp;

  final List<CosmosNativeCoin> nativeCoins;

  final CosmosNativeCoin mainCoin;

  final CosmosNetworkTypes networkType;

  factory CosmosNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cosmosNetworkParams);

    return CosmosNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => CosmosAPIProviderService.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4),
        hrp: cbor.elementAt(5),
        coins: (cbor.elementAt(6) as List)
            .map((e) => CosmosNativeCoin.fromCborBytesOrObject(obj: e))
            .toList(),
        mainCoin:
            CosmosNativeCoin.fromCborBytesOrObject(obj: cbor.getCborTag(7)),
        networkType: CosmosNetworkTypes.fromValue(cbor.elementAt(8)));
  }
  CosmosNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.mainnet,
      required this.hrp,
      required List<CosmosNativeCoin> coins,
      required this.mainCoin,
      required this.networkType})
      : nativeCoins = List<CosmosNativeCoin>.unmodifiable(coins);

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
          networkType.value
        ]),
        WalletModelCborTagsConst.cosmosNetworkParams);
  }

  @override
  NetworkCoinParams<ApiProviderService> updateProviders(
      List<CosmosAPIProviderService> updateProviders) {
    return CosmosNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders,
        mainnet: mainnet,
        hrp: hrp,
        coins: nativeCoins,
        mainCoin: mainCoin,
        networkType: networkType);
  }
}

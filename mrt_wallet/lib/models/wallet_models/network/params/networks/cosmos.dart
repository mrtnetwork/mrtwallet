import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/app/app_image.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/custom.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/networks/cosmos/api_provider/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class CosmosNetworkParams with CborSerializable implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
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
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required this.providers,
      required this.mainnet,
      required this.hrp,
      required List<CosmosNativeCoin> coins,
      required this.mainCoin,
      required this.networkType})
      : nativeCoins = List<CosmosNativeCoin>.unmodifiable(coins);

  @override
  final bool mainnet;

  @override
  final String? transactionExplorer;

  @override
  final String? addressExplorer;

  @override
  int get decimal => token.decimal!;

  @override
  AppImage get logo => token.assetLogo!;

  @override
  final Token token;

  final String hrp;

  final List<CosmosNativeCoin> nativeCoins;

  final CosmosNativeCoin mainCoin;

  final CosmosNetworkTypes networkType;

  @override
  String? getAccountExplorer(String address) {
    return addressExplorer?.replaceAll(_addrArgs, address);
  }

  @override
  String? getTransactionExplorer(String txId) {
    return transactionExplorer?.replaceAll(_txIdArgs, txId);
  }

  @override
  final List<CosmosAPIProviderService> providers;

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
}

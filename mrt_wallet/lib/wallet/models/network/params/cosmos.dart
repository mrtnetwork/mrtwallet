import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';

import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

class CosmosNetworkParams extends NetworkCoinParams<CosmosAPIProvider> {
  final String hrp;
  final String denom;
  final CosmosNetworkTypes networkType;
  final String chainId;
  final String? networkConstantUri;
  final List<CosmosKeysAlgs> keysAlgs;
  final List<CosmosFeeToken> feeTokens;
  final bool useNativeTokenAsFee;

  List<Bip44Coins> coins() {
    return keysAlgs.map((e) => e.coin(chainType)).toList();
  }

  CosmosFeeToken? findFeeToken(String denom) {
    return feeTokens.firstWhereOrNull((e) => e.denom == denom);
  }

  CosmosNetworkParams._({
    super.transactionExplorer,
    super.addressExplorer,
    required super.token,
    required super.providers,
    required super.chainType,
    required this.hrp,
    required this.denom,
    required this.feeTokens,
    required this.networkType,
    required this.chainId,
    required this.keysAlgs,
    required this.useNativeTokenAsFee,
    this.networkConstantUri,
    super.bip32CoinType,
  });
  factory CosmosNetworkParams(
      {String? transactionExplorer,
      String? addressExplorer,
      required Token token,
      required List<CosmosAPIProvider> providers,
      required ChainType chainType,
      required String hrp,
      required String denom,
      required List<CosmosFeeToken> feeTokens,
      required CosmosNetworkTypes networkType,
      required String chainId,
      required List<CosmosKeysAlgs> keysAlgs,
      String? networkConstantUri,
      int? bip32CoinType}) {
    if (feeTokens.isEmpty) {
      throw WalletException("at_least_one_fee_token_required");
    }
    if (token.decimal == null ||
        token.decimal!.isNegative ||
        token.decimal! > CosmosConst.maxTokenExponent) {
      throw WalletException("invalid_token_exponent");
    }
    bool useNativeTokenAsFee = false;
    if (feeTokens.length == 1) {
      useNativeTokenAsFee = denom == feeTokens[0].denom;
    }
    return CosmosNetworkParams._(
      token: token,
      providers: providers,
      chainType: chainType,
      hrp: hrp,
      denom: denom,
      feeTokens: feeTokens,
      networkType: networkType,
      chainId: chainId,
      keysAlgs: keysAlgs,
      bip32CoinType: bip32CoinType,
      useNativeTokenAsFee: useNativeTokenAsFee,
      addressExplorer: addressExplorer,
      networkConstantUri: networkConstantUri,
      transactionExplorer: transactionExplorer,
    );
  }

  factory CosmosNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosNetworkParams);

    return CosmosNetworkParams(
      token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
      providers: values
          .elementAsListOf<CborTagValue>(3)
          .map((e) => CosmosAPIProvider.fromCborBytesOrObject(obj: e))
          .toList(),
      chainType: ChainType.fromValue(values.elementAs(4)),
      hrp: values.elementAs(5),
      denom: values.elementAs(6),
      feeTokens: values
          .elementAsListOf<CborTagValue>(7)
          .map((e) => CosmosFeeToken.fromCborBytesOrObject(obj: e))
          .toList(),
      networkType: CosmosNetworkTypes.fromValue(values.elementAs(8)),
      bip32CoinType: values.elementAs(9),
      chainId: values.elementAs(10),
      networkConstantUri: values.elementAs(11),
      keysAlgs: values
          .elementAsListOf<CborStringValue>(12)
          .map((e) => CosmosKeysAlgs.fromName(e.value))
          .toList(),
      transactionExplorer: values.elementAs(13),
      addressExplorer: values.elementAs(14),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          hrp,
          denom,
          CborListValue.fixedLength(feeTokens.map((e) => e.toCbor()).toList()),
          networkType.value,
          bip32CoinType,
          chainId,
          networkConstantUri,
          CborListValue.fixedLength(
              keysAlgs.map((e) => CborStringValue(e.name)).toList()),
          transactionExplorer,
          addressExplorer,
        ]),
        CborTagsConst.cosmosNetworkParams);
  }

  CosmosNetworkParams copyWith(
      {List<CosmosAPIProvider>? providers,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      ChainType? chainType,
      String? hrp,
      String? denom,
      CosmosNetworkTypes? networkType,
      List<CosmosFeeToken>? feeTokens,
      String? chainId,
      int? bip32CoinType,
      String? networkConstantUri,
      List<CosmosKeysAlgs>? keysAlgs}) {
    return CosmosNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        chainType: chainType ?? this.chainType,
        hrp: hrp ?? this.hrp,
        denom: denom ?? this.denom,
        networkType: networkType ?? this.networkType,
        chainId: chainId ?? this.chainId,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType,
        networkConstantUri: networkConstantUri ?? this.networkConstantUri,
        keysAlgs: keysAlgs ?? this.keysAlgs,
        feeTokens: feeTokens ?? this.feeTokens);
  }

  String get identifier => chainId;

  @override
  NetworkCoinParams<CosmosAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return CosmosNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<CosmosAPIProvider>() ?? providers,
        chainType: chainType,
        hrp: hrp,
        feeTokens: feeTokens,
        denom: denom,
        networkType: networkType,
        chainId: chainId,
        bip32CoinType: bip32CoinType,
        networkConstantUri: networkConstantUri,
        keysAlgs: keysAlgs);
  }
}

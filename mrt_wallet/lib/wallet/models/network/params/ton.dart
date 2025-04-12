import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart' as ton;

class TonNetworkParams extends NetworkCoinParams<TonAPIProvider> {
  final int workchain;
  ton.TonChain get chain => ton.TonChain.fromWorkchain(workchain);
  String get tonChainIdentifier {
    switch (chain) {
      case ton.TonChain.testnet:
        return "ton:testnet";
      case ton.TonChain.mainnet:
        return "ton:mainnet";
      default:
        throw UnimplementedError("Invalid ton network.");
    }
  }

  TonNetworkParams(
      {required super.token,
      required super.providers,
      required this.workchain,
      required super.chainType,
      super.addressExplorer,
      super.transactionExplorer});

  factory TonNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.tonNetworkParam);
    return TonNetworkParams(
        workchain: values.elementAs(0),
        chainType: ChainType.fromValue(values.elementAs(1)),
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(4)),
        providers: values
            .elementAsListOf<CborTagValue>(5)
            .map((e) => TonAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          workchain,
          chainType.name,
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.tonNetworkParam);
  }

  int get identifier => workchain;

  @override
  NetworkCoinParams<TonAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return TonNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<TonAPIProvider>() ?? providers,
        workchain: workchain,
        chainType: chainType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}

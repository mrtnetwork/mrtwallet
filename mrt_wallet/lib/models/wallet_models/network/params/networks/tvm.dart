import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class TVMNetworkParams extends NetworkCoinParams<TronApiProviderService> {
  final List<EVMApiProviderService> ethereumProviders;
  factory TVMNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tvmNetworkParam);

    return TVMNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => TronApiProviderService.fromCborBytesOrObject(obj: e))
            .toList(),
        ethereumProviders: (cbor.elementAt(4) as List)
            .map((e) => EVMApiProviderService.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(5));
  }
  TVMNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required this.ethereumProviders,
      required super.mainnet});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              ethereumProviders.map((e) => e.toCbor()).toList()),
          mainnet
        ]),
        WalletModelCborTagsConst.tvmNetworkParam);
  }

  @override
  NetworkCoinParams<TronApiProviderService> updateProviders(
      List<TronApiProviderService> updateProviders) {
    return TVMNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders,
        ethereumProviders: ethereumProviders,
        mainnet: mainnet);
  }
}

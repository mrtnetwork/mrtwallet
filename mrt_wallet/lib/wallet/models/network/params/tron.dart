import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class TronNetworkParams extends NetworkCoinParams<TronAPIProvider> {
  final List<EthereumAPIProvider> ethereumProviders;
  final String genesis;
  @override
  String get identifier => genesis;
  factory TronNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tvmNetworkParam);

    return TronNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => TronAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        ethereumProviders: (cbor.elementAt(4) as List)
            .map((e) => EthereumAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(cbor.elementAt(5)),
        genesis: cbor.elementAt(6));
  }
  TronNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required this.ethereumProviders,
      required super.chainType,
      required this.genesis});

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
          chainType.name,
          genesis
        ]),
        CborTagsConst.tvmNetworkParam);
  }

  @override
  NetworkCoinParams<TronAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return TronNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<TronAPIProvider>(),
        ethereumProviders: ethereumProviders,
        chainType: chainType,
        genesis: genesis);
  }
}

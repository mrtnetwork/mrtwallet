import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class MoneroNetworkParams extends NetworkCoinParams<MoneroAPIProvider> {
  final MoneroNetwork network;
  final int rctHeight;

  factory MoneroNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.moneroNetworkParams);

    return MoneroNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborObject>(3)
            .map((e) => MoneroAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        network: MoneroNetwork.fromName(values.elementAs(5)),
        rctHeight: values.elementAs(7),
        addressExplorer: values.elementAs(8),
        transactionExplorer: values.elementAs(9));
  }
  MoneroNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.network,
      required this.rctHeight,
      super.addressExplorer,
      super.transactionExplorer});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          network.name,
          const CborNullValue(),
          rctHeight,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.moneroNetworkParams);
  }

  @override
  NetworkCoinParams<MoneroAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer}) {
    return MoneroNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<MoneroAPIProvider>() ?? providers,
        chainType: chainType,
        network: network,
        rctHeight: rctHeight,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}

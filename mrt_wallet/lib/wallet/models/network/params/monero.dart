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
  final String gnesisHash;
  final int rctHeight;

  factory MoneroNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.moneroNetworkParams);

    return MoneroNetworkParams(
        transactionExplorer: values.elementAs(0),
        addressExplorer: values.elementAs(1),
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborObject>(3)
            .map((e) => MoneroAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        network: MoneroNetwork.fromName(values.elementAs(5)),
        gnesisHash: String.fromCharCodes(values.elementAt<List<int>>(6)),
        rctHeight: values.elementAs(7));
  }
  MoneroNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.chainType,
      required this.network,
      required this.gnesisHash,
      required this.rctHeight});

  MoneroNetworkParams copyWith(
      {ChainType? chainType,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<MoneroAPIProvider>? providers,
      MoneroNetwork? network,
      String? gnesisHash,
      int? rctHeight}) {
    return MoneroNetworkParams(
        chainType: chainType ?? this.chainType,
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        network: network ?? this.network,
        gnesisHash: gnesisHash ?? this.gnesisHash,
        rctHeight: rctHeight ?? this.rctHeight);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          network.name,
          CborBytesValue(gnesisHash.codeUnits),
          rctHeight,
        ]),
        CborTagsConst.moneroNetworkParams);
  }

  @override
  NetworkCoinParams<MoneroAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return MoneroNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<MoneroAPIProvider>(),
        chainType: chainType,
        network: network,
        gnesisHash: gnesisHash,
        rctHeight: rctHeight);
  }

  @override
  String get identifier => gnesisHash;
}

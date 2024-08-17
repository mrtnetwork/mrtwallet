import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class SolanaNetworkParams extends NetworkCoinParams<SolanaAPIProvider> {
  final String genesis;

  factory SolanaNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.solNetworkParam);

    return SolanaNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => SolanaAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4),
        genesis: cbor.elementAt(5));
  }
  SolanaNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.mainnet,
      required this.genesis});

  SolanaNetworkParams copyWith(
      {bool? mainnet,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<SolanaAPIProvider>? providers,
      String? genesis}) {
    return SolanaNetworkParams(
        mainnet: mainnet ?? this.mainnet,
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        genesis: genesis ?? this.genesis);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          mainnet,
          genesis
        ]),
        CborTagsConst.solNetworkParam);
  }

  @override
  NetworkCoinParams<SolanaAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return SolanaNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<SolanaAPIProvider>(),
        mainnet: mainnet,
        genesis: genesis);
  }
}

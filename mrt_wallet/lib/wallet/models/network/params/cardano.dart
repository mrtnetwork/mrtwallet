import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CardanoNetworkParams extends NetworkCoinParams<CardanoAPIProvider> {
  factory CardanoNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cardanoNetworkParams);

    return CardanoNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => CardanoAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4));
  }
  CardanoNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.mainnet});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          mainnet
        ]),
        CborTagsConst.cardanoNetworkParams);
  }

  @override
  CardanoNetworkParams updateProviders(List<APIProvider> updateProviders) {
    return CardanoNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<CardanoAPIProvider>(),
        mainnet: mainnet);
  }
}

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

class CardanoNetworkParams extends NetworkCoinParams<CardanoAPIProvider> {
  final int magic;
  factory CardanoNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cardanoNetworkParams);

    return CardanoNetworkParams(
        transactionExplorer: values.elementAs(0),
        addressExplorer: values.elementAs(1),
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => CardanoAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        magic: values.elementAs(5));
  }
  CardanoNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.chainType,
      required this.magic});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          magic
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
        chainType: chainType,
        magic: magic);
  }

  @override
  int get identifier => magic;
}

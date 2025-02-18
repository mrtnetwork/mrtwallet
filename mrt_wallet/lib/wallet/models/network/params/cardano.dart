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
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => CardanoAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        magic: values.elementAs(5),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  CardanoNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.magic,
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
          magic,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.cardanoNetworkParams);
  }

  int get identifier => magic;

  @override
  NetworkCoinParams<CardanoAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return CardanoNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<CardanoAPIProvider>() ?? providers,
        chainType: chainType,
        magic: magic,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}

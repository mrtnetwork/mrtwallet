import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class RippleNetworkParams extends NetworkCoinParams<RippleAPIProvider> {
  static const String _xrpSymbol = "XRP";

  factory RippleNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.xrpNetworkParam);
    final token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    return RippleNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => RippleAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt<bool?>(4) ?? token.symbol == _xrpSymbol);
  }
  RippleNetworkParams(
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
        CborTagsConst.xrpNetworkParam);
  }

  @override
  NetworkCoinParams<RippleAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return RippleNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<RippleAPIProvider>(),
        mainnet: mainnet);
  }
}

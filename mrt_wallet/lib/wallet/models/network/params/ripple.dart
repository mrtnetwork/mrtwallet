import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class RippleNetworkParams extends NetworkCoinParams<RippleAPIProvider> {
  final int networkId;

  factory RippleNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.xrpNetworkParam);
    return RippleNetworkParams(
        transactionExplorer: cbor.elementAs(0),
        addressExplorer: cbor.elementAs(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: cbor
            .elementAsListOf<CborTagValue>(3)
            .map((e) => RippleAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(cbor.elementAs(4)),
        networkId: cbor.elementAs(5));
  }
  RippleNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.chainType,
      required this.networkId});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          networkId
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
        chainType: chainType,
        networkId: networkId);
  }

  @override
  int get identifier => networkId;
}

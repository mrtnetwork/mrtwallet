import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class SubstrateNetworkParams extends NetworkCoinParams<SubstrateAPIProvider> {
  final int ss58Format;
  final int specVersion;

  factory SubstrateNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.substrateNetworkParams);

    return SubstrateNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => SubstrateAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4),
        ss58Format: cbor.elementAt(5),
        specVersion: cbor.elementAt(6));
  }
  SubstrateNetworkParams({
    required super.transactionExplorer,
    required super.addressExplorer,
    required super.token,
    required super.providers,
    required super.mainnet,
    required this.ss58Format,
    required this.specVersion,
  });

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          mainnet,
          ss58Format,
          specVersion
        ]),
        CborTagsConst.substrateNetworkParams);
  }

  @override
  NetworkCoinParams<SubstrateAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return SubstrateNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<SubstrateAPIProvider>(),
        mainnet: mainnet,
        ss58Format: ss58Format,
        specVersion: specVersion);
  }
}

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

class SubstrateNetworkParams extends NetworkCoinParams<SubstrateAPIProvider> {
  final int ss58Format;
  final String gnesis;
  final SubstrateExtrinsicType extrinsicType;

  factory SubstrateNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.substrateNetworkParams);

    return SubstrateNetworkParams(
        transactionExplorer: values.elementAs(0),
        addressExplorer: values.elementAs(1),
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => SubstrateAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        ss58Format: values.elementAs(5),
        gnesis: values.elementAs(6),
        extrinsicType: SubstrateExtrinsicType.fromName(values.elementAs(7)));
  }
  SubstrateNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.chainType,
      required this.ss58Format,
      required this.gnesis,
      required this.extrinsicType});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          ss58Format,
          gnesis,
          extrinsicType.name
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
        chainType: chainType,
        ss58Format: ss58Format,
        gnesis: gnesis,
        extrinsicType: extrinsicType);
  }

  @override
  String get identifier => gnesis;
}

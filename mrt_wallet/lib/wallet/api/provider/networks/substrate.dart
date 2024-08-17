import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class SubstrateAPIProvider extends APIProvider {
  const SubstrateAPIProvider._(
      {required super.serviceName,
      required super.websiteUri,
      required super.protocol,
      required super.auth,
      required super.identifier,
      required this.uri,
      required this.nodeUri});
  factory SubstrateAPIProvider(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      required String identifier,
      String? nodeUri,
      ProviderAuth? auth}) {
    return SubstrateAPIProvider._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        nodeUri: nodeUri,
        auth: auth,
        identifier: identifier);
  }
  final String uri;
  final String? nodeUri;
  @override
  String get callUrl => uri;

  factory SubstrateAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.substrateApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    return SubstrateAPIProvider._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        nodeUri: cbor.elementAt(4),
        auth: cbor.getCborTag(5)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)),
        identifier: APIUtils.getProviderIdentifier(cbor.elementAt(6)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          serviceName,
          websiteUri,
          uri,
          protocol.id,
          nodeUri ?? const CborNullValue(),
          auth?.toCbor(),
          identifier
        ]),
        CborTagsConst.substrateApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];
}

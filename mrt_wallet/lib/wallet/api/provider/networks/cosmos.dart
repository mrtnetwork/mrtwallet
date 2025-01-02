import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class CosmosAPIProvider extends APIProvider {
  const CosmosAPIProvider._(
      {required super.protocol,
      required this.uri,
      required super.auth,
      required super.identifier});
  factory CosmosAPIProvider(
      {required String uri,
      required String identifier,
      ProviderAuthenticated? auth}) {
    return CosmosAPIProvider._(
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        auth: auth,
        identifier: identifier);
  }
  final String uri;
  @override
  String get callUrl => uri;

  factory CosmosAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosApiServiceProvider);
    final int? protocolId = values.elementAs(1);
    return CosmosAPIProvider._(
        uri: values.elementAs(0),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            2, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [uri, protocol.id, auth?.toCbor(), identifier]),
        CborTagsConst.cosmosApiServiceProvider);
  }

  @override
  List get variabels => [uri, protocol, auth];
}

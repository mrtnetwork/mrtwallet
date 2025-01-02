import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class TonAPIProvider extends APIProvider {
  const TonAPIProvider._({
    required super.protocol,
    required super.auth,
    required super.identifier,
    required this.uri,
    required this.apiType,
  });
  factory TonAPIProvider({
    required String serviceName,
    required String websiteUri,
    required String uri,
    required TonApiType apiType,
    required String identifier,
    ProviderAuthenticated? auth,
  }) {
    return TonAPIProvider._(
        protocol: ServiceProtocol.fromURI(uri),
        apiType: apiType,
        uri: uri,
        auth: auth,
        identifier: identifier);
  }
  final TonApiType apiType;
  final String uri;
  @override
  String get callUrl => uri;

  factory TonAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tonApiServiceProvider);
    final int? protocolId = values.elementAs(1);
    final TonApiType apiType =
        TonApiType.fromValue(values.elementAs<String>(2));
    return TonAPIProvider._(
        uri: values.elementAs(0),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        apiType: apiType,
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            3, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [uri, protocol.id, apiType.name, auth?.toCbor(), identifier]),
        CborTagsConst.tonApiServiceProvider);
  }

  @override
  List get variabels => [uri, protocol, apiType];
}

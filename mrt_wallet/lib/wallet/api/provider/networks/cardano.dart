import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CardanoAPIProvider extends APIProvider {
  const CardanoAPIProvider._(
      {required super.protocol,
      required this.uri,
      required super.auth,
      required super.identifier});
  factory CardanoAPIProvider(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      ProviderAuthenticated? auth,
      required String identifier}) {
    return CardanoAPIProvider._(
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        auth: auth,
        identifier: identifier);
  }
  final String uri;
  @override
  String get callUrl => uri;

  factory CardanoAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cardanoApiServiceProvider);
    final int? protocolId = values.elementAs(1);
    return CardanoAPIProvider._(
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
        CborTagsConst.cardanoApiServiceProvider);
  }

  @override
  List get variabels => [uri, protocol, auth];
}

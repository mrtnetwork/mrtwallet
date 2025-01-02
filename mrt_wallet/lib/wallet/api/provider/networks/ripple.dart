import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class RippleAPIProvider extends APIProvider {
  const RippleAPIProvider._(
      {required super.protocol,
      required super.auth,
      required super.identifier,
      required this.uri});
  factory RippleAPIProvider(
      {required String uri,
      required String identifier,
      ProviderAuthenticated? auth}) {
    return RippleAPIProvider._(
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        auth: auth,
        identifier: identifier);
  }
  final String uri;
  @override
  String get callUrl => uri;

  factory RippleAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.rippleApiServiceProvider);
    final int? protocolId = values.elementAs(1);
    return RippleAPIProvider._(
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
        CborTagsConst.rippleApiServiceProvider);
  }
}

import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'provider.dart';

class ElectrumAPIProvider extends BaseBitcoinAPIProvider {
  const ElectrumAPIProvider._(
      {required super.protocol,
      required super.auth,
      required super.identifier,
      required this.url});
  final String url;

  @override
  String get callUrl => url;

  factory ElectrumAPIProvider(
      {required String url,
      required ServiceProtocol protocol,
      required String identifier,
      ProviderAuthenticated? auth}) {
    return ElectrumAPIProvider._(
        url: url, identifier: identifier, protocol: protocol, auth: auth);
  }

  factory ElectrumAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.electrumApiServiceProvider);
    return ElectrumAPIProvider._(
        url: values.elementAs(0),
        protocol: ServiceProtocol.fromID(values.elementAs(1)),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            2, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [url, protocol.id, auth?.toCbor(), identifier]),
        CborTagsConst.electrumApiServiceProvider);
  }

  @override
  BitcoinAPIProviderType get type => BitcoinAPIProviderType.electrum;
}

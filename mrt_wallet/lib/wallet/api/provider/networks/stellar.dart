import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class StellarAPIProvider extends APIProvider {
  const StellarAPIProvider({
    super.auth,
    required super.identifier,
    required this.horizonUrl,
    required this.sorobanUrl,
  }) : super(protocol: ServiceProtocol.http);
  final String horizonUrl;
  final String sorobanUrl;

  @override
  String get callUrl => horizonUrl;

  factory StellarAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.stellarApiProvider);
    return StellarAPIProvider(
      horizonUrl: values.elementAs(0),
      sorobanUrl: values.elementAs(1),
      auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
          2, (e) => ProviderAuthenticated.deserialize(obj: e)),
      identifier: values.elementAs(3),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          horizonUrl,
          sorobanUrl,
          auth?.toCbor(),
          identifier,
        ]),
        CborTagsConst.stellarApiProvider);
  }

  @override
  List get variabels => [horizonUrl, sorobanUrl, protocol];
}

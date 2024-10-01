import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class StellarAPIProvider extends APIProvider {
  const StellarAPIProvider({
    required super.serviceName,
    required super.websiteUri,
    super.protocol = ServiceProtocol.http,
    super.auth,
    required super.identifier,
    required this.horizonUrl,
    required this.sorobanUrl,
  });
  final String horizonUrl;
  final String sorobanUrl;

  @override
  String get callUrl => horizonUrl;

  factory StellarAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.stellarApiProvider);
    return StellarAPIProvider(
      serviceName: cbor.elementAt(0),
      websiteUri: cbor.elementAt(1),
      horizonUrl: cbor.elementAt(2),
      sorobanUrl: cbor.elementAt(3),
      auth: cbor.getCborTag(4)?.to<ProviderAuth, CborTagValue>(
          (e) => ProviderAuth.fromCborBytesOrObject(obj: e)),
      identifier: APIUtils.getProviderIdentifier(cbor.elementAt(5)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          serviceName,
          websiteUri,
          horizonUrl,
          sorobanUrl,
          auth?.toCbor(),
          identifier,
        ]),
        CborTagsConst.stellarApiProvider);
  }
}

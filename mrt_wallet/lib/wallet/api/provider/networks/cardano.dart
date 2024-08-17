import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CardanoAPIProvider extends APIProvider {
  const CardanoAPIProvider._(
      {required super.serviceName,
      required super.websiteUri,
      required super.protocol,
      required this.uri,
      required super.auth,
      required super.identifier});
  factory CardanoAPIProvider(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      ProviderAuth? auth,
      required String identifier}) {
    return CardanoAPIProvider._(
        serviceName: serviceName,
        websiteUri: websiteUri,
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
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cardanoApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    return CardanoAPIProvider._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        auth: cbor.getCborTag(5)?.to<ProviderAuth, CborTagValue>(
                (e) => ProviderAuth.fromCborBytesOrObject(obj: e)) ??
            ProviderAuth(
                type: ProviderAuthType.header,
                key: "project_id",
                value: cbor.elementAt(4)),
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
          const CborNullValue(),
          auth?.toCbor()
        ]),
        CborTagsConst.cardanoApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];
}

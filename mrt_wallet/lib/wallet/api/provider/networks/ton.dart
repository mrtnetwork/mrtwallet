import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart';

class TonAPIProvider extends APIProvider {
  const TonAPIProvider._({
    required super.serviceName,
    required super.websiteUri,
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
    ProviderAuth? auth,
  }) {
    return TonAPIProvider._(
        serviceName: serviceName,
        websiteUri: websiteUri,
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
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tonApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    final TonApiType apiType = TonApiType.fromValue(cbor.elementAt<String>(4));
    return TonAPIProvider._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        apiType: apiType,
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
          apiType.name,
          auth?.toCbor(),
          identifier
        ]),
        CborTagsConst.tonApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];
}

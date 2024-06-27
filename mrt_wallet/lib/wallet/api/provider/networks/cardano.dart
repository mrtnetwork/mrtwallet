import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CardanoAPIProvider extends APIProvider {
  const CardanoAPIProvider._({
    required String serviceName,
    required String websiteUri,
    required ServiceProtocol protocol,
    required this.uri,
    required ProviderAuth? auth,
  }) : super(serviceName, websiteUri, protocol, auth);
  factory CardanoAPIProvider(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      ProviderAuth? auth}) {
    return CardanoAPIProvider._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        auth: auth);
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
            cbor.elementAt<CborObject?>(4)?.to<ProviderAuth, String>(
                  (e) => ProviderAuth(
                      type: ProviderAuthType.header,
                      key: "project_id",
                      value: e),
                ));
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

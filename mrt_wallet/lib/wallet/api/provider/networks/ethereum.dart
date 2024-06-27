import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class EthereumAPIProvider extends APIProvider {
  const EthereumAPIProvider._(
      {required String serviceName,
      required String websiteUri,
      required ServiceProtocol protocol,
      required ProviderAuth? auth,
      required this.uri})
      : super(serviceName, websiteUri, protocol, auth);
  factory EthereumAPIProvider(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      ProviderAuth? auth}) {
    return EthereumAPIProvider._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ServiceProtocol.fromURI(uri),
        uri: uri,
        auth: auth);
  }
  final String uri;
  @override
  String get callUrl => uri;

  factory EthereumAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.evmApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    return EthereumAPIProvider._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        protocol: ServiceProtocol.fromID(protocolId ?? 0),
        auth: cbor.getCborTag(4)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, uri, protocol.id, auth?.toCbor()]),
        CborTagsConst.evmApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];
}

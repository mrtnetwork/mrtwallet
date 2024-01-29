import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class ElectrumApiProviderService extends ApiProviderService {
  const ElectrumApiProviderService._(
      {required String serviceName,
      required String websiteUri,
      required ProviderProtocol protocol,
      this.websocket,
      this.tcp,
      this.ssl})
      : super(serviceName, websiteUri, protocol);
  final String? websocket;
  final String? tcp;
  final String? ssl;

  @override
  ProviderProtocol get protocol {
    if (websocket != null) {
      return ProviderProtocol.websocket;
    } else if (tcp != null) {
      return ProviderProtocol.tcp;
    }
    return ProviderProtocol.ssl;
  }

  String get endpoint {
    if (websocket != null) {
      return websocket!;
    } else if (tcp != null) {
      return tcp!;
    }
    return ssl!;
  }

  @override
  String get callUrl => endpoint;

  factory ElectrumApiProviderService(
      {required String serviceName,
      required String websiteUri,
      required String url,
      required ProviderProtocol protocol}) {
    switch (protocol) {
      case ProviderProtocol.tcp:
        return ElectrumApiProviderService._(
            serviceName: serviceName,
            websiteUri: websiteUri,
            tcp: url,
            protocol: protocol);
      case ProviderProtocol.ssl:
        return ElectrumApiProviderService._(
            serviceName: serviceName,
            websiteUri: websiteUri,
            ssl: url,
            protocol: protocol);
      default:
        return ElectrumApiProviderService._(
            serviceName: serviceName,
            websiteUri: websiteUri,
            websocket: url,
            protocol: protocol);
    }
  }

  factory ElectrumApiProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.electrumApiServiceProvider);
    final websocket = cbor.getIndex(2);
    final tcp = cbor.getIndex(3);
    final ssl = cbor.getIndex(4);
    ProviderProtocol protocol;
    if (websocket != null) {
      protocol = ProviderProtocol.websocket;
    } else if (tcp != null) {
      protocol = ProviderProtocol.tcp;
    } else {
      protocol = ProviderProtocol.ssl;
    }
    return ElectrumApiProviderService._(
        serviceName: cbor.getIndex(0),
        websiteUri: cbor.getIndex(1),
        websocket: websocket,
        tcp: tcp,
        ssl: ssl,
        protocol: protocol);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, websocket, tcp, ssl]),
        WalletModelCborTagsConst.electrumApiServiceProvider);
  }
}

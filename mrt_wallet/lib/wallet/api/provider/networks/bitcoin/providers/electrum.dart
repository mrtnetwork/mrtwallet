import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';

import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

import 'provider.dart';

class ElectrumAPIProvider extends BaseBitcoinAPIProvider {
  const ElectrumAPIProvider._(
      {required super.serviceName,
      required super.websiteUri,
      required super.protocol,
      required super.auth,
      required super.identifier,
      this.websocket,
      this.tcp,
      this.ssl});
  final String? websocket;
  final String? tcp;
  final String? ssl;

  @override
  ServiceProtocol get protocol {
    if (websocket != null) {
      return ServiceProtocol.websocket;
    } else if (tcp != null) {
      return ServiceProtocol.tcp;
    }
    return ServiceProtocol.ssl;
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

  factory ElectrumAPIProvider({
    required String serviceName,
    required String websiteUri,
    required String url,
    required ServiceProtocol protocol,
    required String identifier,
    ProviderAuth? auth,
  }) {
    switch (protocol) {
      case ServiceProtocol.tcp:
        return ElectrumAPIProvider._(
            serviceName: serviceName,
            websiteUri: websiteUri,
            tcp: url,
            identifier: identifier,
            protocol: protocol,
            auth: auth);
      case ServiceProtocol.ssl:
        return ElectrumAPIProvider._(
            serviceName: serviceName,
            websiteUri: websiteUri,
            ssl: url,
            identifier: identifier,
            protocol: protocol,
            auth: auth);
      default:
        return ElectrumAPIProvider._(
            serviceName: serviceName,
            websiteUri: websiteUri,
            websocket: url,
            protocol: protocol,
            identifier: identifier,
            auth: auth);
    }
  }

  factory ElectrumAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.electrumApiServiceProvider);
    final websocket = cbor.elementAt(2);
    final tcp = cbor.elementAt(3);
    final ssl = cbor.elementAt(4);
    ServiceProtocol protocol;
    if (websocket != null) {
      protocol = ServiceProtocol.websocket;
    } else if (tcp != null) {
      protocol = ServiceProtocol.tcp;
    } else {
      protocol = ServiceProtocol.ssl;
    }
    return ElectrumAPIProvider._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        websocket: websocket,
        tcp: tcp,
        ssl: ssl,
        protocol: protocol,
        auth: cbor.getCborTag(5)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)),
        identifier: APIUtils.getProviderIdentifier(cbor.elementAt(6)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, websocket, tcp, ssl, auth?.toCbor()]),
        CborTagsConst.electrumApiServiceProvider);
  }

  @override
  BitcoinAPIProviderType get type => BitcoinAPIProviderType.electrum;
}

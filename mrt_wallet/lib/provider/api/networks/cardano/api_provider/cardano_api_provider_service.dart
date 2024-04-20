import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class CardanoAPIProviderService extends ApiProviderService {
  const CardanoAPIProviderService._(
      {required String serviceName,
      required String websiteUri,
      required ProviderProtocol protocol,
      required this.uri,
      this.projectId})
      : super(serviceName, websiteUri, protocol);
  factory CardanoAPIProviderService(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      String? projectId}) {
    return CardanoAPIProviderService._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ProviderProtocol.fromURI(uri),
        uri: uri,
        projectId: projectId);
  }
  final String uri;
  final String? projectId;
  @override
  String get callUrl => uri;

  factory CardanoAPIProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cardanoApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    return CardanoAPIProviderService._(
      serviceName: cbor.elementAt(0),
      websiteUri: cbor.elementAt(1),
      uri: cbor.elementAt(2),
      protocol: ProviderProtocol.fromID(protocolId ?? 0),
      projectId: cbor.elementAt(4),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, uri, protocol.id, projectId]),
        WalletModelCborTagsConst.cardanoApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol, projectId];

  @override
  NetworkApiProvider toProvider(AppNetworkImpl network) {
    return ChainUtils.buildCardanoProvider(this, network.toNetwork());
  }
}

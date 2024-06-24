import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/core/core.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class CardanoAPIProviderService extends ApiProviderService {
  const CardanoAPIProviderService._({
    required String serviceName,
    required String websiteUri,
    required ProviderProtocol protocol,
    required this.uri,
    required ProviderAuth? auth,
  }) : super(serviceName, websiteUri, protocol, auth);
  factory CardanoAPIProviderService(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      ProviderAuth? auth}) {
    return CardanoAPIProviderService._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ProviderProtocol.fromURI(uri),
        uri: uri,
        auth: auth);
  }
  final String uri;
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
        WalletModelCborTagsConst.cardanoApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];

  @override
  NetworkApiProvider toProvider(AppNetworkImpl network) {
    return ChainUtils.buildCardanoProvider(this, network.toNetwork());
  }
}

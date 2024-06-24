import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/types.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:ton_dart/ton_dart.dart';

class TonAPIProviderService extends ApiProviderService {
  const TonAPIProviderService._({
    required String serviceName,
    required String websiteUri,
    required ProviderProtocol protocol,
    required ProviderAuth? auth,
    required this.uri,
    required this.apiType,
  }) : super(serviceName, websiteUri, protocol, auth);
  factory TonAPIProviderService({
    required String serviceName,
    required String websiteUri,
    required String uri,
    required TonApiType apiType,
    ProviderAuth? auth,
  }) {
    return TonAPIProviderService._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ProviderProtocol.fromURI(uri),
        apiType: apiType,
        uri: uri,
        auth: auth);
  }
  final TonApiType apiType;
  final String uri;
  @override
  String get callUrl => uri;

  factory TonAPIProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tonApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    final TonApiType apiType = TonApiType.fromValue(cbor.elementAt<String>(4));
    return TonAPIProviderService._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        protocol: ProviderProtocol.fromID(protocolId ?? 0),
        apiType: apiType,
        auth: cbor.getCborTag(5)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)));
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
          auth?.toCbor()
        ]),
        WalletModelCborTagsConst.tonApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];

  @override
  NetworkApiProvider toProvider(AppNetworkImpl network) {
    return ChainUtils.buildTonApiProvider(this, network.toNetwork());
  }
}

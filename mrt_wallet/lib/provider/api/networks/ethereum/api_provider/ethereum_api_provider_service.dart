import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/core/core.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class EVMApiProviderService extends ApiProviderService {
  const EVMApiProviderService._(
      {required String serviceName,
      required String websiteUri,
      required ProviderProtocol protocol,
      required ProviderAuth? auth,
      required this.uri})
      : super(serviceName, websiteUri, protocol, auth);
  factory EVMApiProviderService(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      ProviderAuth? auth}) {
    return EVMApiProviderService._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        protocol: ProviderProtocol.fromURI(uri),
        uri: uri,
        auth: auth);
  }
  final String uri;
  @override
  String get callUrl => uri;

  factory EVMApiProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.evmApiServiceProvider);
    final int? protocolId = cbor.elementAt(3);
    return EVMApiProviderService._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        protocol: ProviderProtocol.fromID(protocolId ?? 0),
        auth: cbor.getCborTag(4)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, uri, protocol.id, auth?.toCbor()]),
        WalletModelCborTagsConst.evmApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];

  @override
  NetworkApiProvider toProvider(AppNetworkImpl network) {
    return ChainUtils.buildEVMProvider(this, network.toNetwork());
  }
}

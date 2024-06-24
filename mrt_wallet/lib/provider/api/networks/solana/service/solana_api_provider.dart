import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class SolanaApiProviderService extends ApiProviderService {
  const SolanaApiProviderService({
    required String serviceName,
    required String websiteUri,
    required this.httpNodeUri,
    ProviderAuth? auth,
  }) : super(serviceName, websiteUri, ProviderProtocol.http, auth);
  final String httpNodeUri;

  @override
  String get callUrl => httpNodeUri;

  factory SolanaApiProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.solApiServiceProvider);
    return SolanaApiProviderService(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        httpNodeUri: cbor.elementAt(2),
        auth: cbor.getCborTag(3)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, httpNodeUri, auth?.toCbor()]),
        WalletModelCborTagsConst.solApiServiceProvider);
  }

  @override
  NetworkApiProvider toProvider(AppNetworkImpl network) {
    return ChainUtils.buildSoalanaProvider(this, network.toNetwork());
  }
}

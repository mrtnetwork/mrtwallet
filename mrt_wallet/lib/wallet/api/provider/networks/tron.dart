import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'ethereum.dart';

class TronAPIProvider extends APIProvider {
  const TronAPIProvider({
    required String serviceName,
    required String websiteUri,
    required this.httpNodeUri,
    required this.solidityProvider,
    ProviderAuth? auth,
  }) : super(serviceName, websiteUri, ServiceProtocol.http, auth);
  final String httpNodeUri;
  final EthereumAPIProvider solidityProvider;

  @override
  String get callUrl => httpNodeUri;

  factory TronAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tronApiServiceProvider);
    return TronAPIProvider(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        httpNodeUri: cbor.elementAt(2),
        auth: cbor.getCborTag(3)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)),
        solidityProvider:
            EthereumAPIProvider.fromCborBytesOrObject(obj: cbor.getCborTag(4)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          serviceName,
          websiteUri,
          httpNodeUri,
          auth?.toCbor(),
          solidityProvider.toCbor()
        ]),
        CborTagsConst.tronApiServiceProvider);
  }
}

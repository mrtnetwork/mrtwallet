import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'ethereum.dart';

class TronAPIProvider extends APIProvider {
  const TronAPIProvider({
    required super.serviceName,
    required super.websiteUri,
    super.protocol = ServiceProtocol.http,
    super.auth,
    required super.identifier,
    required this.httpNodeUri,
    required this.solidityProvider,
  });
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
            EthereumAPIProvider.fromCborBytesOrObject(obj: cbor.getCborTag(4)),
        identifier: APIUtils.getProviderIdentifier(cbor.elementAt(5)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          serviceName,
          websiteUri,
          httpNodeUri,
          auth?.toCbor(),
          solidityProvider.toCbor(),
          identifier
        ]),
        CborTagsConst.tronApiServiceProvider);
  }
}

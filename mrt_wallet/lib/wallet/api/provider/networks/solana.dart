import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class SolanaAPIProvider extends APIProvider {
  const SolanaAPIProvider({
    required super.serviceName,
    required super.websiteUri,
    super.protocol = ServiceProtocol.http,
    super.auth,
    required super.identifier,
    required this.httpNodeUri,
  });
  final String httpNodeUri;

  @override
  String get callUrl => httpNodeUri;

  factory SolanaAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.solApiServiceProvider);
    return SolanaAPIProvider(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        httpNodeUri: cbor.elementAt(2),
        auth: cbor.getCborTag(3)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)),
        identifier: APIUtils.getProviderIdentifier(cbor.elementAt(4)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, httpNodeUri, auth?.toCbor(), identifier]),
        CborTagsConst.solApiServiceProvider);
  }
}

import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class SolanaAPIProvider extends APIProvider {
  const SolanaAPIProvider({
    required String serviceName,
    required String websiteUri,
    required this.httpNodeUri,
    ProviderAuth? auth,
  }) : super(serviceName, websiteUri, ServiceProtocol.http, auth);
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
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, httpNodeUri, auth?.toCbor()]),
        CborTagsConst.solApiServiceProvider);
  }
}

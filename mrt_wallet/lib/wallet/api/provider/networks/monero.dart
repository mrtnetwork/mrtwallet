import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class MoneroAPIProvider extends APIProvider {
  const MoneroAPIProvider(
      {super.auth, required super.identifier, required this.httpNodeUri})
      : super(protocol: ServiceProtocol.http);
  final String httpNodeUri;

  @override
  String get callUrl => httpNodeUri;

  factory MoneroAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroApiServiceProvider);
    return MoneroAPIProvider(
        httpNodeUri: values.elementAs(0),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            1, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([httpNodeUri, auth?.toCbor(), identifier]),
        CborTagsConst.moneroApiServiceProvider);
  }
}

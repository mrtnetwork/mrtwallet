import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'ethereum.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class TronAPIProvider extends APIProvider {
  const TronAPIProvider(
      {super.auth,
      required super.identifier,
      required this.httpNodeUri,
      required this.solidityProvider})
      : super(protocol: ServiceProtocol.http);
  final String httpNodeUri;
  final EthereumAPIProvider solidityProvider;

  @override
  String get callUrl => httpNodeUri;

  factory TronAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tronApiServiceProvider);
    return TronAPIProvider(
        httpNodeUri: cbor.elementAs(0),
        solidityProvider:
            EthereumAPIProvider.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
        auth: cbor.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            2, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: cbor.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          httpNodeUri,
          solidityProvider.toCbor(),
          auth?.toCbor(),
          identifier
        ]),
        CborTagsConst.tronApiServiceProvider);
  }
}

import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

enum AptosAPIProviderType {
  fullnode(0),
  graphQl(1);

  final int value;
  bool get isFullNode => this == fullnode;
  const AptosAPIProviderType(this.value);
  static AptosAPIProviderType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "AptosAPIProviderType not found."));
  }
}

// abstract class AptosAPIProvider extends APIProvider {
//   final AptosAPIProviderType type;
//   const AptosAPIProvider(
//       {required super.protocol,
//       required super.identifier,
//       required super.auth,
//       required this.type});
// }

class AptosAPIProvider extends APIProvider {
  final AptosAPIProviderType type;
  const AptosAPIProvider(
      {super.auth,
      required super.identifier,
      required this.fullNodeUri,
      required this.type})
      : super(protocol: ServiceProtocol.http);
  final String fullNodeUri;
  @override
  String get callUrl => fullNodeUri;

  factory AptosAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.aptosApiServiceProvider);
    return AptosAPIProvider(
        fullNodeUri: values.elementAs(0),
        auth: values.elemetMybeAs<ProviderAuthenticated, CborTagValue>(
            1, (e) => ProviderAuthenticated.deserialize(obj: e)),
        identifier: values.elementAs(2),
        type: AptosAPIProviderType.fromValue(values.elementAs(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [fullNodeUri, auth?.toCbor(), identifier, type.value]),
        CborTagsConst.aptosApiServiceProvider);
  }
}

class AptosProviderIdentifier extends ProviderIdentifier {
  final String fullNodeIdentifier;
  final String graphQlIdentifier;
  const AptosProviderIdentifier(
      {required this.fullNodeIdentifier, required this.graphQlIdentifier})
      : super(network: NetworkType.aptos);
  factory AptosProviderIdentifier.deserialize(
      {List<int>? bytes, String? hex, CborObject? cbor}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: cbor, tags: NetworkType.aptos.tag);
    return AptosProviderIdentifier(
        fullNodeIdentifier: values.elementAs(0),
        graphQlIdentifier: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([fullNodeIdentifier, graphQlIdentifier]),
        network.tag);
  }

  @override
  List get variabels => [fullNodeIdentifier, graphQlIdentifier];
}

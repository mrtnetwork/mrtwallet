import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

enum ProviderAuthType {
  header,
  path,
  query;

  static ProviderAuthType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletExceptionConst.invalidProviderInformation);
  }
}

class ProviderAuth with CborSerializable {
  final ProviderAuthType type;
  final String key;
  final String value;
  const ProviderAuth(
      {required this.type, required this.key, required this.value});

  factory ProviderAuth.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.apiServiceAuthSettings);
    return ProviderAuth(
        type: ProviderAuthType.fromName(cbor.elementAt(0)),
        key: cbor.elementAt(1),
        value: cbor.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([type.name, key, value]),
        WalletModelCborTagsConst.apiServiceAuthSettings);
  }
}

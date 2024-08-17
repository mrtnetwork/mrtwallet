import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

enum ProviderAuthType {
  header,
  query;

  static ProviderAuthType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletExceptionConst.invalidProviderInformation);
  }

  bool get isHeader => this == ProviderAuthType.header;
}

class ProviderAuth with CborSerializable {
  final ProviderAuthType type;
  final String key;
  final String value;
  const ProviderAuth(
      {required this.type, required this.key, required this.value});

  Map<String, String> get auth => {key: value};

  factory ProviderAuth.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.apiServiceAuthSettings);
    return ProviderAuth(
        type: ProviderAuthType.fromName(cbor.elementAt(0)),
        key: cbor.elementAt(1),
        value: cbor.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([type.name, key, value]),
        CborTagsConst.apiServiceAuthSettings);
  }
}

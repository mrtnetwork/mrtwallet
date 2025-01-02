import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/constant/global/serialization.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';

enum ProviderAuthType {
  header(APPSerializationConst.basicProviderAuth),
  query(APPSerializationConst.basicProviderAuth),
  digest(APPSerializationConst.digestProviderAuth);

  final List<int> tag;
  const ProviderAuthType(this.tag);
  static ProviderAuthType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletExceptionConst.invalidProviderInformation);
  }

  static ProviderAuthType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(tag, e.tag),
        orElse: () => throw WalletExceptionConst.invalidProviderInformation);
  }

  bool get isHeader => this == ProviderAuthType.header;
  bool get isDigest => this == ProviderAuthType.digest;
}

abstract class ProviderAuthenticated with CborSerializable, Equatable {
  final ProviderAuthType type;
  const ProviderAuthenticated({required this.type});
  Uri toUri(Uri uri);
  Map<String, String>? toHeaders(Map<String, String>? headers);

  factory ProviderAuthenticated.deserialize(
      {List<int>? bytes, CborObject? obj, String? cborHex}) {
    final CborTagValue values =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: cborHex);
    final type = ProviderAuthType.fromTag(values.tags);
    return switch (type) {
      ProviderAuthType.header ||
      ProviderAuthType.query =>
        BasicProviderAuthenticated.fromCborBytesOrObject(obj: values),
      ProviderAuthType.digest =>
        DigestProviderAuthenticated.fromCborBytesOrObject(obj: values)
    };
  }

  T cast<T extends ProviderAuthenticated>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", "$runtimeType"]);
    }
    return this as T;
  }
}

class BasicProviderAuthenticated extends ProviderAuthenticated {
  final String key;
  final String value;
  const BasicProviderAuthenticated(
      {required super.type, required this.key, required this.value});

  Map<String, String> get auth => {key: value};

  factory BasicProviderAuthenticated.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, ProviderAuthType.header.tag);
    return BasicProviderAuthenticated(
        type: ProviderAuthType.fromName(cbor.elementAt(0)),
        key: cbor.elementAt(1),
        value: cbor.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([type.name, key, value]), type.tag);
  }

  @override
  Uri toUri(Uri uri) {
    if (type != ProviderAuthType.query) {
      return uri;
    }
    return uri.replace(queryParameters: auth);
  }

  @override
  Map<String, String>? toHeaders(Map<String, String>? headers) {
    if (type != ProviderAuthType.header) {
      return headers;
    }
    return {...headers ?? {}, ...auth};
  }

  @override
  List get variabels => [type, key, value];
}

class DigestProviderAuthenticated extends ProviderAuthenticated {
  final String password;
  final String username;

  DigestProviderAuthenticated({
    required this.password,
    required this.username,
  }) : super(type: ProviderAuthType.digest);

  factory DigestProviderAuthenticated.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, ProviderAuthType.digest.tag);
    return DigestProviderAuthenticated(
        password: values.elementAs(0), username: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([password, username]), type.tag);
  }

  @override
  Uri toUri(Uri uri) {
    return uri;
  }

  @override
  Map<String, String>? toHeaders(Map<String, String>? headers) {
    if (type != ProviderAuthType.header) {
      return headers;
    }
    return {};
  }

  @override
  List get variabels => [type, password, username];
}

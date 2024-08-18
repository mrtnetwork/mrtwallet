import 'package:blockchain_utils/cbor/types/cbor_tag.dart';

import 'key_data.dart';

class FakeKeyData implements CryptoKeyData {
  @override
  CborTagValue toCbor() {
    throw UnimplementedError();
  }

  @override
  String get keyName => throw UnimplementedError();
}

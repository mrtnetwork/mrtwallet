import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';

abstract class NFTCore with CborSerializable {
  abstract final String? uri;
}

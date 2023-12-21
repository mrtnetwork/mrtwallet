import 'package:mrt_wallet/models/serializable/serializable.dart';

abstract class NFTCore with CborSerializable {
  abstract final String? uri;
}

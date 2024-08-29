import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CosmosNativeCoin with CborSerializable {
  final int decimal;
  final String denom;
  const CosmosNativeCoin({required this.decimal, required this.denom});
  factory CosmosNativeCoin.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosNativeToken);
    return CosmosNativeCoin(
        decimal: cbor.elementAt(0), denom: cbor.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborIntValue(decimal), CborStringValue(denom)]),
        CborTagsConst.cosmosNativeToken);
  }
}

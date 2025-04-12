import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class Web3AccountAcitvity with CborSerializable, Equatable {
  final String method;
  final DateTime date;
  final String? path;
  final String? address;
  final int? id;
  Web3AccountAcitvity({
    required this.method,
    DateTime? date,
    required this.path,
    this.id,
    this.address,
  }) : date = date ?? DateTime.now();
  factory Web3AccountAcitvity.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.permissionActivityTag);
    return Web3AccountAcitvity(
        method: values.elementAt(0),
        date: values.elementAt(1),
        path: values.elementAt(2),
        address: values.elementAt(3),
        id: values.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method, CborEpochFloatValue(date), path, address, id]),
        CborTagsConst.permissionActivityTag);
  }

  @override
  List get variabels => [method, date, path, address, id];
}

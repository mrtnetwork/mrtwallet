import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
// import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class MoneroCachedBlockHeight {
  final int block;
  final DateTime time;
  MoneroCachedBlockHeight(this.block) : time = DateTime.now();
  bool get needFetch =>
      time.isBefore(DateTime.now().add(MoneroConst.avarageBlockTime));
}

class MoneroRignOutput with CborSerializable {
  final List<BigInt> orderedIndexes;
  final List<BigInt> indexes;
  MoneroRignOutput(
      {required List<BigInt> orderedIndexes, required List<BigInt> indexes})
      : orderedIndexes = orderedIndexes.immutable,
        indexes = indexes.immutable;
  factory MoneroRignOutput.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.monerogenerateRingOutput);
    return MoneroRignOutput(
        orderedIndexes: values
            .elementAsListOf<CborBigIntValue>(0)
            .map((e) => e.value)
            .toList(),
        indexes: values
            .elementAsListOf<CborBigIntValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborListValue.fixedLength(
          orderedIndexes.map((e) => CborBigIntValue(e)).toList()),
      CborListValue.fixedLength(
          indexes.map((e) => CborBigIntValue(e)).toList()),
    ], CborTagsConst.monerogenerateRingOutput);
  }
}

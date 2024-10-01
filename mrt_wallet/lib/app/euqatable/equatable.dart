import 'package:blockchain_utils/utils/compare/compare.dart';

abstract mixin class Equatable {
  List<dynamic> get variabels;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Equatable) {
      return false;
    }
    if (other.runtimeType != runtimeType) return false;
    if (variabels.length != other.variabels.length) {
      return false;
    }
    for (int i = 0; i < variabels.length; i++) {
      final vi = variabels[i];
      final oI = other.variabels[i];
      if (vi is Iterable) {
        if (oI is! Iterable) return false;
        if (vi.length != oI.length) return false;
        if (!CompareUtils.iterableIsEqual(vi, oI)) {
          return false;
        }
      } else if (variabels[i] != other.variabels[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    int result = 0;
    for (var i in variabels) {
      result ^= i.hashCode;
    }
    return result;
  }
}

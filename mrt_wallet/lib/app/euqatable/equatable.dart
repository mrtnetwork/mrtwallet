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
      if (variabels[i] != other.variabels[i]) {
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

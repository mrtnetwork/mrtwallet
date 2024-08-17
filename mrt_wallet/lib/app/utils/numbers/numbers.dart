extension QuickNum on BigInt {
  String get toRadix16 => "0x${toRadixString(16)}";
}

extension QuicIntkNum on int {
  String get toRadix16 => "0x${toRadixString(16)}";
}

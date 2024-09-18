import 'dart:math' as math;

extension QuickDouble on double {
  double max(double other) => math.max(this, other);
}

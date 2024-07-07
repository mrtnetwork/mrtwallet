class Point {
  double x;
  double y;
  Point(this.x, this.y);
}

class QRFinderPattern {
  int stateCount1;
  int stateCount2;
  int stateCount3;
  int stateCount4;
  int stateCount5;
  int stateCount6;

  QRFinderPattern()
      : stateCount1 = 0,
        stateCount2 = 0,
        stateCount3 = 0,
        stateCount4 = 0,
        stateCount5 = 0,
        stateCount6 = 0;

  bool looksLikeFinder() {
    // Implement the logic to check if the pattern looks like a QR finder pattern
    // Placeholder for simplicity
    return stateCount1 == 1 &&
        stateCount2 == 1 &&
        stateCount3 == 3 &&
        stateCount4 == 1 &&
        stateCount5 == 1;
  }

  void slide() {
    // Slide the pattern
    stateCount1 = stateCount2;
    stateCount2 = stateCount3;
    stateCount3 = stateCount4;
    stateCount4 = stateCount5;
    stateCount5 = stateCount6;
    stateCount6 = 0;
  }

  double estModSize() {
    return (stateCount1 +
            stateCount2 +
            stateCount3 +
            stateCount4 +
            stateCount5 +
            stateCount6) /
        7.0;
  }
}

class QRFinderPosition {
  Point location;
  double moduleSize;
  double lastModuleSize;

  QRFinderPosition(this.location, this.moduleSize, this.lastModuleSize);
}

class RefineResult {
  Point location;
  double moduleSize;
  double lastModuleSize;

  RefineResult(this.location, this.moduleSize, this.lastModuleSize);
}

typedef Refine = RefineResult? Function(Point finder, double moduleSize);

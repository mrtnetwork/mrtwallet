// The MIT License (MIT)

// Copyright (c) 2020 Pieter van Loon

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:math';
import 'package:flutter/rendering.dart';
import 'sliver_cross_axis_positioned.dart';

class RenderSliverCrossAxisConstrained extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderSliverCrossAxisPositionedMixin {
  /// Max allowed limit of the cross axis
  double get maxCrossAxisExtent => _maxCrossAxisExtent!;
  double? _maxCrossAxisExtent;
  set maxCrossAxisExtent(double value) {
    assert(value > 0);
    if (_maxCrossAxisExtent != value) {
      _maxCrossAxisExtent = value;
      markNeedsLayout();
    }
  }

  /// How to align the sliver in the cross axis
  /// 0 means center -1 means to the left +1 means to the right
  double get alignment => _alignment!;
  double? _alignment;
  set alignment(double value) {
    assert(value >= -1.0);
    assert(value <= 1.0);
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  @override
  SliverCrossAxisPositionedData createCrossAxisPositionData(
    SliverConstraints constraints,
  ) {
    final crossAxisExtent = min(
      constraints.crossAxisExtent,
      maxCrossAxisExtent,
    );
    return SliverCrossAxisPositionedData(
      crossAxisExtent: crossAxisExtent,
      crossAxisPosition: (alignment + 1) *
          ((constraints.crossAxisExtent - crossAxisExtent) / 2),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}

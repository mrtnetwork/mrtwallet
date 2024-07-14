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
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'rendering/sliver_cross_axis_constrained.dart';

/// Constrains and centers the [child] sliver to a maximum cross axis extent
/// specified by [maxCrossAxisExtent].
/// [alignment] specifies how to align the child where -1 is left +1 is right.
class SliverCrossAxisConstrained extends SingleChildRenderObjectWidget {
  const SliverCrossAxisConstrained({
    Key? key,
    required this.maxCrossAxisExtent,
    required Widget child,
    this.alignment = 0,
  }) : super(key: key, child: child);

  /// Max allowed limit of the cross axis
  final double maxCrossAxisExtent;

  /// How to align the sliver in the cross axis
  /// 0 means center -1 means to the left +1 means to the right
  final double alignment;

  @override
  RenderSliverCrossAxisConstrained createRenderObject(BuildContext context) {
    final renderObject = RenderSliverCrossAxisConstrained();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverCrossAxisConstrained renderObject) {
    renderObject
      ..maxCrossAxisExtent = maxCrossAxisExtent
      ..alignment = alignment;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<double>('maxCrossAxisExtent', maxCrossAxisExtent));
  }
}

import 'package:flutter/material.dart';
import 'rendering/sliver_pinned_header.dart';

/// [SliverPinnedHeader] keeps its child pinned to the leading edge of the viewport.
class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({super.key, required Widget super.child});

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}

class SliverPinnedHeaderSurface extends StatelessWidget {
  final Widget child;
  final double elevation;
  const SliverPinnedHeaderSurface(
      {super.key, required this.child, this.elevation = 0.0});

  @override
  Widget build(BuildContext context) {
    return SliverPinnedHeader(
        child: Material(elevation: elevation, child: child));
  }
}

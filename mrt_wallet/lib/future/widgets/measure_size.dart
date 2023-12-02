import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mrt_wallet/types/typedef.dart';

class _MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  FuncVoidSize onChange;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final FuncVoidSize onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      // ignore: library_private_types_in_public_api
      BuildContext context,
      covariant _MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

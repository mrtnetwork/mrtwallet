import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/widgets/animated/animation.dart';
import 'package:mrt_wallet/future/widgets/widgets/container_with_border.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';

class Shimmer extends StatelessWidget {
  final int count;
  final bool sliver;
  final bool enable;
  final WidgetContext onActive;
  const Shimmer({
    this.shimmerBox = const ShimmerBox(),
    this.count = 3,
    required this.onActive,
    this.sliver = false,
    required this.enable,
    super.key,
  });
  final Widget shimmerBox;
  @override
  Widget build(BuildContext context) {
    return switch (sliver) {
      false => APPAnimatedSwitcher(enable: enable, widgets: {
          false: (context) => ShimmerWidget(count: count, child: shimmerBox),
          true: onActive
        }),
      true => APPSliverAnimatedSwitcher(enable: enable, widgets: {
          false: (context) => SliverToBoxAdapter(
              child: ShimmerWidget(count: count, child: shimmerBox)),
          true: onActive
        }),
    };
  }
}

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final int count;

  const ShimmerWidget(
      {super.key, this.child = const ShimmerBox(), required this.count});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SafeState<ShimmerWidget>, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                context.colors.primaryContainer,
                context.colors.surface.wOpacity(0.8),
                context.colors.primaryContainer.wOpacity(0.5),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _GradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return widget.child;
            },
            itemCount: widget.count,
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _GradientTransform extends GradientTransform {
  final double slideValue;
  const _GradientTransform(this.slideValue);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slideValue, 0.0, 0.0);
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Row(children: []),
    );
  }
}

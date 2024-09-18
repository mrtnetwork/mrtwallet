import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst;
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'constraints_box_view.dart';
import 'widget_constant.dart';

typedef BodyBuilder = Widget Function(ScrollController controller);

class AppBottomSheet extends StatefulWidget {
  const AppBottomSheet(
      {super.key,
      required this.label,
      this.child,
      this.body,
      this.minExtent = 0.7,
      this.maxExtend = 1.0,
      this.initiaalExtend,
      this.centerContent = true,
      this.slivers = const [],
      this.actions = const []});
  final String label;
  final Widget? child;
  final BodyBuilder? body;
  final double maxExtend;
  final double minExtent;
  final double? initiaalExtend;
  final List<Widget> actions;
  final List<Widget> slivers;
  final bool centerContent;
  @override
  State<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<AppBottomSheet> {
  late final double initialExtend =
      (widget.initiaalExtend) ?? widget.minExtent.max(widget.maxExtend - 0.1);

  final DraggableScrollableController controller =
      DraggableScrollableController();
  double appBarAnimationRadius = 25.0;
  bool _calculateAppBarRadius(double v) {
    if (v > 0.9) {
      final double extent = 1 - v;
      appBarAnimationRadius = (25 * extent) * 10;
      if (mounted) setState(() {});
    } else if (appBarAnimationRadius < 25) {
      appBarAnimationRadius = 25;
      if (mounted) setState(() {});
    }

    return false;
  }

  void onTapGesture() {
    if (context.hasParentFocus) {
      context.clearFocus();
    } else {
      context.pop();
    }
  }

  bool inChangeExtend = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.initiaalExtend != null) {
      _calculateAppBarRadius(widget.initiaalExtend!);
    }
    final height = context.mediaQuery.viewInsets.bottom;
    if (height > 0 && controller.isAttached) {
      inChangeExtend = true;
      controller
          .animateTo(widget.maxExtend,
              duration: APPConst.milliseconds100, curve: Curves.linear)
          .then((value) {
        inChangeExtend = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapGesture,
          child: SizedBox(
            width: context.mediaQuery.size.width,
            height: context.mediaQuery.size.height,
          ),
        ),
        GestureDetector(
          onTap: () => context.clearFocus(),
          child: SizedBox.fromSize(
            size: Size.fromHeight(context.mediaQuery.size.height),
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (v) {
                if (!inChangeExtend) {
                  context.clearFocus();
                }
                return _calculateAppBarRadius(v.extent);
              },
              child: DraggableScrollableSheet(
                minChildSize: widget.minExtent,
                maxChildSize: widget.maxExtend,
                initialChildSize: initialExtend,
                controller: controller,
                builder: (context, scroll) {
                  return SafeArea(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(appBarAnimationRadius),
                          topRight: Radius.circular(appBarAnimationRadius)),
                      child: widget.body?.call(scroll) ??
                          Scaffold(
                            appBar: AppBar(
                              leadingWidth:
                                  appBarAnimationRadius < 2 ? 56.0 : 0,
                              actions: widget.actions,
                              leading: appBarAnimationRadius < 2
                                  ? null
                                  : const SizedBox(),
                              title: Text(widget.label),
                              centerTitle: false,
                            ),
                            body: Column(
                              children: [
                                if (widget.centerContent)
                                  Flexible(
                                    child: Center(
                                      child: CustomScrollView(
                                        shrinkWrap: true,
                                        controller: scroll,
                                        slivers: [
                                          ...widget.slivers,
                                          if (widget.child != null)
                                            SliverToBoxAdapter(
                                              child: ConstraintsBoxView(
                                                  padding:
                                                      WidgetConstant.padding20,
                                                  child: widget.child!),
                                            )
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: CustomScrollView(
                                      controller: scroll,
                                      slivers: [
                                        ...widget.slivers,
                                        if (widget.child != null)
                                          SliverToBoxAdapter(
                                            child: ConstraintsBoxView(
                                                padding:
                                                    WidgetConstant.padding20,
                                                child: widget.child!),
                                          )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

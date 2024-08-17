import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/core.dart' show MethodUtils;
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart'
    show DynamicVoid, FutureT;
import 'constraints_box_view.dart';
import 'widget_constant.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class DialogView extends StatelessWidget {
  const DialogView(
      {this.widget,
      this.title,
      this.titleWidget,
      this.content = const [],
      this.child,
      super.key});
  final Widget? widget;
  final Widget? child;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> content;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstraintsBoxView(
        alignment: Alignment.center,
        maxWidth: APPConst.dialogWidth,
        padding: WidgetConstant.padding20,
        child: ClipRRect(
          borderRadius: WidgetConstant.border25,
          child: Material(
            color: context.colors.surface,
            child: child ??
                CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    SliverAppBar(
                      title: titleWidget ?? Text(title ?? ""),
                      leading: WidgetConstant.sizedBox,
                      leadingWidth: 0,
                      pinned: true,
                      actions: [...content, const CloseButton()],
                    ),
                    SliverToBoxAdapter(
                      child: ConstraintsBoxView(
                        padding: WidgetConstant.padding20,
                        child: widget ?? WidgetConstant.sizedBox,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class DialogDoubleButtonView extends StatelessWidget {
  const DialogDoubleButtonView({
    super.key,
    this.firstButtonLabel,
    this.secoundButtonLabel,
    this.firstButtonPressed,
    this.secountButtonPressed,
  });
  final String? firstButtonLabel;
  final String? secoundButtonLabel;
  final DynamicVoid? firstButtonPressed;
  final DynamicVoid? secountButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetConstant.paddingOnlyTop20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton(
              onPressed: () {
                if (firstButtonPressed != null) {
                  firstButtonPressed?.call();
                } else {
                  context.pop(true);
                }
              },
              child: Text(firstButtonLabel ?? "yes".tr)),
          WidgetConstant.width8,
          FilledButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(context.colors.tertiaryContainer),
                  foregroundColor: WidgetStatePropertyAll(
                      context.colors.onTertiaryContainer)),
              onPressed: () {
                if (secountButtonPressed != null) {
                  secountButtonPressed?.call();
                } else {
                  context.pop(false);
                }
              },
              child: Text(secoundButtonLabel ?? "no".tr)),
        ],
      ),
    );
  }
}

class DialogTextView extends StatelessWidget {
  const DialogTextView({super.key, this.text, this.widget, this.buttonWidget});
  final String? text;
  final Widget? widget;
  final Widget? buttonWidget;
  @override
  Widget build(BuildContext context) {
    final Widget subtitle = widget ?? Text(text ?? "");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [subtitle, buttonWidget ?? WidgetConstant.sizedBox],
    );
  }
}

class AsyncDialogDoubleButtonView extends StatefulWidget {
  const AsyncDialogDoubleButtonView({
    super.key,
    this.firstButtonLabel,
    this.secoundButtonLabel,
    this.firstButtonPressed,
    this.secountButtonPressed,
  });
  final String? firstButtonLabel;
  final String? secoundButtonLabel;
  final FutureT? firstButtonPressed;
  final FutureT? secountButtonPressed;

  @override
  State<AsyncDialogDoubleButtonView> createState() =>
      _AsyncDialogDoubleButtonViewState();
}

class _AsyncDialogDoubleButtonViewState
    extends State<AsyncDialogDoubleButtonView> with SafeState {
  final GlobalKey<StreamWidgetState> progressKeyFirst =
      GlobalKey(debugLabel: "_AsyncDialogDoubleButtonViewState_1");
  final GlobalKey<StreamWidgetState> progressKeySecound =
      GlobalKey(debugLabel: "_AsyncDialogDoubleButtonViewState_2");
  String? _error;
  void onTap(bool first) async {
    if (first && widget.firstButtonPressed == null) {
      context.pop(true);
      return;
    } else if (!first && widget.secountButtonPressed == null) {
      context.pop(false);
      return;
    }
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
    final pKey = first ? progressKeyFirst : progressKeySecound;
    if (pKey.inProgress) return;
    pKey.process();
    final result = await MethodUtils.call(() async {
      if (first) {
        return await widget.firstButtonPressed!();
      }
      return await widget.secountButtonPressed!();
    });
    if (closed) return;
    if (result.hasError) {
      pKey.error();
      _error = result.error!;
      setState(() {});
    } else {
      pKey.success();
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        context.pop(result.result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetConstant.paddingOnlyTop20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StreamWidget(
              buttonWidget: FilledButton(
                  onPressed: () {
                    onTap(true);
                  },
                  child: Text(widget.firstButtonLabel ?? "yes".tr)),
              key: progressKeyFirst),
          WidgetConstant.width8,
          StreamWidget(
              buttonWidget: FilledButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          context.colors.tertiaryContainer),
                      foregroundColor: WidgetStatePropertyAll(
                          context.colors.onTertiaryContainer)),
                  onPressed: () {
                    onTap(false);
                  },
                  child: Text(widget.secoundButtonLabel ?? "no".tr)),
              key: progressKeySecound),
        ],
      ),
    );
  }
}

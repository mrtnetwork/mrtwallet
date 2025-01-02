import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

typedef OnTapMemo = Function(XRPLMemo);

class RippleMemosView extends StatelessWidget {
  const RippleMemosView(
      {required this.memos,
      super.key,
      required this.onCreateMemo,
      required this.onTapMemo});
  final List<XRPLMemo> memos;
  final DynamicVoid onCreateMemo;
  final OnTapMemo onTapMemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("memos".tr, style: context.textTheme.titleMedium),
                  Text("memo_desc".tr),
                ],
              ),
            ),
            if (memos.isNotEmpty)
              IconButton(
                  onPressed: onCreateMemo, icon: const Icon(Icons.add_box))
          ],
        ),
        WidgetConstant.height8,
        AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: memos.isEmpty
              ? ContainerWithBorder(
                  onRemove: onCreateMemo,
                  onRemoveIcon: Icon(
                    Icons.add,
                    color: context.colors.onPrimaryContainer,
                  ),
                  child: Text(
                    "tap_to_create_memo".tr,
                    style: context.onPrimaryTextTheme.bodyMedium,
                  ),
                )
              : Column(
                  children: List.generate(memos.length,
                      (index) => _RippleMemoView(memos[index], onTapMemo)),
                ),
        )
      ],
    );
  }
}

class _RippleMemoView extends StatelessWidget {
  const _RippleMemoView(this.memo, this.onTapMemo);
  final XRPLMemo memo;
  final OnTapMemo onTapMemo;
  @override
  Widget build(BuildContext context) {
    final bool memoIsEmpty = memo.memoType == null &&
        memo.memoFormat == null &&
        memo.memoData == null;
    final bodyMedium = context.onPrimaryTextTheme.bodyMedium;
    final labelLarge = context.onPrimaryTextTheme.labelLarge;
    return ContainerWithBorder(
        onRemoveIcon: Icon(
          Icons.edit,
          color: context.colors.onPrimaryContainer,
        ),
        onRemove: () {
          onTapMemo(memo);
        },
        child: memoIsEmpty
            ? Text("value_is_empty".tr)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (memo.memoData != null) ...[
                    Text("memo_data".tr, style: labelLarge),
                    Text(memo.memoData!, style: bodyMedium)
                  ],
                  if (memo.memoFormat != null) ...[
                    Text("memo_format".tr, style: labelLarge),
                    Text(memo.memoFormat!, style: bodyMedium)
                  ],
                  if (memo.memoType != null) ...[
                    Text("memo_type".tr, style: labelLarge),
                    Text(memo.memoType!, style: bodyMedium)
                  ],
                ],
              ));
  }
}

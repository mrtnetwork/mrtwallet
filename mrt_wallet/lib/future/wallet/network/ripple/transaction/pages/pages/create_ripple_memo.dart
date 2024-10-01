import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class CreateRippleMemoView extends StatefulWidget {
  const CreateRippleMemoView({super.key, this.memo});
  final XRPLMemo? memo;

  @override
  State<CreateRippleMemoView> createState() => _CreateRippleMemoViewState();
}

class _CreateRippleMemoViewState extends State<CreateRippleMemoView> {
  late String? memoData = widget.memo?.memoData;
  late String? memoFormat = widget.memo?.memoFormat;
  late String? memoType = widget.memo?.memoType;
  bool get isReady =>
      memoData != null || memoFormat != null || memoType != null;

  void onSetupData(String? v) {
    memoData = v;
    setState(() {});
  }

  void onSetupFormat(String? v) {
    memoFormat = v;
    setState(() {});
  }

  void onSetupType(String? v) {
    memoType = v;
    setState(() {});
  }

  void onSetupMemo() {
    final memo = XRPLMemo(
        memoData: memoData, memoFormat: memoFormat, memoType: memoType);
    context.pop(memo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "memos_field".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ripple_memo_desc1".tr),
                WidgetConstant.height8,
                Text("empty_desc".tr),
                WidgetConstant.height8,
                Text("hex_desc".tr)
              ],
            )),
        PageTitleSubtitle(
            title: "memo_data".tr,
            titleStyle: context.textTheme.titleMedium,
            body: Text("memo_data_desc".tr)),
        ContainerWithBorder(
          onRemoveIcon:
              memoData == null ? const Icon(Icons.add) : const Icon(Icons.edit),
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  "memos_field".tr,
                  child: StringWriterView(
                    defaultValue: memoData,
                    title: PageTitleSubtitle(
                        title: "memo_data".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("memo_data_desc".tr),
                            WidgetConstant.height8,
                            Text("empty_desc".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "memo".tr,
                  ),
                )
                .then(onSetupData);
          },
          child: Text(memoData ?? "tap_to_input_value".tr),
        ),
        WidgetConstant.height20,
        PageTitleSubtitle(
            titleStyle: context.textTheme.titleMedium,
            title: "memo_format".tr,
            body: Text("memo_format_desc".tr)),
        ContainerWithBorder(
          onRemoveIcon: memoFormat == null
              ? const Icon(Icons.add)
              : const Icon(Icons.edit),
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  "memos_field".tr,
                  child: StringWriterView(
                    defaultValue: memoFormat,
                    title: PageTitleSubtitle(
                        title: "memo_format".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("memo_format_desc".tr),
                            WidgetConstant.height8,
                            Text("empty_desc".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "memo".tr,
                  ),
                )
                .then(onSetupFormat);
          },
          child: Text(memoFormat ?? "tap_to_input_value".tr),
        ),
        WidgetConstant.height20,
        PageTitleSubtitle(
            titleStyle: context.textTheme.titleMedium,
            title: "memo_type".tr,
            body: Text("memo_type_desc".tr)),
        ContainerWithBorder(
          onRemoveIcon:
              memoType == null ? const Icon(Icons.add) : const Icon(Icons.edit),
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  "memos_field".tr,
                  child: StringWriterView(
                    defaultValue: memoType,
                    title: PageTitleSubtitle(
                        title: "memo_type".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("memo_type_desc".tr),
                            WidgetConstant.height8,
                            Text("empty_desc".tr),
                          ],
                        )),
                    buttonText: "setup_input".tr,
                    label: "memo_type".tr,
                  ),
                )
                .then(onSetupType);
          },
          child: Text(memoType ?? "tap_to_input_value".tr),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: isReady ? onSetupMemo : null,
              child: Text("setup_memo".tr),
            )
          ],
        )
      ],
    );
  }
}

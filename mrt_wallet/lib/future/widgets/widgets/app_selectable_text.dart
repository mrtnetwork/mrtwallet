import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'bytes_tools.dart';

class APPSelectableText extends StatelessWidget {
  const APPSelectableText(this.value,
      {this.maxlines = 10, this.minlines = 1, this.style, super.key});
  final TextStyle? style;
  final int? minlines;
  final int? maxlines;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      value,
      style: style,
      minLines: minlines,
      maxLines: maxlines,
      contextMenuBuilder: (context, editableTextState) {
        List<ContextMenuButtonItem> buttonItems =
            editableTextState.contextMenuButtonItems;
        final textEditingValue = editableTextState.currentTextEditingValue;
        final String fullText = textEditingValue.text;
        final TextSelection selection = textEditingValue.selection;
        String selectedText = '';
        if (selection.isValid && !selection.isCollapsed) {
          selectedText = fullText.substring(selection.start, selection.end);
        }
        if (StringUtils.isHexBytes(selectedText)) {
          final bytesTools = ContextMenuButtonItem(
              onPressed: () {
                editableTextState.hideToolbar();
                context.openSliverBottomSheet(
                  'bytes_tools'.tr,
                  child: BytesToolsView(value: selectedText),
                );
              },
              label: 'bytes_tools'.tr,
              type: ContextMenuButtonType.custom);
          buttonItems = [...buttonItems, bytesTools];
        }
        final isNumber = BigintUtils.tryParse(selectedText);
        if (isNumber != null) {
          void copyText(String text, BuildContext context) {
            Clipboard.setData(ClipboardData(text: text));
            context.showAlert("copied_to_clipboard".tr);
          }

          final n7 = SubstrateHelper.numberToDecimals(isNumber, 7);
          final n10 = SubstrateHelper.numberToDecimals(isNumber, 10);
          final n12 = SubstrateHelper.numberToDecimals(isNumber, 12);
          final n18 = SubstrateHelper.numberToDecimals(isNumber, 18);
          buttonItems = [
            ...buttonItems,
            ContextMenuButtonItem(
                onPressed: () {
                  copyText(n7, context);
                  editableTextState.hideToolbar();
                },
                label: 'number_to_decimal'.tr.replaceOne("7").replaceTwo(n7),
                type: ContextMenuButtonType.custom),
            ContextMenuButtonItem(
                onPressed: () {
                  copyText(n10, context);
                  editableTextState.hideToolbar();
                },
                label: 'number_to_decimal'.tr.replaceOne("10").replaceTwo(n10),
                type: ContextMenuButtonType.custom),
            ContextMenuButtonItem(
                onPressed: () {
                  copyText(n12, context);
                  editableTextState.hideToolbar();
                },
                label: 'number_to_decimal'.tr.replaceOne("12").replaceTwo(n12),
                type: ContextMenuButtonType.custom),
            ContextMenuButtonItem(
                onPressed: () {
                  copyText(n18, context);
                  editableTextState.hideToolbar();
                },
                label: 'number_to_decimal'.tr.replaceOne("18").replaceTwo(n18),
                type: ContextMenuButtonType.custom),
          ];
        }

        return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: buttonItems);
      },
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/types/typedef.dart';

class StringWriterView extends StatefulWidget {
  const StringWriterView({
    super.key,
    required this.title,
    required this.label,
    required this.buttomText,
    this.customValidator,
    this.defaultValue,
    this.minLength,
    this.maxLength,
    this.regExp,
  });
  final Widget title;
  final String label;
  final String buttomText;
  final int? minLength;
  final int? maxLength;
  final RegExp? regExp;
  final String? defaultValue;
  final NullStringString? customValidator;

  @override
  State<StringWriterView> createState() => _StringWriterViewState();
}

class _StringWriterViewState extends State<StringWriterView> with SafeState {
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "_StringWriterViewState");
  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "_StringWriterViewState_1");
  late String text = widget.defaultValue ?? "";
  void onChange(String v) {
    text = v;
  }

  String? validator(String? v) {
    if (widget.minLength == null &&
        widget.maxLength == null &&
        widget.regExp == null) return null;
    if (widget.regExp != null) {
      if (!widget.regExp!.hasMatch(v!)) {
        return "regular_exception_validate_desc"
            .tr
            .replaceOne(widget.regExp!.pattern);
      }
    }
    final int length = v?.length ?? 0;
    if (length < (widget.minLength ?? 0)) {
      return "character_length_min_validator"
          .tr
          .replaceOne("${widget.minLength ?? 0}");
    }
    if (widget.maxLength != null && length > widget.maxLength!) {
      return "character_length_max_validator"
          .tr
          .replaceOne("${widget.maxLength ?? 0}");
    }
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  void onPressed() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (context.mounted) {
      context.pop(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.title,
          WidgetConstant.height20,
          AppTextField(
            label: widget.label,
            minlines: 2,
            maxLines: 5,
            initialValue: text,
            validator: widget.customValidator ?? validator,
            suffixIcon: PasteTextIcon(onPaste: onPaste),
            onChanged: onChange,
            key: textFieldKey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: onPressed,
                child: Text(widget.buttomText),
              )
            ],
          )
        ],
      ),
    );
  }
}

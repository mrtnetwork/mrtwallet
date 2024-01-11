import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/types/typedef.dart';

class NumberWriteView extends StatefulWidget {
  const NumberWriteView({
    super.key,
    required this.title,
    required this.label,
    required this.buttomText,
    this.allowDecimal = true,
    this.defaultValue,
    this.maxPrecision,
    this.min,
    this.max,
    this.regExp,
    this.allowSign = true,
    this.customValidator,
  });
  final Widget title;
  final String label;
  final String buttomText;
  final BigRational? min;
  final BigRational? max;
  final RegExp? regExp;
  final BigRational? defaultValue;
  final int? maxPrecision;
  final bool allowDecimal;
  final bool allowSign;
  final NullStringString? customValidator;

  @override
  State<NumberWriteView> createState() => _NumberWriteViewState();
}

class _NumberWriteViewState extends State<NumberWriteView> with SafeState {
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "_NumberWriteViewState");
  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "_NumberWriteViewState_1");
  late String text = widget.defaultValue?.toString() ?? "0";
  void onChange(String v) {
    text = v;
  }

  String? validator(String? v) {
    final val = BigRational.tryParseDecimaal(v ?? "");
    if (val == null) {
      return "enter_valid_number".tr;
    }
    if (widget.regExp != null) {
      if (!widget.regExp!.hasMatch(v!)) {
        return "regular_exception_validate_desc"
            .tr
            .replaceOne(widget.regExp!.pattern);
      }
    }
    if (widget.min != null) {
      if (val < widget.min!) {
        return "minium_numnber_validator"
            .tr
            .replaceOne(widget.min!.toString().to3Digits);
      }
    }
    if (widget.max != null) {
      if (val > widget.max!) {
        return "maximum_number_validator"
            .tr
            .replaceOne(widget.max!.toString().to3Digits);
      }
    }
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  void onPressed() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final parse = BigRational.tryParseDecimaal(text);
    if (context.mounted && parse != null) {
      context.pop(parse);
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
          ConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            maxWidth: AppGlobalConst.maxTextFieldWidth,
            child: AppTextField(
              label: widget.label,
              minlines: 1,
              maxLines: 2,
              initialValue: text,
              keyboardType: TextInputType.numberWithOptions(
                  decimal: widget.allowDecimal, signed: widget.allowSign),
              inputFormatters: [
                BigRetionalRangeTextInputFormatter(
                    max: widget.max,
                    min: widget.min,
                    allowDecimal: widget.allowDecimal,
                    maxPrecision: widget.maxPrecision),
              ],
              validator: widget.customValidator ?? validator,
              suffixIcon: PasteTextIcon(onPaste: onPaste),
              textAlign: TextAlign.center,
              onChanged: onChange,
              key: textFieldKey,
            ),
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

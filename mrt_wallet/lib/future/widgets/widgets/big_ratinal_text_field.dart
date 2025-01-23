import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/text_field/input_formaters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'paste_icon_widget.dart';
import 'widget_constant.dart';

class BigRationalTextField extends StatefulWidget {
  const BigRationalTextField({
    super.key,
    required this.label,
    required this.onChange,
    this.padding = WidgetConstant.paddingVertical8,
    this.helperText,
    this.hintText,
    this.error,
    this.validator,
    this.defaultValue,
    required this.max,
    required this.min,
    this.maxScale,
    this.focusNode,
    this.nextFocus,
    this.disableWriting = false,
    this.showPasteIcon = false,
  });
  final bool showPasteIcon;
  final BigRational min;
  final BigRational? max;
  final EdgeInsets padding;
  final String label;
  final String? helperText;
  final String? hintText;
  final String? error;
  final NullStringString? validator;
  final BigIntRationalVoid onChange;
  final BigRational? defaultValue;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final bool disableWriting;
  final int? maxScale;
  @override
  State<BigRationalTextField> createState() => BigRationalTextFieldState();
}

class BigRationalTextFieldState extends State<BigRationalTextField>
    with SafeState<BigRationalTextField> {
  final TextEditingController _controller = TextEditingController(text: "");
  late BigRational min;
  BigRational? max;
  int? maxScale;
  bool allowSign = false;
  bool showDecimal = false;

  void onSubmitField(String v) {
    if (widget.nextFocus != null) {
      if (mounted) widget.nextFocus?.requestFocus();
    }
  }

  void listener() {
    final value = _controller.text.isEmpty
        ? widget.min
        : BigRational.parseDecimal(_controller.text);
    widget.onChange(value);
  }

  void changeIndex(BigRational newIndex) {
    if (newIndex < widget.min ||
        (widget.max != null && newIndex > widget.max!)) {
      return;
    }
    _controller.text = "$newIndex";
  }

  void setValue(BigRational value) {
    _controller.text = value.toDecimal();
  }

  BigInt? getValue() {
    return BigInt.tryParse(_controller.text);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(listener);
    if (widget.defaultValue != null) {
      MethodUtils.after(
          () async => changeIndex(widget.defaultValue ?? widget.min));
    }
  }

  void onPaste(String v) {
    _controller.text = v;
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    _controller.dispose();
    super.dispose();
  }

  // void updateWidget() {

  // }

  void updateScale(
      {required int? maxScale,
      required BigRational min,
      required BigRational max}) {
    this.maxScale = maxScale;
    this.min = min;
    this.max = max;
    allowSign = min.isNegative;
    showDecimal = this.maxScale != null;
    updateState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    maxScale = widget.maxScale;
    allowSign = widget.min.isNegative;
    showDecimal = maxScale != null;
    min = widget.min;
    max = widget.max;
  }

  @override
  Widget build(BuildContext context) {
    return _NumberTextFieldView(
      padding: widget.padding,
      controller: _controller,
      showPasteIcon: widget.showPasteIcon,
      allowSign: widget.min.isNegative,
      disableWriting: widget.disableWriting,
      error: widget.error,
      focusNode: widget.focusNode,
      helperText: widget.helperText,
      hintText: widget.hintText,
      label: widget.label,
      validator: widget.validator,
      onSubmitField: onSubmitField,
      onPaste: onPaste,
      inputFormatters: [
        // FilteringTextInputFormatter.digitsOnly,
        BigRetionalRangeTextInputFormatter(
            min: min,
            max: max,
            allowSign: allowSign,
            allowDecimal: showDecimal,
            maxScale: maxScale)
      ],
    );
  }
}

class _NumberTextFieldView extends StatelessWidget {
  const _NumberTextFieldView(
      {required this.padding,
      required this.controller,
      this.hintText,
      this.helperText,
      required this.showPasteIcon,
      this.error,
      this.label,
      this.focusNode,
      required this.allowSign,
      this.inputFormatters,
      required this.disableWriting,
      this.validator,
      required this.onSubmitField,
      required this.onPaste});
  final EdgeInsetsGeometry padding;
  // final bool minus;
  final TextEditingController controller;
  final String? hintText;
  final String? helperText;
  final bool showPasteIcon;
  final String? error;
  final String? label;
  final FocusNode? focusNode;
  final bool allowSign;
  final List<TextInputFormatter>? inputFormatters;
  final bool disableWriting;
  // final bool add;
  final NullStringString? validator;
  final StringVoid onSubmitField;
  final StringVoid onPaste;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        textAlign: TextAlign.center,
        autovalidateMode: AutovalidateMode.always,
        focusNode: focusNode,
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: allowSign),
        controller: controller,
        validator: validator,
        onFieldSubmitted: onSubmitField,
        minLines: null,
        maxLines: null,
        inputFormatters: inputFormatters,
        readOnly: disableWriting,
        decoration: InputDecoration(
            filled: true,
            hintText: hintText,
            helperText: helperText,
            suffixIcon: showPasteIcon
                ? PasteTextIcon(onPaste: onPaste, isSensitive: false)
                : null,
            errorText: error,
            labelText: label,
            border: OutlineInputBorder(
                borderRadius: WidgetConstant.border8,
                borderSide: BorderSide.none)),
      ),
    );
  }
}

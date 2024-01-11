import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:mrt_wallet/app/core.dart';

class AppTextField extends StatefulWidget {
  const AppTextField(
      {super.key,
      this.minlines,
      this.maxLines,
      this.label,
      this.onChanged,
      this.hint,
      this.error,
      this.validator,
      this.inputFormatters,
      this.suffix,
      this.helperText,
      this.keyboardType,
      this.textDirection,
      this.padding = WidgetConstant.paddingVertical8,
      this.obscureText = false,
      this.suffixIcon,
      this.prefix,
      this.prefixIcon,
      this.textInputAction,
      this.focusNode,
      this.nextFocus,
      this.disableContextMenu = false,
      this.filled = true,
      this.initialValue,
      this.style,
      this.textAlign = TextAlign.start,
      this.readOnly = false,
      this.helperStyle});
  final String? label;
  final String? hint;
  final String? error;
  final StringVoid? onChanged;
  final NullStringString? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final EdgeInsets padding;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final bool disableContextMenu;
  final int? minlines;
  final int? maxLines;
  final bool filled;
  final String? initialValue;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool readOnly;
  final TextStyle? helperStyle;
  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> with SafeState {
  late TextDirection? direction = widget.textDirection;
  final TextEditingController controller = TextEditingController();
  late bool obscureText = widget.obscureText;
  void listener() {
    widget.onChanged?.call(controller.text);
  }

  void onChaangeObscureText() {
    obscureText = !obscureText;
    setState(() {});
  }

  void onChange(String value) {
    if (!mounted) return;
    widget.onChanged?.call(value);
    if (widget.textDirection != null) return;
    if (value.trim().isEmpty) {
      if (direction != null) {
        direction = null;
        setState(() {});
      }
    } else if (AppStringUtility.startsWithRtl(value)) {
      if (direction != TextDirection.rtl) {
        direction = TextDirection.rtl;
        setState(() {});
      }
    } else {
      if (direction != TextDirection.ltr) {
        direction = TextDirection.ltr;
        setState(() {});
      }
    }
  }

  void onSubmitField(String v) {
    if (widget.nextFocus != null) {
      if (mounted) widget.nextFocus?.requestFocus();
    }
  }

  void updateText(String text) {
    if (mounted) {
      controller.text = text;
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    Future.delayed(Duration.zero, () {
      controller.text = widget.initialValue ?? "";
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TextFormField(
        textAlign: widget.textAlign,
        controller: controller,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        autofillHints: const [],
        onChanged: onChange,
        textDirection: direction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: widget.keyboardType,
        focusNode: widget.focusNode,
        obscureText: obscureText,
        style: widget.style,
        readOnly: widget.readOnly,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: onSubmitField,
        minLines: widget.minlines,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        contextMenuBuilder: widget.disableContextMenu
            ? null
            : (context, editableTextState) =>
                AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                ),
        decoration: InputDecoration(
            filled: widget.filled,
            suffix: widget.suffix,
            prefix: widget.prefix,
            prefixIcon: widget.prefixIcon,
            helperStyle: widget.helperStyle,
            helperMaxLines: 2,
            errorMaxLines: 2,
            helperText: widget.helperText,
            labelText: widget.label,
            border: OutlineInputBorder(
                borderRadius: WidgetConstant.border8,
                borderSide: BorderSide.none),
            suffixIcon: widget.suffixIcon ??
                (widget.obscureText
                    ? ObscureIcon(
                        show: obscureText, onTap: onChaangeObscureText)
                    : null),
            hintText: widget.hint,
            errorText: widget.error),
      ),
    );
  }
}

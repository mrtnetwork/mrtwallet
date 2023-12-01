import 'package:flutter/material.dart';
import 'package:mrt_wallet/types/typedef.dart';

class AppDropDownBottom<T> extends StatefulWidget {
  const AppDropDownBottom({
    super.key,
    required this.items,
    required this.label,
    this.value,
    this.onChanged,
    this.validator,
    this.icon,
    this.error,
  });
  final Map<T, Widget> items;
  final FuncVoidNullT? onChanged;
  final NullStringT? validator;
  final String label;
  final Widget? icon;
  final String? error;
  final T? value;
  @override
  State<AppDropDownBottom> createState() => _AppDropDownBottomState<T>();
}

class _AppDropDownBottomState<T> extends State<AppDropDownBottom> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      items: widget.items.keys
          .map<DropdownMenuItem<T>>((e) => DropdownMenuItem<T>(
                value: e,
                child: widget.items[e]!,
              ))
          .toList(),
      icon: widget.icon,
      onChanged: widget.onChanged,
      validator: widget.validator,
      value: widget.value,
      decoration: InputDecoration(
          labelText: widget.label, errorText: widget.error, errorMaxLines: 3),
    );
  }
}

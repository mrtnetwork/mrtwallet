import 'package:flutter/material.dart';
import 'package:mrt_wallet/types/typedef.dart';

class AppDropDownBottom<T> extends StatelessWidget {
  const AppDropDownBottom(
      {super.key,
      required this.items,
      required this.label,
      this.value,
      this.onChanged,
      this.validator,
      this.icon,
      this.error,
      this.suffixIcon});
  final Map<T, Widget> items;
  final FuncVoidNullT<T?>? onChanged;
  final NullStringT<T>? validator;
  final String label;
  final Widget? icon;
  final String? error;
  final T? value;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: items.keys
          .map<DropdownMenuItem<T>>(
              (e) => DropdownMenuItem<T>(value: e, child: items[e]!))
          .toList(),
      icon: icon,
      onChanged: onChanged,
      validator: validator,
      value: value,
      decoration: InputDecoration(
          labelText: label,
          errorText: error,
          errorMaxLines: 3,
          suffixIcon: suffixIcon),
    );
  }
}

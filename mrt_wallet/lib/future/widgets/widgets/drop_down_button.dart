import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart'
    show FuncVoidNullT, NullStringT;

class AppDropDownBottom<T> extends StatelessWidget {
  const AppDropDownBottom(
      {super.key,
      required this.items,
      required this.label,
      this.itemBuilder,
      this.value,
      this.onChanged,
      this.validator,
      this.icon,
      this.error,
      this.suffixIcon,
      this.isExpanded = false});
  final Map<T, Widget> items;
  final Map<T, Widget>? itemBuilder;
  final FuncVoidNullT<T?>? onChanged;
  final NullStringT<T>? validator;
  final String label;
  final Widget? icon;
  final String? error;
  final T? value;
  final Widget? suffixIcon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: itemBuilder?.keys
              .map<DropdownMenuItem<T>>(
                  (e) => DropdownMenuItem<T>(value: e, child: itemBuilder![e]!))
              .toList() ??
          items.keys
              .map<DropdownMenuItem<T>>(
                  (e) => DropdownMenuItem<T>(value: e, child: items[e]!))
              .toList(),
      icon: icon,
      selectedItemBuilder: (context) => items.keys
          .map<DropdownMenuItem<T>>(
              (e) => DropdownMenuItem<T>(value: e, child: items[e]!))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: isExpanded,
      value: value,
      decoration: InputDecoration(
          labelText: label,
          errorText: error,
          errorMaxLines: 3,
          suffixIcon: suffixIcon),
    );
  }
}

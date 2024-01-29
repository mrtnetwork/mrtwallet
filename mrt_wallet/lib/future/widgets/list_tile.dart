import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/context.dart';
import 'package:mrt_wallet/types/typedef.dart';

class AppListTile extends StatelessWidget {
  const AppListTile(
      {Key? key,
      this.title,
      this.subtitle,
      this.trailing,
      this.leading,
      this.onTap,
      this.contentPadding,
      this.tileColor,
      this.enabled = true,
      this.selected = false,
      this.disabled = false,
      this.maxLine = 2})
      : super(key: key);
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final DynamicVoid? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? tileColor;
  final bool enabled;
  final bool selected;
  final bool disabled;
  final int maxLine;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.labelLarge!, child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: maxLine,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
      trailing: trailing,
      leading: leading,
      onTap: onTap,
      contentPadding: contentPadding,
      tileColor: tileColor,
      enabled: enabled,
      selected: selected,
    );
  }
}

class AppCheckListTile extends StatelessWidget {
  const AppCheckListTile(
      {Key? key, this.onChanged, this.value, this.title, this.subtitle})
      : super(key: key);
  final NullBoolVoid? onChanged;
  final bool? value;
  final Widget? title;
  final Widget? subtitle;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      onChanged: onChanged,
      value: value,
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.labelLarge!, child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
    );
  }
}

class AppRadioListTile<T> extends StatelessWidget {
  const AppRadioListTile(
      {Key? key,
      required this.groupValue,
      this.onChanged,
      required this.value,
      this.title,
      this.subtitle})
      : super(key: key);
  final void Function(T? value)? onChanged;
  final T value;
  final Widget? title;
  final Widget? subtitle;
  final T? groupValue;
  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      onChanged: onChanged,
      groupValue: groupValue,
      value: value,
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.labelLarge!, child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
    );
  }
}

class AppSwitchListTile extends StatelessWidget {
  const AppSwitchListTile(
      {Key? key,
      this.onChanged,
      required this.value,
      this.title,
      this.subtitle})
      : super(key: key);
  final NullBoolVoid? onChanged;
  final bool value;
  final Widget? title;
  final Widget? subtitle;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      onChanged: onChanged,
      value: value,
      title: title == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              child: title!),
      subtitle: subtitle == null
          ? null
          : DefaultTextStyle(
              style: context.textTheme.bodyMedium!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              child: subtitle!, 
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class AccountAppbarActionView extends StatelessWidget {
  const AccountAppbarActionView(
      {required this.text,
      this.actionIcon,
      required this.onAction,
      required this.onHide,
      super.key});
  final String text;
  final Icon? actionIcon;
  final DynamicVoid onAction;
  final DynamicVoid onHide;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAction,
      child: MaterialBanner(
        backgroundColor: context.colors.inverseSurface,
        content: Text(
          text,
          style: context.colors.onInverseSurface.bodyMedium(context),
        ),
        actions: [
          IconButton(
              onPressed: onHide,
              icon: Icon(
                Icons.close,
                color: context.colors.onInverseSurface,
              ))
        ],
      ),
    );
  }
}

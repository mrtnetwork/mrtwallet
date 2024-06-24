import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/context.dart';

class MaterialPageView extends StatelessWidget {
  const MaterialPageView({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.primary,
      child: SafeArea(
          child: Container(
        color: context.colors.surface,
        child: child,
      )),
    );
  }
}

class ScaffolPageView extends StatelessWidget {
  const ScaffolPageView({required this.child, super.key, this.appBar});
  final Widget child;
  final AppBar? appBar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
    );
  }
}

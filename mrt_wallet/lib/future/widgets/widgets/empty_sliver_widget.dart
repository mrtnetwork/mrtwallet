import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst, Translate;
import 'widget_constant.dart';

typedef OnItemBuilder = Widget Function();

class EmptyItemSliverWidgetView extends StatelessWidget {
  const EmptyItemSliverWidgetView({
    required this.isEmpty,
    required this.itemBuilder,
    super.key,
    this.icon,
    this.subject,
  });
  final bool isEmpty;
  final IconData? icon;
  final String? subject;
  final OnItemBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon ?? Icons.hourglass_empty, size: APPConst.double80),
                WidgetConstant.height8,
                Text("no_items_found".tr),
              ],
            ),
          )
        : itemBuilder();
  }
}

class EmptyItemWidgetView extends StatelessWidget {
  const EmptyItemWidgetView({
    required this.isEmpty,
    required this.itemBuilder,
    super.key,
    this.icon,
    this.subject,
  });
  final bool isEmpty;
  final IconData? icon;
  final String? subject;
  final OnItemBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon ?? Icons.hourglass_empty,
                        size: APPConst.double80),
                    WidgetConstant.height8,
                    Text("no_items_found".tr),
                  ],
                ),
              ),
            ],
          )
        : itemBuilder();
  }
}

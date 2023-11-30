import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/context.dart';
import 'widget_constant.dart';

class PageTitleSubtitle extends StatelessWidget {
  const PageTitleSubtitle(
      {super.key, required this.title, required this.body, this.subtitle});
  final String? title;
  final Widget body;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title ?? "",
            style: context.textTheme.titleLarge,
          ),
        Padding(
          padding: title == null ? EdgeInsets.zero : WidgetConstant.padding10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle ?? "",
                  style: context.textTheme.labelLarge,
                ),
              Padding(
                padding: WidgetConstant.padding5,
                child: body,
              )
            ],
          ),
        ),
      ],
    );
  }
}

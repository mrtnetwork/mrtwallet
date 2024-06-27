import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show ColorConst, QuickContextAccsess, Translate, UriUtils;

class TextAndLinkView extends StatelessWidget {
  const TextAndLinkView(
      {required this.text, required this.url, super.key, this.linkDesc});
  final String text;
  final String url;
  final String? linkDesc;
  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(style: context.textTheme.bodyMedium, children: [
      TextSpan(text: text),
      const TextSpan(text: " "),
      TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              UriUtils.lunch(url);
            },
          text: linkDesc ?? "end_link".tr,
          style: context.textTheme.titleSmall?.copyWith(color: ColorConst.blue))
    ]));
  }
}

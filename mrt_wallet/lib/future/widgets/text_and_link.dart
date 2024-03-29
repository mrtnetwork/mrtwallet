import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';

class TextAndLinkView extends StatelessWidget {
  const TextAndLinkView({required this.text, required this.url, super.key});
  final String text;
  final String url;
  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(style: context.textTheme.bodyMedium, children: [
      TextSpan(text: text),
      const TextSpan(text: " "),
      TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              PlatformInterface.interface.launchUri(url);
            },
          text: "end_link".tr,
          style:
              context.textTheme.titleMedium?.copyWith(color: CustomColors.blue))
    ]));
  }
}

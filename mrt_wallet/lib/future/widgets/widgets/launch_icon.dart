import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show UriUtils;
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class LaunchBrowserIcon extends StatelessWidget {
  const LaunchBrowserIcon({required this.url, this.color, Key? key, this.size})
      : super(key: key);
  final String? url;
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (url == null) {
            context.showAlert("url_does_not_exists".tr);
            return;
          }
          UriUtils.lunch(url);
        },
        icon: Icon(Icons.launch, size: size));
  }
}

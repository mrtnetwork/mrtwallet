import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/context.dart';

List<Widget> bottomAppBarWidgets(BuildContext context) {
  if (PlatformInterface.supportWebView) {
    return [
      IconButton(
          onPressed: () {
            context.to(PageRouter.webview);
          },
          icon: const Icon(Icons.travel_explore))
    ];
  }
  return [];
}

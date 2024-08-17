import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/widgets/list_tile.dart';

class WebViewPopupMenu extends StatelessWidget {
  const WebViewPopupMenu(this.controller, {Key? key}) : super(key: key);
  final WebViewStateController controller;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(onSelected: (v) {
      switch (v) {
        case 0:
          controller.showHistories();
          break;
        case 1:
          controller.addOrRemoveFromBookMark(controller.controller.tab.value);
          break;
        case 2:
          controller.showBookmarks();
          break;
        default:
          break;
      }
    }, itemBuilder: (c) {
      return [
        PopupMenuItem<int>(
          value: 0,
          child: AppListTile(
            trailing: const Icon(Icons.history),
            title: Text("histories".tr, style: context.textTheme.labelMedium),
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: AppListTile(
            trailing: controller.inBokmark
                ? const Icon(Icons.bookmark_added)
                : const Icon(Icons.bookmark_add_outlined),
            title: Text("bookmark".tr, style: context.textTheme.labelMedium),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: AppListTile(
            trailing: const Icon(Icons.bookmarks),
            title: Text("bookmarks".tr, style: context.textTheme.labelMedium),
          ),
        ),
      ];
    });
  }
}

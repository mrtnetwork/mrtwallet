import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/permission_view.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/tab_handler.dart';
import 'package:mrt_wallet/future/wallet/webview/view/native_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'menu.dart';

class WebView extends StatelessWidget {
  const WebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder(
        controller: () => WebViewStateController(
            context.watch<WalletProvider>(StateConst.main)),
        repositoryId: StateConst.webview,
        builder: (model) {
          return PopScope<bool>(
            canPop: false,
            onPopInvokedWithResult: (inBrowser, s) {
              if (s == true) return;
              model.onBackButton(() {
                if (context.mounted) {
                  context.pop(true);
                }
              });
            },
            child: MaterialPageView(
                child: UnfocusableChild(
              child: Scaffold(
                appBar: model.inited ? null : AppBar(),
                // width: context.mediaQuery.size.height,
                body: PageProgress(
                  key: model.progressKey,
                  initialStatus: StreamWidgetStatus.progress,
                  initialWidget: const PageProgressChildWidget(
                      Icon(Icons.travel_explore, size: APPConst.double80)),
                  child: (c) => RefreshIndicator(
                    onRefresh: model.reload,
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            pinned: true,
                            centerTitle: false,
                            leading: IconButton(
                                onPressed: () {
                                  model.onPop(() {
                                    context.pop(true);
                                  });
                                },
                                icon: const Icon(Icons.arrow_back)),
                            actions: [
                              APPAnimatedSwitcher(enable: model.page, widgets: {
                                WebViewTabPage.tabs: (c) => TextButton.icon(
                                      onPressed: () {
                                        model.newTab((v) {});
                                      },
                                      label: Text("new_tab".tr),
                                      icon: const Icon(Icons.add_box),
                                    ),
                                WebViewTabPage.browser: (c) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        LiveWidget(() {
                                          final status = model.web3Status.value;
                                          return IconButton(
                                              iconSize: 28,
                                              onPressed: status.inProgress
                                                  ? null
                                                  : () {
                                                      context.openDialogPage(
                                                        "update_permission".tr,
                                                        fullWidget:
                                                            Web3PermissionUpdateView(
                                                                controller:
                                                                    model),
                                                      );
                                                    },
                                              icon: APPAnimatedSwitcher(
                                                enable: status,
                                                widgets: {
                                                  MRTScriptWalletStatus.active:
                                                      (c) => Icon(
                                                          Icons.security,
                                                          color: context
                                                              .colors.primary),
                                                  MRTScriptWalletStatus.failed:
                                                      (c) => const Icon(
                                                          Icons.error),
                                                  MRTScriptWalletStatus.block:
                                                      (c) => const Icon(
                                                          Icons.block),
                                                  MRTScriptWalletStatus
                                                          .progress:
                                                      (c) => Icon(
                                                          Icons.security,
                                                          color: context
                                                              .colors.disable),
                                                },
                                              ));
                                        }),
                                        IconButton(
                                            iconSize: 28,
                                            onPressed: () {
                                              model.showOpenTabs();
                                            },
                                            icon: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                const Icon(Icons
                                                    .check_box_outline_blank_rounded),
                                                Text(
                                                  model.tabsLength.toString(),
                                                  style: context
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w900),
                                                )
                                              ],
                                            )),
                                        WebViewPopupMenu(model),
                                      ],
                                    ),
                                WebViewTabPage.history: (c) => TextButton.icon(
                                      onPressed: model.clearHistory,
                                      label: Text("remove_all".tr),
                                      icon: const Icon(Icons.clear),
                                    ),
                                WebViewTabPage.bookmarks: (c) =>
                                    TextButton.icon(
                                      onPressed: model.clearBookmark,
                                      label: Text("remove_all".tr),
                                      icon: const Icon(Icons.clear),
                                    ),
                              }),
                            ],
                            bottom: APPPreferredSizeWidget(
                                height: model.inBrowser ? 80 : 0,
                                child: APPAnimatedContainer(
                                    isActive: model.inBrowser,
                                    onActive: (c) => Column(
                                          children: [
                                            Row(
                                              children: [
                                                WidgetConstant.width8,
                                                Flexible(
                                                  child: AppTextField(
                                                    key: model.textField,
                                                    focusNode: model.focusNode,
                                                    maxLines: 1,
                                                    keyboardType:
                                                        TextInputType.url,
                                                    initialValue: model
                                                        .controller
                                                        .tab
                                                        .value
                                                        .url,
                                                    prefixIcon: LiveWidget(() {
                                                      return CircleAPPImageView(
                                                        model.controller.image,
                                                        radius: 15,
                                                        onError: (c) =>
                                                            const Icon(Icons
                                                                .travel_explore_rounded),
                                                        onProgress: (c) =>
                                                            const Icon(Icons
                                                                .travel_explore_rounded),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                                LiveWidget(() {
                                                  return Row(
                                                    key: ValueKey(model
                                                        .liveNotifier.value),
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      _BooleanFutureIcon(
                                                          callBack:
                                                              model.goBack,
                                                          icon:
                                                              Icons.arrow_back,
                                                          onLoading: model
                                                              .canGoBack()),
                                                      _BooleanFutureIcon(
                                                          callBack:
                                                              model.goForward,
                                                          icon: Icons
                                                              .arrow_forward,
                                                          onLoading: model
                                                              .canGoForward()),
                                                    ],
                                                  );
                                                })
                                              ],
                                            ),
                                            LiveWidget(() {
                                              if (model.progress.value !=
                                                  null) {
                                                return SizedBox(
                                                  height: 8,
                                                  child:
                                                      LinearProgressIndicator(
                                                          value: model
                                                              .progress.value),
                                                );
                                              }
                                              return WidgetConstant.height8;
                                            }),
                                          ],
                                        ),
                                    onDeactive: (c) =>
                                        WidgetConstant.sizedBox)),
                          )
                        ];
                      },
                      body: APPAnimatedSwitcher(
                        enable: model.page,
                        widgets: {
                          WebViewTabPage.tabs: (c) => _TabsPage(model),
                          WebViewTabPage.browser: (c) => APPNativeView(
                                controller: model.controller.controller,
                                gestureRecognizers: {
                                  Factory<OneSequenceGestureRecognizer>(
                                      () => EagerGestureRecognizer()),
                                },
                              ),
                          WebViewTabPage.bookmarks: (c) => _BookmarksPage(
                              model: model, tabs: model.bookmarks),
                          WebViewTabPage.history: (c) => _HistoriesPage(
                              model: model, histories: model.histories),
                        },
                        height: context.mediaQuery.size.height,
                      ),
                    ),
                  ),
                ),
              ),
            )),
          );
        });
  }
}

class _BookmarksPage extends StatelessWidget {
  final WebViewStateController model;
  final List<WebViewTab> tabs;
  const _BookmarksPage({required this.model, required this.tabs, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.mediaQuery.size.height,
      child: Padding(
        padding: WidgetConstant.paddingHorizontal10,
        child: EmptyItemWidgetView(
          isEmpty: tabs.isEmpty,
          itemBuilder: () => ListView.separated(
            itemBuilder: (context, index) {
              final tab = tabs[index];
              final bool haveTitle = tab.title != null;
              return ContainerWithBorder(
                padding: WidgetConstant.padding10,
                onRemove: () {},
                onTapWhenOnRemove: false,
                onRemoveWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          model.openTabPage(tab);
                        },
                        icon: Icon(Icons.open_in_browser,
                            color: context.colors.onPrimaryContainer)),
                    IconButton(
                        onPressed: () {
                          model.removeBookmars(tab);
                        },
                        icon: Icon(Icons.remove_circle,
                            color: context.colors.onPrimaryContainer)),
                  ],
                ),
                margin: WidgetConstant.paddingH10V5,
                child: Row(
                  children: [
                    CircleAPPImageView(
                      tab.image,
                      radius: 15,
                      // imageColor: context.colors.primaryContainer,
                      onError: (c) => const Icon(Icons.travel_explore_rounded),
                      onProgress: (c) =>
                          const Icon(Icons.travel_explore_rounded),
                    ),
                    WidgetConstant.width8,
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (haveTitle)
                            OneLineTextWidget(tab.title!,
                                style: context.textTheme.labelLarge),
                          OneLineTextWidget(tab.viewName,
                              style: haveTitle
                                  ? context.textTheme.bodyMedium
                                  : context.textTheme.labelLarge),
                        ])),
                  ],
                ),
              );
            },
            itemCount: tabs.length,
            separatorBuilder: (context, index) => WidgetConstant.height8,
            shrinkWrap: true,
          ),
        ),
      ),
    );
  }
}

class _HistoriesPage extends StatefulWidget {
  final WebViewStateController model;
  final List<WebViewTab> histories;
  const _HistoriesPage({required this.model, required this.histories, Key? key})
      : super(key: key);

  @override
  State<_HistoriesPage> createState() => _HistoriesPageState();
}

class _HistoriesPageState extends State<_HistoriesPage> with SafeState {
  late final List<WebViewTab> tabs = List<WebViewTab>.from(widget.histories);
  Map<DateTime, List<WebViewTab>> histories = {};
  Map<DateTime, List<WebViewTab>> groupVisitsByDate(List<WebViewTab> visits) {
    Map<DateTime, List<WebViewTab>> groupedVisits = {};
    for (var visit in visits) {
      DateTime dateKey = visit.lastVisit.toOnlyDate();
      groupedVisits[dateKey] ??= [];
      groupedVisits[dateKey]!.add(visit);
    }
    return groupedVisits;
  }

  void remove(DateTime key, WebViewTab tab, int index) {
    tabs.remove(tab);
    histories[key]?.remove(tab);
    if (histories[key]?.isEmpty ?? false) {
      histories.remove(key);
    }
    updateState();
    widget.model.removeHistory(tab);
    listKey.currentState?.removeIndex(index);
  }

  void clearBookmarks() {
    widget.model.clearHistory();
  }

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  final GlobalKey<APPRemovableListState> listKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async {
      histories = groupVisitsByDate(tabs);
      progressKey.backToIdle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialStatus: StreamWidgetStatus.progress,
      child: (c) => Padding(
        padding: WidgetConstant.paddingHorizontal10,
        child: EmptyItemWidgetView(
          isEmpty: histories.isEmpty,
          itemBuilder: () => APPAnimatedRemovableList(
            length: tabs.length,
            shrinkWrap: true,
            key: listKey,
            itemBuilder: (context, int pos, animated, [bool? inRemove]) {
              if (inRemove == true && tabs.isEmpty) {
                return WidgetConstant.sizedBox;
              }
              final tab = tabs[pos];
              DateTime dateKey = tab.lastVisit.toOnlyDate();
              final index = histories[dateKey]?.indexOf(tab) ?? -1;
              final bool haveTitle = tab.title != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (inRemove != true) ...[
                    if (pos > 0 && index == 0) WidgetConstant.height20,
                    if (index == 0) ...[
                      WidgetConstant.height8,
                      Text(dateKey.toOnlyDateStr(),
                          style: context.textTheme.titleMedium),
                    ],
                  ],
                  FadeTransition(
                    opacity: animated,
                    child: ContainerWithBorder(
                      padding: WidgetConstant.padding10,
                      onRemove: () {},
                      onTapWhenOnRemove: false,
                      onRemoveWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                widget.model.openTabPage(tab);
                              },
                              icon: Icon(Icons.open_in_browser,
                                  color: context.colors.onPrimaryContainer)),
                          IconButton(
                              onPressed: () {
                                remove(dateKey, tab, pos);
                              },
                              icon: Icon(Icons.remove_circle,
                                  color: context.colors.onPrimaryContainer)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAPPImageView(
                            tab.image,
                            radius: 15,
                            onError: (c) =>
                                const Icon(Icons.travel_explore_rounded),
                            onProgress: (c) =>
                                const Icon(Icons.travel_explore_rounded),
                          ),
                          WidgetConstant.width8,
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      tab.lastVisit.toTimeOnlyStr(),
                                      style: context.colors.onPrimaryContainer
                                          .bodySmall(context),
                                    )
                                  ],
                                ),
                                if (haveTitle)
                                  OneLineTextWidget(
                                    tab.title!,
                                    style: context.colors.onPrimaryContainer
                                        .lableLarge(context),
                                  ),
                                OneLineTextWidget(tab.viewName,
                                    style: haveTitle
                                        ? context.colors.onPrimaryContainer
                                            .bodyMedium(context)
                                        : context.colors.onPrimaryContainer
                                            .lableLarge(context)),
                              ])),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

typedef _OnIconStatus = Future<bool>;

class _BooleanFutureIcon extends StatelessWidget {
  const _BooleanFutureIcon(
      {required this.callBack,
      required this.icon,
      required this.onLoading,
      Key? key})
      : super(key: key);
  final IconData icon;
  final _OnIconStatus onLoading;
  final DynamicVoid callBack;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: onLoading,
      builder: (context, snapshot) {
        bool enable = snapshot.hasData && snapshot.data!;
        return IconButton(
            onPressed: enable ? callBack : null, icon: Icon(icon));
      },
    );
  }
}

class _TabsPage extends StatelessWidget {
  const _TabsPage(this.controller, {Key? key}) : super(key: key);
  final WebViewStateController controller;

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WebViewStateController>(
        controller: () => controller,
        repositoryId: StateConst.webview,
        removable: false,
        builder: (controller) {
          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            children: List.generate(
              controller.controllers.length,
              (i) {
                final view = controller.controllers[i];
                final bool selected = view.viewType == controller.viewType;
                return InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: WidgetConstant.border8,
                  ),
                  onTap: () => controller.switchTab(view),
                  borderRadius: WidgetConstant.border8,
                  child: Card(
                    margin: WidgetConstant.padding5,
                    child: ClipRRect(
                      borderRadius: WidgetConstant.border8,
                      child: Stack(
                        children: [
                          IgnorePointer(
                            child: APPNativeView(controller: view.controller),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: WidgetConstant.padding5,
                              decoration: BoxDecoration(
                                  color: context.colors.primaryContainer,
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  )),
                              child: Row(
                                children: [
                                  CircleAPPImageView(
                                    view.tab.value.image,
                                    radius: 15,
                                    onProgress: (c) => const Icon(
                                        Icons.travel_explore_rounded,
                                        color: Colors.red),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OneLineTextWidget(
                                          view.tab.value.viewName,
                                          style: context.textTheme.labelLarge,
                                        ),
                                        if (view.tab.value.title != null)
                                          OneLineTextWidget(
                                              view.tab.value.title ?? "",
                                              style:
                                                  context.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  if (selected) WidgetConstant.check
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.colors.surface.opacity5),
                              child: IconButton(
                                  onPressed: () {
                                    controller.removeTab(view);
                                  },
                                  icon: const Icon(Icons.close)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

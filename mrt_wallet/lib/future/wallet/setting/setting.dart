import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';

class AppSettingView extends StatefulWidget {
  const AppSettingView({super.key});

  @override
  State<AppSettingView> createState() => _AppSettingViewState();
}

class _AppSettingViewState extends State<AppSettingView> {
  void toggleBrightness() {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    wallet.toggleBrightness();
    setState(() {});
  }

  void changeColor(Color color) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    wallet.changeColor(color);
    setState(() {});
    context.showAlert("color_changed".tr);
  }

  static const List<Color> _defaultColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final setting = PageRouter.networkSettings(wallet.network);
    return ScaffolPageView(
      appBar: AppBar(
        title: Text("wallet_preferences".tr),
      ),
      child: ConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (setting != null)
                AppListTile(
                  leading: const Icon(Icons.settings),
                  title: Text("network_settings".tr),
                  subtitle: Text(wallet.network.coinParam.token.name),
                  onTap: () {
                    context.to(setting);
                  },
                ),
              AppListTile(
                leading: const Icon(Icons.delete),
                title: Text("erase_wallet".tr),
                subtitle: Text("clear_wallet_data".tr),
                onTap: () {
                  context.to(PageRouter.eraswWallet);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.password),
                title: Text("wallet_password".tr),
                subtitle: Text("change_password".tr),
                onTap: () {
                  context.to(PageRouter.changePassword);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.security),
                title: Text("security".tr),
                subtitle: Text("export_security_phrase".tr),
                onTap: () {
                  context.to(PageRouter.exportSeed);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.key),
                title: Text("private_key".tr),
                subtitle: Text("import_private_key".tr),
                onTap: () {
                  context.to(PageRouter.importAccount);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.key),
                title: Text("imported_key".tr),
                subtitle: Text("manage_imported_key".tr),
                onTap: () {
                  context.to(PageRouter.manageImportedKey,
                      argruments: wallet.network);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.backup),
                title: Text("backup".tr),
                subtitle: Text("backup_wallet".tr),
                onTap: () {
                  context.to(PageRouter.backupWallet,
                      argruments: wallet.network);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.settings),
                title: Text("wallet_settings".tr),
                subtitle: Text("wallet_settings_desc".tr),
                onTap: () {
                  context.to(PageRouter.updateSetting).then((value) {
                    setState(() {});
                  });
                },
              ),
              const Divider(),
              AppListTile(
                leading: const Icon(Icons.currency_bitcoin),
                title: AppDropDownBottom(
                  items: {
                    for (final i in Currency.values)
                      i: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: context.textTheme.labelLarge,
                            text: i.name.toUpperCase(),
                            children: [
                              TextSpan(
                                  text: " (${i.currencyName})",
                                  style: context.textTheme.bodyMedium)
                            ]),
                      )
                  },
                  label: "toggle_currency".tr,
                  value: wallet.appSetting.currency,
                  onChanged: wallet.changeCurrency,
                  isExpanded: true,
                ),
              ),
              AppListTile(
                onTap: toggleBrightness,
                leading: const Icon(Icons.dark_mode),
                trailing: Switch(
                  value: ThemeController.appTheme.brightness == Brightness.dark,
                  onChanged: (value) => toggleBrightness(),
                ),
                title: Text("dark_mode".tr),
                subtitle: Text("adjust_app_brightness".tr),
              ),
              AppListTile(
                onTap: () {
                  context.openSliverDialog(
                      (ctx) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PageTitleSubtitle(
                                  title: null,
                                  body: Text("select_color_from_blow".tr)),
                              WidgetConstant.height20,
                              Wrap(
                                children: List.generate(_defaultColors.length,
                                    (index) {
                                  return InkWell(
                                    onTap: () {
                                      context.pop(null);
                                      changeColor(_defaultColors[index]);
                                    },
                                    child: Padding(
                                      padding: WidgetConstant.padding10,
                                      child: Icon(
                                        Icons.color_lens,
                                        color: _defaultColors[index],
                                        size: APPConst.double40,
                                      ),
                                    ),
                                  );
                                }),
                              )
                            ],
                          ),
                      "primary_color_palette".tr);
                },
                leading: const Icon(Icons.color_lens),
                title: Text("primary_color_palette".tr),
                subtitle: Text("define_primary_of_app".tr),
              ),
              const Divider(),
              AppListTile(
                title: Text("about_mrt_wallet".tr),
                leading: const Icon(Icons.info),
                subtitle: Text("essence_of_mrt_wallet".tr),
                onTap: () {
                  wallet.eraseAll();
                  // context.openSliverDialog(
                  //     (ctx) => const AbountWalletView(), APPConst.name);
                },
              ),
              WidgetConstant.height20,
            ],
          ),
        ),
      ),
    );
  }
}

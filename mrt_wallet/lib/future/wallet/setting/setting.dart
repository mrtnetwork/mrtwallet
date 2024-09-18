import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/theme/theme.dart';
import 'package:mrt_wallet/future/wallet/start/pages/about.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

import 'color_selector.dart';

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

  void changeColor(Color? color) {
    if (color == null) return;
    final wallet = context.watch<WalletProvider>(StateConst.main);
    wallet.changeColor(color);
    setState(() {});
    context.showAlert("color_changed".tr);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final setting = PageRouter.networkSettings(wallet.wallet.network);
    return ScaffolPageView(
      appBar: AppBar(
        title: Text("wallet_preferences".tr),
      ),
      child: SingleChildScrollView(
        child: ConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          child: Column(
            children: [
              if (setting != null)
                AppListTile(
                  leading: const Icon(Icons.settings),
                  title: Text("network_settings".tr),
                  subtitle: Text(wallet.wallet.network.coinParam.token.name),
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
                      argruments: wallet.wallet.network);
                },
              ),
              AppListTile(
                leading: const Icon(Icons.backup),
                title: Text("backup".tr),
                subtitle: Text("backup_wallet".tr),
                onTap: () {
                  context.to(PageRouter.backupWallet,
                      argruments: wallet.wallet.network);
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
                leading: ThemeController.appTheme.brightness == Brightness.dark
                    ? const Icon(Icons.dark_mode)
                    : const Icon(Icons.light_mode),
                trailing: Switch(
                  value: ThemeController.appTheme.brightness == Brightness.dark,
                  onChanged: (value) => toggleBrightness(),
                ),
                title: Text("dark_mode".tr),
                subtitle: Text("adjust_app_brightness".tr),
              ),
              AppListTile(
                onTap: () {
                  context
                      .openSliverDialog<Color>(
                          (ctx) => const ColorSelectorModal(),
                          "primary_color_palette".tr)
                      .then(changeColor);
                },
                leading: const Icon(Icons.color_lens),
                title: Text("primary_color_palette".tr),
                subtitle: Text("define_primary_of_app".tr),
              ),
              if (wallet.appSetting.supportBarcodeScanner)
                AppListTile(
                  onTap: () {
                    context.to(PageRouter.barcodeScanner);
                  },
                  leading: const Icon(Icons.qr_code),
                  title: Text("qr_code_scanner".tr),
                  subtitle: Text("retrive_barcode_data".tr),
                ),
              const Divider(),
              AppListTile(
                title: Text("about_mrt_wallet".tr),
                leading: const Icon(Icons.info),
                subtitle: Text("essence_of_mrt_wallet".tr),
                onTap: () {
                  context.openSliverDialog(
                      (ctx) => const AbountWalletView(), APPConst.name);
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

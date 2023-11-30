import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/app/material.dart';

class AppSettingView extends StatefulWidget {
  const AppSettingView({super.key});

  @override
  State<AppSettingView> createState() => _AppSettingViewState();
}

class _AppSettingViewState extends State<AppSettingView> {
  void toggleBrightness() {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    wallet.toggleBrightness();
    setState(() {});
  }

  void changeColor(Color color) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
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
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    return ScaffolPageView(
      appBar: AppBar(
        title: Text("wallet_preferences".tr),
      ),
      child: Column(
        children: [
          AppListTile(
            leading: const Icon(Icons.delete),
            title: Text("erase_wallet".tr),
            subtitle: Text("clear_wallet_data".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.eraswWallet);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.password),
            title: Text("wallet_password".tr),
            subtitle: Text("change_password".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.changePassword);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.security),
            title: Text("security".tr),
            subtitle: Text("export_security_phrase".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.exportSeed);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.key),
            title: Text("private_key".tr),
            subtitle: Text("import_private_key".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.importAccount,
                  argruments: wallet.network);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.backup),
            title: Text("backup".tr),
            subtitle: Text("backup_wallet".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.backupWallet,
                  argruments: wallet.network);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.security),
            title: Text("automatic_loc".tr),
            subtitle: Text(wallet.setting.lockTime.viewName.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.updateSetting).then((value) {
                setState(() {});
              });
            },
          ),
          InkWell(
            onTap: toggleBrightness,
            child: AppListTile(
              leading: const Icon(Icons.dark_mode),
              trailing: Switch(
                value: AppMaterialController.appTheme.brightness ==
                    Brightness.dark,
                onChanged: (value) => toggleBrightness(),
              ),
              title: Text("dark_mode".tr),
            ),
          ),
          InkWell(
            onTap: () {
              context.openSliverDialog(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: null, body: Text("select_color_from_blow".tr)),
                      WidgetConstant.height20,
                      Wrap(
                        children: List.generate(_defaultColors.length, (index) {
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
                                size: AppGlobalConst.double40,
                              ),
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                  "primary_color_palette".tr);
            },
            child: AppListTile(
              leading: const Icon(Icons.color_lens),
              trailing: const Icon(Icons.arrow_forward),
              title: Text("primary_color_palette".tr),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class ManageImportedKeysView extends StatelessWidget {
  const ManageImportedKeysView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppNetworkImpl network = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (p0, p1) {
          return _ImportAccount(password: p1, network: network);
        },
        title: "imported_key".tr,
        subtitle: PageTitleSubtitle(
            title: "manage_imported_key".tr,
            body: Text("manage_key_desc1".tr)));
  }
}

class _ImportAccount extends StatefulWidget {
  const _ImportAccount({required this.password, required this.network});
  final String password;
  final AppNetworkImpl network;
  @override
  State<_ImportAccount> createState() => _ImportAccountState();
}

class _ImportAccountState extends State<_ImportAccount> with SafeState {
  final GlobalKey<AppTextFieldState> textFieldState =
      GlobalKey<AppTextFieldState>(debugLabel: "_ImportAccountState");
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_ImportAccountState_1");
  final GlobalKey<FormState> form =
      GlobalKey(debugLabel: "_ImportAccountState_2");
  final Set<EncryptedCustomKey> importedKeys = {};
  void getAccounts() async {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final result = await wallet.getImportedAccounts(widget.password);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      if (result.result.isEmpty) {
        progressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithTextView(
              text: "no_imported_key_found".tr, icon: Icons.hourglass_empty),
        );
      } else {
        importedKeys.addAll(result.result);
        progressKey.success();
      }
    }
  }

  void removeKey(EncryptedCustomKey key) async {
    progressKey.progressText("deleting_key".tr);
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final result = await wallet.removeImportedKey(key, widget.password);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
      return;
    }
    importedKeys.clear();
    progressKey.progressText("retrieving_imported_keys_wait".tr);
    getAccounts();
  }

  bool inited = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!inited) {
      inited = true;
      getAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialWidget:
          ProgressWithTextView(text: "retrieving_imported_keys_wait".tr),
      initialStatus: StreamWidgetStatus.progress,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => UnfocusableChild(
        child: ConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  PageTitleSubtitle(
                      title: "manage_imported_key".tr,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("manage_key_desc1".tr),
                          WidgetConstant.height8,
                          Text("manage_key_desc2".tr)
                        ],
                      )),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "inventory_keys".tr,
                        style: context.textTheme.titleMedium),
                    TextSpan(
                        text: " (${"publick_key".tr}) ",
                        style: context.textTheme.bodySmall)
                  ])),
                  WidgetConstant.height8,
                  ...List.generate(importedKeys.length, (index) {
                    final EncryptedCustomKey key =
                        importedKeys.elementAt(index);
                    return ContainerWithBorder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (key.name != null)
                            Text(key.name ?? "",
                                style: context.textTheme.labelLarge),
                          Text(key.publicKey),
                          Text(
                              "imported_at"
                                  .tr
                                  .replaceOne(key.created.toDateAndTime()),
                              style: context.textTheme.bodySmall),
                          WidgetConstant.height8,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FilledButton.icon(
                                  onPressed: () {
                                    context
                                        .openSliverDialog<bool>(
                                      (p0) => DialogTextView(
                                          buttomWidget: DialogDoubleButtonView(
                                            firstButtonLabel: "remove".tr,
                                            secoundButtonLabel: "cancel".tr,
                                          ),
                                          widget: Column(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("manage_key_desc1".tr),
                                                  WidgetConstant.height8,
                                                  Text("manage_key_desc2".tr)
                                                ],
                                              )
                                            ],
                                          )),
                                      "remove_account".tr,
                                    )
                                        .then((value) {
                                      if (value == true && context.mounted) {
                                        removeKey(key);
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.delete,
                                      color: context.colors.errorContainer),
                                  label: Text("remove".tr)),
                              WidgetConstant.width8,
                              FilledButton.icon(
                                  onPressed: () {
                                    context.to(PagePathConst.exportPrivateKey,
                                        argruments: (key, widget.password));
                                  },
                                  icon: const Icon(Icons.share),
                                  label: Text("export".tr))
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

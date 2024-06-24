import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class AccountPrivteKeyView extends StatelessWidget {
  const AccountPrivteKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    CryptoAccountAddress? account;
    EncryptedCustomKey? customKey;
    String? password;
    final args = context.getDynamicArgs();
    if (args is CryptoAccountAddress) {
      account = args;
    } else {
      args as (EncryptedCustomKey, String);
      customKey = args.$1;
      password = args.$2;
    }

    return PasswordCheckerView(
        accsess: WalletAccsessType.extendedKey,
        account: account,
        password: password,
        customKey: customKey,
        onAccsess: (p0, p1) {
          return _AccountPrivateKeyView(
              keys: p0.whereType<AccessPrivateKeyResponse>().toList(),
              password: p1,
              account: account,
              network: wallet.network,
              customKey: customKey);
        },
        title: "export_private_key".tr,
        subtitle: PageTitleSubtitle(
            title: "private_key".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("export_private_key_desc".tr),
                WidgetConstant.height8,
                Text("enter_wallet_password_to_continue".tr),
              ],
            )));
  }
}

class _AccountPrivateKeyView extends StatefulWidget {
  const _AccountPrivateKeyView({
    required this.keys,
    required this.password,
    required this.account,
    required this.network,
    required this.customKey,
  });
  final List<AccessPrivateKeyResponse> keys;
  final String password;
  final CryptoAccountAddress? account;
  final EncryptedCustomKey? customKey;
  final AppNetworkImpl network;
  @override
  State<_AccountPrivateKeyView> createState() => _AccountPrivateKeyViewState();
}

class _AccountPrivateKeyViewState extends State<_AccountPrivateKeyView>
    with SafeState, SecureState {
  late AccessPrivateKeyResponse key = widget.keys.first;
  bool get hasMultipleKey => widget.keys.length > 1;
  Bip32Base get account => key.account;
  String get privateKey => key.privateKey;
  CryptoCoins get coin => key.coin;
  String? get keyName => widget.customKey?.name;
  String? get wif => key.wif;
  bool _showPrivateKey = false;

  void onChangeKey(AccessPrivateKeyResponse? changeKey) {
    if (key == changeKey || changeKey == null) return;
    key = changeKey;
    setState(() {});
  }

  void onChangeShowPrivateKey() {
    _showPrivateKey = !_showPrivateKey;
    setState(() {});
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.paddingHorizontal20,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PageTitleSubtitle(
                title: "private_key".tr,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("export_private_key_desc".tr)],
                )),
            if (hasMultipleKey) ...[
              Text("private_keys".tr, style: context.textTheme.titleMedium),
              Text("switch_between_keys".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                onChanged: onChangeKey,
                items: {for (final i in widget.keys) i: Text(i.keyName.tr)},
                label: "key_name".tr,
                value: key,
              ),
              WidgetConstant.height20,
            ],
            if (widget.account != null && !hasMultipleKey) ...[
              Text("address_details".tr, style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                child: CopyTextWithBarcode(
                    dataToCopy: widget.account!.address.toAddress,
                    widget: AddressDetailsView(address: widget.account!),
                    barcodeTitle: "address_sharing".tr),
              ),
              WidgetConstant.height20,
            ],
            if (keyName != null) ...[
              Text("key_name".tr, style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(child: Text(keyName ?? "")),
              WidgetConstant.height20,
            ],
            AnimatedSwitcher(
              duration: AppGlobalConst.animationDuraion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                key: UniqueKey(),
                children: [
                  Text("private_key".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: AppGlobalConst.animationDuraion,
                        child: Container(
                          foregroundDecoration: _showPrivateKey
                              ? null
                              : BoxDecoration(
                                  color: context.colors.secondary,
                                  borderRadius: WidgetConstant.border8,
                                ),
                          child: ContainerWithBorder(
                              child: CopyTextWithBarcode(
                            secureBarcode: true,
                            barcodeWidget: ContainerWithBorder(
                                child: CopyTextIcon(
                                    dataToCopy: privateKey,
                                    widget: ObscureTextView(privateKey,
                                        maxLine: 3))),
                            underBarcodeWidget: ErrorTextContainer(
                                margin: WidgetConstant.paddingVertical10,
                                error: "image_store_alert_keys".tr),
                            dataToCopy: privateKey,
                            barcodeTitle: "private_key".tr,
                            widget: SelectableText(privateKey),
                          )),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: AppGlobalConst.animationDuraion,
                          child: SizedBox(
                            key: ValueKey(_showPrivateKey),
                            child: _showPrivateKey
                                ? WidgetConstant.sizedBox
                                : FilledButton.icon(
                                    onPressed: onChangeShowPrivateKey,
                                    icon: const Icon(Icons.remove_red_eye),
                                    label: Text("show_private_key".tr)),
                          ),
                        ),
                      )
                    ],
                  ),
                  WidgetConstant.height20,
                  Text("extended_private_key".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: AppGlobalConst.animationDuraion,
                        child: Container(
                          foregroundDecoration: _showPrivateKey
                              ? null
                              : BoxDecoration(
                                  color: context.colors.secondary,
                                  borderRadius: WidgetConstant.border8,
                                ),
                          child: ContainerWithBorder(
                              child: CopyTextWithBarcode(
                            secureBarcode: true,
                            barcodeWidget: ContainerWithBorder(
                                child: CopyTextIcon(
                                    dataToCopy: account.privateKey.toExtended,
                                    widget: ObscureTextView(
                                        account.privateKey.toExtended,
                                        maxLine: 5))),
                            underBarcodeWidget: ErrorTextContainer(
                                margin: WidgetConstant.paddingVertical10,
                                error: "image_store_alert_keys".tr),
                            dataToCopy: account.privateKey.toExtended,
                            barcodeTitle: "extended_private_key".tr,
                            widget:
                                SelectableText(account.privateKey.toExtended),
                          )),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: AppGlobalConst.animationDuraion,
                          child: SizedBox(
                            key: ValueKey(_showPrivateKey),
                            child: _showPrivateKey
                                ? WidgetConstant.sizedBox
                                : FilledButton.icon(
                                    onPressed: onChangeShowPrivateKey,
                                    icon: const Icon(Icons.remove_red_eye),
                                    label: Text("show_private_key".tr)),
                          ),
                        ),
                      )
                    ],
                  ),
                  if (wif != null) ...[
                    WidgetConstant.height20,
                    Text("wif".tr, style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: AppGlobalConst.animationDuraion,
                          child: Container(
                            foregroundDecoration: _showPrivateKey
                                ? null
                                : BoxDecoration(
                                    color: context.colors.secondary,
                                    borderRadius: WidgetConstant.border8,
                                  ),
                            child: ContainerWithBorder(
                                child: CopyTextWithBarcode(
                              secureBarcode: true,
                              barcodeWidget: ContainerWithBorder(
                                  child: CopyTextIcon(
                                      dataToCopy: wif!,
                                      widget:
                                          ObscureTextView(wif!, maxLine: 3))),
                              underBarcodeWidget: ErrorTextContainer(
                                  margin: WidgetConstant.paddingVertical10,
                                  error: "image_store_alert_keys".tr),
                              dataToCopy: wif!,
                              barcodeTitle: "private_key".tr,
                              widget: SelectableText(wif!),
                            )),
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: AppGlobalConst.animationDuraion,
                            child: SizedBox(
                              key: ValueKey(_showPrivateKey),
                              child: _showPrivateKey
                                  ? WidgetConstant.sizedBox
                                  : FilledButton.icon(
                                      onPressed: onChangeShowPrivateKey,
                                      icon: const Icon(Icons.remove_red_eye),
                                      label: Text("show_private_key".tr)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: WidgetConstant.paddingVertical20,
                  child: FilledButton.icon(
                      label: Text("create_backup".tr),
                      onPressed: () {
                        context.openSliverDialog<SecretWalletEncoding>(
                            (ctx) => SecureBackupView(
                                  password: widget.password,
                                  data: privateKey,
                                  descriptions: [
                                    WidgetConstant.height8,
                                    Text("about_web3_defination_desc4".tr),
                                  ],
                                ),
                            "backup_private_key".tr);
                      },
                      icon: const Icon(Icons.backup)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
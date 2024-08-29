import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/secure_state/secure_state.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/security/security.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class AccountPrivteKeyView extends StatelessWidget {
  const AccountPrivteKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    ChainAccount? account;
    EncryptedCustomKey? customKey;
    String? password;
    final args = context.getDynamicArgs();
    if (args is ChainAccount) {
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
        onAccsess: (crendential, password, network) {
          return _AccountPrivateKeyView(
              keys: crendential.whereType<PrivateKeyData>().toList(),
              password: password,
              account: account,
              network: wallet.wallet.network,
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
  final List<PrivateKeyData> keys;
  final String password;
  final ChainAccount? account;
  final EncryptedCustomKey? customKey;
  final WalletNetwork network;
  @override
  State<_AccountPrivateKeyView> createState() => _AccountPrivateKeyViewState();
}

class _AccountPrivateKeyViewState extends State<_AccountPrivateKeyView>
    with SafeState, SecureState {
  late PrivateKeyData key = widget.keys.first;
  bool get hasMultipleKey => widget.keys.length > 1;
  String? keyInNetwork;
  String get privateKey => keyInNetwork ?? key.privateKey;

  String? get extendedKey => key.extendedKey;
  CryptoCoins get coin => key.coin;
  String? get keyName => widget.customKey?.name;
  String? get wif => key.wif;
  bool _showPrivateKey = false;
  EllipticCurveTypes get type => key.coin.conf.type;

  void onChangeKey(PrivateKeyData? changeKey) {
    if (key == changeKey || changeKey == null) return;
    key = changeKey;
    init();
    setState(() {});
  }

  void onChangeShowPrivateKey() {
    _showPrivateKey = !_showPrivateKey;
    setState(() {});
  }

  void init() {
    if (widget.network.type == NetworkType.xrpl) {
      keyInNetwork = MethodUtils.nullOnException(
          () => RippleUtils.toRipplePrivateKey(privateKey, coin));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
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
                    widget: AddressDetailsView(
                      address: widget.account!,
                    ),
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
              duration: APPConst.animationDuraion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                key: UniqueKey(),
                children: [
                  Text("private_key".tr, style: context.textTheme.titleMedium),
                  Text(type.name.camelCase),
                  WidgetConstant.height8,
                  Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: APPConst.animationDuraion,
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
                                    isSensitive: true,
                                    dataToCopy: privateKey,
                                    widget: ObscureTextView(privateKey,
                                        maxLine: 3))),
                            underBarcodeWidget: ErrorTextContainer(
                                margin: WidgetConstant.paddingVertical10,
                                error: "image_store_alert_keys".tr),
                            dataToCopy: privateKey,
                            barcodeTitle: "private_key".tr,
                            buttons: [
                              IconButton(
                                  onPressed: () {
                                    context.openSliverDialog(
                                        (ctx) => GenerateBackupView(
                                            password: widget.password,
                                            data: privateKey,
                                            type: MrtBackupTypes.privatekey),
                                        "backup_private_key".tr);
                                  },
                                  icon: const Icon(Icons.backup)),
                            ],
                            widget: SelectableText(privateKey),
                          )),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: APPConst.animationDuraion,
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
                  if (extendedKey != null) ...[
                    WidgetConstant.height20,
                    Text("extended_private_key".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: APPConst.animationDuraion,
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
                              buttons: [
                                IconButton(
                                    onPressed: () {
                                      context.openSliverDialog<
                                              SecretWalletEncoding>(
                                          (ctx) => GenerateBackupView(
                                                password: widget.password,
                                                data: extendedKey!,
                                                type:
                                                    MrtBackupTypes.extendedKey,
                                              ),
                                          "backup_extended_key".tr);
                                    },
                                    icon: const Icon(Icons.backup)),
                              ],
                              barcodeWidget: ContainerWithBorder(
                                  child: CopyTextIcon(
                                      isSensitive: true,
                                      dataToCopy: extendedKey!,
                                      widget: ObscureTextView(extendedKey!,
                                          maxLine: 5))),
                              underBarcodeWidget: ErrorTextContainer(
                                  margin: WidgetConstant.paddingVertical10,
                                  error: "image_store_alert_keys".tr),
                              dataToCopy: extendedKey!,
                              barcodeTitle: "extended_private_key".tr,
                              widget: SelectableText(extendedKey!),
                            )),
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: APPConst.animationDuraion,
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
                  if (wif != null) ...[
                    WidgetConstant.height20,
                    Text("wif".tr, style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: APPConst.animationDuraion,
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
                              buttons: [
                                IconButton(
                                    onPressed: () {
                                      context.openSliverDialog<
                                              SecretWalletEncoding>(
                                          (ctx) => GenerateBackupView(
                                                password: widget.password,
                                                data: wif!,
                                                type: MrtBackupTypes.wif,
                                              ),
                                          "backup_wif".tr);
                                    },
                                    icon: const Icon(Icons.backup)),
                              ],
                              barcodeWidget: ContainerWithBorder(
                                  child: CopyTextIcon(
                                      dataToCopy: wif!,
                                      isSensitive: true,
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
                            duration: APPConst.animationDuraion,
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
            WidgetConstant.height20,
          ],
        ),
      ),
    );
  }
}

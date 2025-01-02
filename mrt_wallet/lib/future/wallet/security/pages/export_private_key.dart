import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:mrt_wallet/future/secure_state/secure_state.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/security/security.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
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
        importedKey: customKey,
        onAccsess: (crendential, password, network) {
          return _AccountPrivateKeyView(
              keys: crendential.whereType<CryptoPrivateKeyData>().toList(),
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
  final List<CryptoPrivateKeyData> keys;
  final String password;
  final ChainAccount? account;
  final EncryptedCustomKey? customKey;
  final WalletNetwork network;
  @override
  State<_AccountPrivateKeyView> createState() => _AccountPrivateKeyViewState();
}

class _AccountPrivateKeyViewState extends State<_AccountPrivateKeyView>
    with SafeState<_AccountPrivateKeyView>, SecureState {
  List<PrivateKeysView> keys = [];
  late PrivateKeysView key;
  bool hasMultipleKey = false;
  String? get keyName => widget.customKey?.name;
  bool showKeys = false;

  void onChangeKey(PrivateKeysView? changeKey) {
    if (key == changeKey || changeKey == null) return;
    key = changeKey;
    init();
    updateState();
  }

  void onChangeShowPrivateKey() {
    showKeys = !showKeys;
    updateState();
  }

  PrivateKeysView toNetworkKeyFormat(PrivateKeysView key) {
    switch (widget.network.type) {
      case NetworkType.xrpl:
        return key.copyWith(
            privateKey: MethodUtils.nullOnException(() =>
                RippleUtils.toRipplePrivateKey(key.privateKey, key.curve)));
      default:
        return key;
    }
  }

  void init() {
    keys = widget.keys.map((e) => toNetworkKeyFormat(e.toViewKey)).toList();
    key = keys.first;
    hasMultipleKey = keys.length > 1;
  }

  @override
  void onInitOnce() {
    init();
    super.onInitOnce();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          sliver: SliverToBoxAdapter(
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
                      items: {for (final i in keys) i: Text(i.keyName.tr)},
                      label: "key_name".tr,
                      value: key),
                  WidgetConstant.height20,
                ],
                if (widget.account != null && !hasMultipleKey) ...[
                  Text("address_details".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: CopyTextWithBarcode(
                        dataToCopy: widget.account!.address.toAddress,
                        widget: AddressDetailsView(
                            address: widget.account!,
                            color: context.onPrimaryContainer),
                        barcodeTitle: "address_sharing".tr),
                  ),
                  WidgetConstant.height20,
                ],
                if (keyName != null) ...[
                  Text("key_name".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: Text(keyName ?? "",
                          style: context.onPrimaryTextTheme.bodyMedium)),
                  WidgetConstant.height20,
                ],
                AnimatedSwitcher(
                  duration: APPConst.animationDuraion,
                  child: _KeysView(
                      privateKey: key, state: this, key: ValueKey(key)),
                ),
                WidgetConstant.height20
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KeysView extends StatelessWidget {
  final PrivateKeysView privateKey;
  const _KeysView({required this.privateKey, required this.state, super.key});
  final _AccountPrivateKeyViewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HiddenKeyView(
            title: "private_key".tr,
            subtitle: privateKey.curve.name.camelCase,
            keyData: privateKey.privateKey,
            showKey: state.showKeys,
            onTapBackup: () {
              context.openSliverDialog(
                  (ctx) => GenerateBackupView(
                      password: state.widget.password,
                      data: privateKey.privateKey,
                      type: MrtBackupTypes.privatekey),
                  "backup_private_key".tr);
            },
            onTapShowKey: state.onChangeShowPrivateKey),
        if (privateKey.extendKey != null) ...[
          WidgetConstant.height20,
          _HiddenKeyView(
              title: "extended_private_key".tr,
              keyData: privateKey.extendKey!,
              showKey: state.showKeys,
              onTapBackup: () {
                context.openSliverDialog<SecretWalletEncoding>(
                    (ctx) => GenerateBackupView(
                          password: state.widget.password,
                          data: privateKey.extendKey!,
                          type: MrtBackupTypes.extendedKey,
                        ),
                    "backup_extended_key".tr);
              },
              onTapShowKey: state.onChangeShowPrivateKey),
        ],
        if (privateKey.wif != null) ...[
          WidgetConstant.height20,
          _HiddenKeyView(
              title: "wif".tr,
              keyData: privateKey.wif!,
              showKey: state.showKeys,
              onTapBackup: () {
                context.openSliverDialog<SecretWalletEncoding>(
                    (ctx) => GenerateBackupView(
                          password: state.widget.password,
                          data: privateKey.wif!,
                          type: MrtBackupTypes.wif,
                        ),
                    "backup_wif".tr);
              },
              onTapShowKey: state.onChangeShowPrivateKey),
        ],
        ConditionalWidget(
          onActive: (context) =>
              _MoneroKeysView(privateKey: privateKey.cast(), state: state),
          enable: privateKey.keyType == CryptoPrivateKeyDataType.monero,
        )
      ],
    );
  }
}

class _MoneroKeysView extends StatelessWidget {
  final MoneroPrivateKeysView privateKey;
  const _MoneroKeysView({required this.privateKey, required this.state});
  final _AccountPrivateKeyViewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        _HiddenKeyView(
            title: "spend_private_key".tr,
            keyData: privateKey.spendPrivateKey,
            showKey: state.showKeys,
            onTapBackup: () {
              context.openSliverDialog(
                  (ctx) => GenerateBackupView(
                      password: state.widget.password,
                      data: privateKey.spendPrivateKey,
                      type: MrtBackupTypes.privatekey),
                  "backup_private_key".tr);
            },
            onTapShowKey: state.onChangeShowPrivateKey),
        WidgetConstant.height20,
        _HiddenKeyView(
            title: "view_private_key".tr,
            keyData: privateKey.viewPrivateKey,
            showKey: state.showKeys,
            onTapBackup: () {
              context.openSliverDialog(
                  (ctx) => GenerateBackupView(
                      password: state.widget.password,
                      data: privateKey.viewPrivateKey,
                      type: MrtBackupTypes.privatekey),
                  "backup_private_key".tr);
            },
            onTapShowKey: state.onChangeShowPrivateKey),
      ],
    );
  }
}

class _HiddenKeyView extends StatelessWidget {
  final String title;
  final String keyData;
  final String? subtitle;
  final bool showKey;
  final DynamicVoid onTapBackup;
  final DynamicVoid onTapShowKey;
  const _HiddenKeyView(
      {required this.title,
      required this.keyData,
      this.subtitle,
      required this.showKey,
      required this.onTapBackup,
      required this.onTapShowKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleMedium),
        if (subtitle != null) Text(subtitle!),
        WidgetConstant.height8,
        Stack(
          children: [
            AnimatedSwitcher(
              duration: APPConst.animationDuraion,
              child: Container(
                foregroundDecoration: showKey
                    ? null
                    : BoxDecoration(
                        color: context.colors.secondary,
                        borderRadius: WidgetConstant.border8),
                child: ContainerWithBorder(
                    child: CopyTextWithBarcode(
                  secureBarcode: true,
                  barcodeWidget: ContainerWithBorder(
                      child: CopyTextIcon(
                          isSensitive: true,
                          dataToCopy: keyData,
                          color: context.onPrimaryContainer,
                          widget: ObscureTextView(keyData,
                              maxLine: 3,
                              style: context.onPrimaryTextTheme.bodyMedium))),
                  underBarcodeWidget: ErrorTextContainer(
                      margin: WidgetConstant.paddingVertical10,
                      error: "image_store_alert_keys".tr),
                  dataToCopy: keyData,
                  barcodeTitle: title,
                  color: context.onPrimaryContainer,
                  buttons: [
                    IconButton(
                        onPressed: () {
                          onTapBackup();
                        },
                        icon: Icon(Icons.backup,
                            color: context.onPrimaryContainer)),
                  ],
                  widget: SelectableText(keyData,
                      style: context.onPrimaryTextTheme.bodyMedium),
                )),
              ),
            ),
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: APPConst.animationDuraion,
                child: SizedBox(
                  key: ValueKey(showKey),
                  child: showKey
                      ? WidgetConstant.sizedBox
                      : FilledButton.icon(
                          onPressed: onTapShowKey,
                          icon: const Icon(Icons.remove_red_eye),
                          label: Text("show_private_key".tr)),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

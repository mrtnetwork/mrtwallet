import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/secure_flag_state.dart';
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
    CryptoAddress? account;
    String? accountId;
    String? password;
    final args = context.getDynamicArgs();
    if (args is CryptoAddress) {
      account = args;
    } else {
      args as List<String>;
      accountId = args.first;
      password = args.last;
    }

    return PasswordCheckerView(
        accsess: WalletAccsessType.privateKey,
        account: account,
        password: password,
        accountId: accountId,
        onAccsess: (p0, p1) {
          return _AccountPrivateKeyView(
              privateKey: p0,
              password: p1,
              account: account,
              network: wallet.network);
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
    required this.privateKey,
    required this.password,
    required this.account,
    required this.network,
  });
  final String privateKey;
  final String password;
  final CryptoAddress? account;
  final AppNetworkImpl network;
  @override
  State<_AccountPrivateKeyView> createState() => _AccountPrivateKeyViewState();
}

class _AccountPrivateKeyViewState extends State<_AccountPrivateKeyView>
    with SafeState, SecureState {
  late Bip44Base account;
  late final String privateKeyHex;
  late CryptoCoins coin = widget.network.coins.first;
  late final List<CryptoCoins> coins = widget.network.coins;
  CryptoCoins? wifCoin;

  late final Map<CryptoCoins, Widget> supportedCoins = {
    for (final i in coins)
      i: RichText(
          text: TextSpan(children: [
        TextSpan(text: i.coinName.camelCase),
        TextSpan(text: " (${i.proposal.specName.toUpperCase()}) ")
      ]))
  };
  late final Map<CryptoCoins, Widget> supportedWif = {
    for (final i in coins)
      if (i.conf.wifNetVer != null)
        i: RichText(
            text: TextSpan(children: [
          TextSpan(text: i.coinName.camelCase),
          TextSpan(text: " (${i.proposal.specName.toUpperCase()}) ")
        ]))
  };
  bool get supportWif => supportedWif.isNotEmpty;
  String? wif;

  bool supported = false;

  void initPrivateKey() {
    try {
      if (widget.account != null) {
        if (coins.contains(widget.account!.coin)) {
          coin = widget.account!.coin;
        }
        privateKeyHex = widget.privateKey;
        account = BlockchainUtils.privateKeyToBip44(privateKeyHex, coin);
      } else {
        final bip32 = Bip32Slip10Ed25519.fromExtendedKey(widget.privateKey);
        privateKeyHex = bip32.privateKey.toHex();
        account = BlockchainUtils.privateKeyToBip44(privateKeyHex, coin);
      }
      if (supportWif) {
        wifCoin = coin.conf.wifNetVer != null ? coin : supportedWif.keys.first;
        wif = _toWif();
      }

      supported = true;
    } catch (e) {
      supported = false;
    }
  }

  String? _toWif() {
    if (wifCoin != null) {
      return WifEncoder.encode(account.privateKey.raw,
          netVer: wifCoin!.conf.wifNetVer!);
    }
    return null;
  }

  bool _showPrivateKey = false;
  void onChangeShowPrivateKey() {
    _showPrivateKey = !_showPrivateKey;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initPrivateKey();
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  void onChangeExtendedType<T>(T? v) {
    if (v == null) return;
    coin = v as CryptoCoins;
    account = BlockchainUtils.privateKeyToBip44(privateKeyHex, coin);
    setState(() {});
  }

  void onChangeWif<T>(T? v) {
    if (v == null) return;
    wifCoin = v as CryptoCoins;
    wif = _toWif();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialWidget:
          ErrorWithTextView(text: "unable_to_accsess_private_key".tr),
      initialStatus:
          !supported ? PageProgressStatus.error : PageProgressStatus.idle,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => ConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetConstant.height20,
              PageTitleSubtitle(
                  title: "private_key".tr,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("export_private_key_desc".tr)],
                  )),
              if (widget.account != null) ...[
                Text("address_details".tr, style: context.textTheme.titleLarge),
                WidgetConstant.height8,
                ContainerWithBorder(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: CopyTextWithBarcode(
                      dataToCopy: widget.account!.address.toAddress,
                      widget: BitcoinAddressDetailsView(
                        account: widget.account as IBitcoinAddress,
                      ),
                      barcodeTitle: "address_sharing".tr),
                ),
                WidgetConstant.height20,
              ],
              Text("private_key".tr, style: context.textTheme.titleLarge),
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
                                dataToCopy: privateKeyHex,
                                widget: ObscureTextView(privateKeyHex,
                                    maxLine: 3))),
                        underBarcodeWidget: ErrorTextContainer(
                            margin: WidgetConstant.paddingVertical10,
                            error: "image_store_alert_keys".tr),
                        dataToCopy: privateKeyHex,
                        barcodeTitle: "private_key".tr,
                        widget: SelectableText(privateKeyHex),
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
                            : FilledButton.tonalIcon(
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
                  style: context.textTheme.titleLarge),
              WidgetConstant.height8,
              AppDropDownBottom(
                items: supportedCoins,
                label: "key_extended_for".tr,
                onChanged: onChangeExtendedType,
                value: coin,
              ),
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
                        widget: SelectableText(account.privateKey.toExtended),
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
                            : FilledButton.tonalIcon(
                                onPressed: onChangeShowPrivateKey,
                                icon: const Icon(Icons.remove_red_eye),
                                label: Text("show_private_key".tr)),
                      ),
                    ),
                  )
                ],
              ),
              if (supportWif) ...[
                WidgetConstant.height20,
                Text("wif".tr, style: context.textTheme.titleLarge),
                WidgetConstant.height8,
                AppDropDownBottom(
                  items: supportedWif,
                  label: "wif_for".tr,
                  onChanged: onChangeWif,
                  value: wifCoin,
                ),
                if (wif != null) ...[
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
                                    widget: ObscureTextView(wif!, maxLine: 3))),
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
                                : FilledButton.tonalIcon(
                                    onPressed: onChangeShowPrivateKey,
                                    icon: const Icon(Icons.remove_red_eye),
                                    label: Text("show_private_key".tr)),
                          ),
                        ),
                      )
                    ],
                  ),
                ]
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: WidgetConstant.paddingVertical20,
                    child: FilledButton.tonalIcon(
                        label: Text("create_backup".tr),
                        onPressed: () {
                          context.openSliverDialog<SecretWalletEncoding>(
                              SecureBackupView(
                                password: widget.password,
                                data: privateKeyHex,
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
      ),
    );
  }
}

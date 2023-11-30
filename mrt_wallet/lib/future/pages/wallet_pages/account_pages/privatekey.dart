
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class AccountPrivteKeyView extends StatelessWidget {
  const AccountPrivteKeyView({super.key});
  @override
  Widget build(BuildContext context) {
    final CryptoAddress account = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.privateKey,
        account: account,
        onAccsess: (p0, p1) {
          return _AccountPrivateKeyView(
              privateKey: p0, password: p1, account: account);
        },
        title: "export_private_key".tr,
        subtitle: PageTitleSubtitle(
            title: "private_key".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("export_private_key_desc".tr)],
            )));
  }
}

class _AccountPrivateKeyView extends StatefulWidget {
  const _AccountPrivateKeyView(
      {required this.privateKey,
      required this.password,
      required this.account});
  final String privateKey;
  final String password;
  final CryptoAddress account;
  @override
  State<_AccountPrivateKeyView> createState() => _AccountPrivateKeyViewState();
}

class _AccountPrivateKeyViewState extends State<_AccountPrivateKeyView> {
  late final Bip44Base account;
  late final String privateKeyHex;

  String? wif;

  bool supported = false;

  void initPrivateKey() {
    try {
      final privateKey = BytesUtils.fromHexString(widget.privateKey);
      final coin = widget.account.coin;
      switch (widget.account.coin.proposal) {
        case BipProposal.bip44:
          account = Bip44.fromPrivateKey(privateKey, coin as Bip44Coins);
          break;
        case BipProposal.bip49:
          account = Bip49.fromPrivateKey(privateKey, coin as Bip49Coins);
          break;
        case BipProposal.bip84:
          account = Bip84.fromPrivateKey(privateKey, coin as Bip84Coins);
          break;
        case BipProposal.bip86:
          account = Bip86.fromPrivateKey(privateKey, coin as Bip86Coins);
          break;
        default:
          supported = false;
          return;
      }
      privateKeyHex = BytesUtils.toHexString(account.privateKey.raw);
      if (coin.conf.wifNetVer != null) {
        wif = WifEncoder.encode(account.privateKey.raw,
            netVer: coin.conf.wifNetVer!);
      }
      supported = true;
    } catch (e) {
      supported = false;
    }
  }

  String? backup;

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
          child: backup != null
              ? Column(
                  key: const ValueKey<bool>(true),
                  children: [
                    PageTitleSubtitle(
                        title: "b_using_web3_secret_defination".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextAndLinkView(
                              text: "about_web3_secret_defination".tr,
                              url: AppLinkConst.aboutWeb3StorageDefination,
                            ),
                            WidgetConstant.height8,
                            Text("about_web3_defination_desc1".tr),
                            WidgetConstant.height8,
                            Text("about_web3_defination_desc4".tr),
                            WidgetConstant.height8,
                            Text("backup_desc2".tr)
                          ],
                        )),
                    WidgetConstant.height8,
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: WidgetConstant.border8,
                      ),
                      child: Padding(
                          padding: WidgetConstant.padding10,
                          child: Text(backup!)),
                    ),
                    Padding(
                      padding: WidgetConstant.paddingVertical20,
                      child: CopyTextIcon(
                          dataToCopy: backup!, size: AppGlobalConst.double40),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitleSubtitle(
                        title: "private_key".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("export_private_key_desc".tr)],
                        )),
                    Text("address_details".tr,
                        style: context.textTheme.titleLarge),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: CopyTextWithBarcode(
                          dataToCopy: widget.account.address.toAddress,
                          widget: BitcoinAddressDetailsView(
                            account: widget.account as IBitcoinAddress,
                          ),
                          barcodeTitle: "address_sharing".tr),
                    ),
                    WidgetConstant.height20,
                    Text("extended_private_key".tr,
                        style: context.textTheme.titleLarge),
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
                    if (wif != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetConstant.height20,
                          Text("wif".tr, style: context.textTheme.titleLarge),
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
                                            widget: ObscureTextView(wif!,
                                                maxLine: 3))),
                                    underBarcodeWidget: ErrorTextContainer(
                                        margin:
                                            WidgetConstant.paddingVertical10,
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
                                            icon: const Icon(
                                                Icons.remove_red_eye),
                                            label: Text("show_private_key".tr)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
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

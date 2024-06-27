import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPConst, QuickContextAccsess, StateConst, Translate;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

import 'package:mrt_wallet/wallet/wallet.dart'
    show
        AccessPubliKeyResponse,
        WalletNetwork,
        Bip32AddressCore,
        ChainHandler,
        ICardanoAddress;

class AccountPublicKeyView extends StatelessWidget {
  final ChainHandler chainAccount;
  const AccountPublicKeyView({
    required this.chainAccount,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return _BipAccountPublicKey(
        account: chainAccount.account.address as Bip32AddressCore,
        network: chainAccount.network);
  }
}

class _BipAccountPublicKey extends StatefulWidget {
  const _BipAccountPublicKey({required this.account, required this.network});
  final Bip32AddressCore account;
  final WalletNetwork network;
  @override
  State<_BipAccountPublicKey> createState() => __BipAccountPublicKeyState();
}

class __BipAccountPublicKeyState extends State<_BipAccountPublicKey> {
  final List<AccessPubliKeyResponse> pubKeys = [];
  bool get hasMultipleKey => pubKeys.length > 1;
  late AccessPubliKeyResponse publicKey;
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  bool inited = false;
  void initPubKey() async {
    if (inited) return;
    inited = true;
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final result = await wallet.getAccountPubKys(account: widget.account);
    if (result.hasResult) {
      pubKeys.addAll(result.result);
      progressKey.success();
      publicKey = pubKeys.first;
    } else {
      progressKey.errorText("cannot_export_public_key".tr, backToIdle: false);
    }
  }

  late final ICardanoAddress? adaLegacyAddress = isAdaLegacy();

  ICardanoAddress? isAdaLegacy() {
    if (widget.account is ICardanoAddress) {
      if ((widget.account as ICardanoAddress).addressDetails.isLegacy) {
        return widget.account as ICardanoAddress;
      }
    }
    return null;
  }

  void onChangeKey(AccessPubliKeyResponse? changeKey) {
    if (publicKey == changeKey || changeKey == null) return;
    publicKey = changeKey;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initPubKey();
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialStatus: StreamWidgetStatus.progress,
      backToIdle: APPConst.oneSecoundDuration,
      initialWidget: ProgressWithTextView(text: "retrieve_the_public".tr),
      child: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "export_public_key".tr,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("export_public_key_desc1".tr)],
              )),
          if (hasMultipleKey) ...[
            Text("public_keys".tr, style: context.textTheme.titleMedium),
            Text("switch_between_keys".tr),
            WidgetConstant.height8,
            AppDropDownBottom(
              onChanged: onChangeKey,
              items: {for (final i in pubKeys) i: Text(i.keyName.tr)},
              label: "key_name".tr,
              value: publicKey,
            ),
            WidgetConstant.height20,
          ],
          if (!hasMultipleKey) ...[
            Text("address_details".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            ContainerWithBorder(
              child: CopyTextWithBarcode(
                  dataToCopy: widget.account.address.toAddress,
                  widget: AddressDetailsView(address: widget.account),
                  barcodeTitle: "address_sharing".tr),
            ),
            WidgetConstant.height20
          ],
          _HDPathDetails(byronLegacy: adaLegacyAddress),
          AnimatedSwitcher(
            duration: APPConst.animationDuraion,
            child: Column(
              key: UniqueKey(),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("extended_public_key".tr,
                    style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                    child: CopyTextWithBarcode(
                  dataToCopy: publicKey.extendedKey,
                  barcodeTitle: "extended_public_key".tr,
                  widget: SelectableText(publicKey.extendedKey),
                )),
                WidgetConstant.height20,
                Text("comperessed_public_key".tr,
                    style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                    child: CopyTextWithBarcode(
                  barcodeTitle: "comperessed_public_key".tr,
                  dataToCopy: publicKey.comprossed,
                  widget: SelectableText(publicKey.comprossed),
                )),
                if (publicKey.uncomprossed != null) ...[
                  WidgetConstant.height20,
                  Text("uncomperessed_public_key".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: CopyTextWithBarcode(
                    dataToCopy: publicKey.uncomprossed!,
                    barcodeTitle: "uncomperessed_public_key".tr,
                    widget: SelectableText(publicKey.uncomprossed!),
                  )),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _HDPathDetails extends StatelessWidget {
  const _HDPathDetails({this.byronLegacy});
  final ICardanoAddress? byronLegacy;

  @override
  Widget build(BuildContext context) {
    if (byronLegacy == null) return WidgetConstant.sizedBox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("hd_path".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          onRemoveIcon:
              CopyTextIcon(dataToCopy: byronLegacy!.addressDetails.hdPath!),
          child:
              Text(byronLegacy!.addressDetails.hdPath!.or("non_derivation".tr)),
        ),
        WidgetConstant.height20,
        Text("hd_path_key".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          onRemoveIcon: CopyTextIcon(
              dataToCopy: byronLegacy!.addressDetails.hdPathKeyHex!),
          child: Text(byronLegacy!.addressDetails.hdPathKeyHex!),
        ),
        WidgetConstant.height20
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

import 'package:mrt_wallet/app/core.dart'
    show APPConst, MethodUtils, StateConst;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';

class AccountPublicKeyView extends StatelessWidget {
  const AccountPublicKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChainAccount account = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.unlock,
        onAccsess: (credential, password, network) =>
            _BipAccountPublicKey(account: account, network: network),
        title: "publick_key".tr,
        subtitle: PageTitleSubtitle(
            title: "unlock_wallet".tr, body: Text("unlock_access_desc".tr)));
  }
}

class _BipAccountPublicKey extends StatefulWidget {
  const _BipAccountPublicKey({required this.account, required this.network});
  final ChainAccount account;
  final WalletNetwork network;
  @override
  State<_BipAccountPublicKey> createState() => __BipAccountPublicKeyState();
}

class __BipAccountPublicKeyState extends State<_BipAccountPublicKey> {
  final List<CryptoPublicKeyData> pubKeys = [];
  bool get hasMultipleKey => pubKeys.length > 1;
  late CryptoPublicKeyData publicKey;
  String? keyInNetwork;
  String? get extendedKey => publicKey.extendedKey;
  String? get uncomprossed => publicKey.uncomprossed;
  String get comprossed => keyInNetwork ?? publicKey.comprossed;
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  bool inited = false;
  void checkNetworkFormat() {
    if (widget.network.type == NetworkType.xrpl) {
      keyInNetwork = MethodUtils.nullOnException(
          () => RippleUtils.toRipplePublicKey(comprossed));
    }
  }

  void initPubKey() async {
    if (inited) return;
    inited = true;

    final wallet = context.watch<WalletProvider>(StateConst.main).wallet;
    final result = await wallet.getAccountPubKys(account: widget.account);
    if (result.hasResult) {
      pubKeys.addAll(result.result);
      progressKey.success();
      publicKey = pubKeys.first;
      checkNetworkFormat();
    } else {
      if (widget.account.multiSigAccount) {
        progressKey.errorText("unavailable_multi_sig_public_key".tr,
            backToIdle: false);
      } else {
        progressKey.errorText(result.error?.tr ?? "cannot_export_public_key".tr,
            backToIdle: false);
      }
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

  void onChangeKey(CryptoPublicKeyData? changeKey) {
    if (publicKey == changeKey || changeKey == null) return;
    publicKey = changeKey;
    checkNetworkFormat();
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
      child: (c) => CustomScrollView(
        shrinkWrap: true,
        slivers: [
          WidgetConstant.sliverPaddingVertial20,
          SliverToBoxAdapter(
            child: ConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitleSubtitle(
                      title: "export_public_key".tr,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text("export_public_key_desc1".tr)],
                      )),
                  if (hasMultipleKey) ...[
                    Text("public_keys".tr,
                        style: context.textTheme.titleMedium),
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
                    Text("address_details".tr,
                        style: context.textTheme.titleMedium),
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
                        if (extendedKey != null) ...[
                          Text("extended_public_key".tr,
                              style: context.textTheme.titleMedium),
                          WidgetConstant.height8,
                          ContainerWithBorder(
                              child: CopyTextWithBarcode(
                            dataToCopy: extendedKey!,
                            barcodeTitle: "extended_public_key".tr,
                            widget: SelectableText(extendedKey!),
                          )),
                          WidgetConstant.height20,
                        ],
                        Text("comperessed_public_key".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                            child: CopyTextWithBarcode(
                          barcodeTitle: "comperessed_public_key".tr,
                          dataToCopy: comprossed,
                          widget: SelectableText(comprossed),
                        )),
                        if (uncomprossed != null) ...[
                          WidgetConstant.height20,
                          Text("uncomperessed_public_key".tr,
                              style: context.textTheme.titleMedium),
                          WidgetConstant.height8,
                          ContainerWithBorder(
                              child: CopyTextWithBarcode(
                            dataToCopy: uncomprossed!,
                            barcodeTitle: "uncomperessed_public_key".tr,
                            widget: SelectableText(uncomprossed!),
                          )),
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          WidgetConstant.sliverPaddingVertial20,
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
          onRemoveIcon: CopyTextIcon(
            isSensitive: false,
            dataToCopy: byronLegacy!.addressDetails.hdPath!,
          ),
          child:
              Text(byronLegacy!.addressDetails.hdPath!.or("non_derivation".tr)),
        ),
        WidgetConstant.height20,
        Text("hd_path_key".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          onRemoveIcon: CopyTextIcon(
              isSensitive: false,
              dataToCopy: byronLegacy!.addressDetails.hdPathKeyHex!),
          child: Text(byronLegacy!.addressDetails.hdPathKeyHex!),
        ),
        WidgetConstant.height20
      ],
    );
  }
}

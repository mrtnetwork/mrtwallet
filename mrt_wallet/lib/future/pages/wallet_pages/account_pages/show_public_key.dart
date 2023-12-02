import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class AccountPublicKeyView extends StatelessWidget {
  final CryptoAddress address;
  const AccountPublicKeyView({required this.address, super.key});
  @override
  Widget build(BuildContext context) {
    return _BipAccountPublicKey(bip: address as Bip32AddressCore);
  }
}

class _BipAccountPublicKey extends StatefulWidget {
  const _BipAccountPublicKey({required this.bip});
  final Bip32AddressCore bip;
  @override
  State<_BipAccountPublicKey> createState() => __BipAccountPublicKeyState();
}

class __BipAccountPublicKeyState extends State<_BipAccountPublicKey> {
  late final Bip44Base account;
  late final String publicKey;
  late final String uncompressedPublicKey;

  bool supported = false;

  void initPubKey() {
    switch (widget.bip.coin.proposal) {
      case BipProposal.bip44:
        account = Bip44.fromPublicKey(
            widget.bip.publicKey, widget.bip.coin as Bip44Coins);
        break;
      case BipProposal.bip49:
        account = Bip49.fromPublicKey(
            widget.bip.publicKey, widget.bip.coin as Bip49Coins);
        break;
      case BipProposal.bip84:
        account = Bip84.fromPublicKey(
            widget.bip.publicKey, widget.bip.coin as Bip84Coins);
        break;
      case BipProposal.bip86:
        account = Bip86.fromPublicKey(
            widget.bip.publicKey, widget.bip.coin as Bip86Coins);
        break;
      default:
        supported = false;
        return;
    }
    publicKey = BytesUtils.toHexString(account.publicKey.compressed);
    uncompressedPublicKey =
        BytesUtils.toHexString(account.publicKey.uncompressed);
    supported = true;
  }

  @override
  void initState() {
    super.initState();
    initPubKey();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "export_public_key".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("export_public_key_desc1".tr)],
            )),
        Text("address_details".tr, style: context.textTheme.titleLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: CopyTextWithBarcode(
              dataToCopy: widget.bip.address.toAddress,
              widget: BitcoinAddressDetailsView(
                account: widget.bip as IBitcoinAddress,
              ),
              barcodeTitle: "address_sharing".tr),
        ),
        WidgetConstant.height20,
        Text("extended_public_key".tr, style: context.textTheme.titleLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CopyTextWithBarcode(
          dataToCopy: account.publicKey.toExtended,
          barcodeTitle: "extended_public_key".tr,
          widget: SelectableText(account.publicKey.toExtended),
        )),
        WidgetConstant.height20,
        Text("comperessed_public_key".tr, style: context.textTheme.titleLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CopyTextWithBarcode(
          barcodeTitle: "comperessed_public_key".tr,
          dataToCopy: publicKey,
          widget: SelectableText(publicKey),
        )),
        WidgetConstant.height20,
        Text("uncomperessed_public_key".tr,
            style: context.textTheme.titleLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CopyTextWithBarcode(
          dataToCopy: uncompressedPublicKey,
          barcodeTitle: "uncomperessed_public_key".tr,
          widget: SelectableText(uncompressedPublicKey),
        )),
      ],
    );
  }
}

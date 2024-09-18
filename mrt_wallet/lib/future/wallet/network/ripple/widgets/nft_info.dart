import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/nfts/networks/ripple.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/router/page_router.dart';

class RippleNFTokenView extends StatelessWidget {
  const RippleNFTokenView({super.key, required this.nft});
  final RippleNFToken nft;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("serial".tr, style: context.textTheme.labelLarge),
        CopyTextIcon(
          isSensitive: false,
          dataToCopy: nft.serial.toString(),
          widget: OneLineTextWidget(nft.serial.toString(),
              style: context.textTheme.bodySmall),
        ),
        WidgetConstant.height8,
        Text("nfts_id".tr, style: context.textTheme.labelLarge),
        CopyTextIcon(
          isSensitive: false,
          dataToCopy: nft.nftokenId,
          widget: OneLineTextWidget(nft.nftokenId,
              style: context.textTheme.bodySmall),
        ),
        if (nft.uri != null) ...[
          WidgetConstant.height8,
          Text("uri".tr, style: context.textTheme.labelLarge),
          CopyTextIcon(
              isSensitive: false,
              dataToCopy: nft.uri!,
              widget: OneLineTextWidget(nft.uri ?? "",
                  style: context.textTheme.bodySmall)),
        ],
        WidgetConstant.divider,
        AppListTile(
          title: const Text("NFTokenBurn"),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            final validator = LiveTransactionForm<RippeBurnTokenForm>(
                validator: RippeBurnTokenForm(offerID: nft.nftokenId));
            context.to(PageRouter.rippleTransaction, argruments: validator);
          },
        ),
        AppListTile(
          title: const Text("NFTokenCreateOffer"),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            final validator = LiveTransactionForm<RippleCreateOfferForm>(
                validator: RippleCreateOfferForm(offerID: nft.nftokenId));
            context.to(PageRouter.rippleTransaction, argruments: validator);
          },
        ),
        AppListTile(
          title: const Text("NFTokenCancelOffer"),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            final validator = LiveTransactionForm<RippleCancelOfferForm>(
                validator: RippleCancelOfferForm(offerID: nft.nftokenId));
            context.to(PageRouter.rippleTransaction, argruments: validator);
          },
        ),
      ],
    );
  }
}

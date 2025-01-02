import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class MoneroTxProofsView extends StatelessWidget {
  final List<MoneroTxDestinationWithProof> proofs;
  final String txId;
  final WalletMoneroNetwork network;
  const MoneroTxProofsView(
      {required this.proofs,
      required this.txId,
      required this.network,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "transaction_proofs".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("monero_tx_proof_desc".tr),
                Text("monero_tx_proof_desc1".tr),
              ],
            )),
        Text("transaction_id".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Text(txId,
                style: context.colors.onPrimaryContainer.bodyMedium(context))),
        WidgetConstant.height20,
        Text("recipients".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ListView.separated(
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics,
            itemBuilder: (context, index) {
              final proof = proofs[index];
              return ContainerWithBorder(
                  backgroundColor: context.colors.onPrimaryContainer,
                  // padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("address".tr,
                          style: context.colors.primaryContainer
                              .titleMedium(context)),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                        child: CopyTextIcon(
                          color: context.colors.onPrimaryContainer,
                          dataToCopy: proof.address.address,
                          widget: Text(proof.address.address,
                              style: context.colors.onPrimaryContainer
                                  .bodyMedium(context)),
                        ),
                      ),
                      WidgetConstant.height20,
                      Text("amount".tr,
                          style: context.colors.primaryContainer
                              .titleMedium(context)),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                        child: CoinPriceView(
                          token: network.token,
                          balance: proof.amount,
                          style: context.colors.onPrimaryContainer
                              .lableLarge(context),
                          symbolColor: context.colors.onPrimaryContainer,
                          showTokenImage: true,
                        ),
                      ),
                      WidgetConstant.height20,
                      Text("proof".tr,
                          style: context.colors.primaryContainer
                              .titleMedium(context)),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                        child: CopyTextIcon(
                          dataToCopy: proof.proof,
                          color: context.colors.onPrimaryContainer,
                          widget: SelectableText(
                            proof.proof,
                            style: context.colors.onPrimaryContainer
                                .bodyMedium(context),
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ));
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: proofs.length)
      ],
    );
  }
}

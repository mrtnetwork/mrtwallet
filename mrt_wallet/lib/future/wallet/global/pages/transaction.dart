import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/transaction/transaction.dart';

class TransactionView extends StatelessWidget {
  final ChainTransaction transaction;
  final Chain chain;
  const TransactionView(
      {required this.transaction, required this.chain, super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      onRemove: () {
        context.openSliverDialog((context) {
          return TransactionModalView(transaction: transaction, chain: chain);
        }, "transaction".tr);
      },
      onRemoveIcon: ConditionalWidgets(
        enable: transaction.type,
        widgets: {
          WalletTransactionType.send: (context) => Icon(
                Icons.upload,
                color: context.onPrimaryContainer,
              ),
          WalletTransactionType.received: (context) => Icon(
                Icons.download,
                color: context.onPrimaryContainer,
              ),
        },
      ),
      child: Row(
        children: [
          Expanded(
            child: CoinPriceView(
              token: chain.network.token,
              balance: transaction.totalOutput,
              showTokenImage: true,
              style: context.textTheme.titleMedium,
              symbolColor: context.onPrimaryContainer,
            ),
          ),
          Text(transaction.time.toDateAndTime(),
              style: context.onPrimaryTextTheme.bodySmall)
        ],
      ),
    );
  }
}

class TransactionModalView extends StatelessWidget {
  final ChainTransaction transaction;
  final Chain chain;
  const TransactionModalView(
      {required this.transaction, required this.chain, super.key});

  @override
  Widget build(BuildContext context) {
    final txUrl = chain.network.getTransactionExplorer(transaction.txId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("total_amount".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: ConditionalWidgets(
            enable: transaction.type,
            widgets: {
              WalletTransactionType.send: (context) => Icon(
                    Icons.upload,
                    color: context.onPrimaryContainer,
                  ),
              WalletTransactionType.received: (context) => Icon(
                    Icons.download,
                    color: context.onPrimaryContainer,
                  ),
            },
          ),
          child: CoinPriceView(
              token: chain.network.token,
              balance: transaction.totalOutput,
              showTokenImage: true,
              style: context.onPrimaryTextTheme.titleMedium,
              symbolColor: context.onPrimaryContainer),
        ),
        WidgetConstant.height20,
        Text("transaction_id".tr,
            style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          enableTap: false,
          onRemoveIcon:
              LaunchBrowserIcon(url: txUrl, color: context.onPrimaryContainer),
          child: CopyableTextWidget(
              text: transaction.txId, color: context.onPrimaryContainer),
        ),
        WidgetConstant.height20,
        Text("outputs".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ListView.separated(
            itemBuilder: (context, index) {
              final output = transaction.outputs[index];
              return TransactionOutputView(
                  output: output, network: chain.network);
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: transaction.outputs.length,
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics),
      ],
    );
  }
}

class TransactionOutputView extends StatelessWidget {
  const TransactionOutputView(
      {required this.output, required this.network, super.key});
  final WalletTransactionOutput output;
  final WalletNetwork network;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
                text: output.address, color: context.primaryContainer),
          ),
          ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CoinPriceView(
              token: output.amount.token ?? network.token,
              balance: output.amount.amount,
              showTokenImage: true,
              style: context.primaryTextTheme.titleMedium,
              symbolColor: context.primaryContainer,
            ),
          ),
          switch (output.runtimeType) {
            const (MoneroTransactionOutput) =>
              _MoneroOutputView(output: output as MoneroTransactionOutput),
            _ => WidgetConstant.sizedBox
          }
        ],
      ),
    );
  }
}

class _MoneroOutputView extends StatelessWidget {
  const _MoneroOutputView({required this.output});
  final MoneroTransactionOutput output;

  @override
  Widget build(BuildContext context) {
    if (output.proof == null) return WidgetConstant.sizedBox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("proof".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          backgroundColor: context.onPrimaryContainer,
          child: CopyableTextWidget(
              text: output.proof!,
              color: context.primaryContainer,
              maxLines: 3),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/ton/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';

class TonWeb3TransactionFieldsView extends StatelessWidget {
  const TonWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3TonRequest<Web3TonSendTransactionResponse, Web3TonSendTransaction>
      request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
        controller: () => Web3TonTransactionRequestController(
            walletProvider: wallet, request: request),
        builder: (context, controller) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("transaction_messages".tr,
                      style: context.textTheme.titleMedium),
                  Text("ton_tx_message_details".tr),
                  WidgetConstant.height20,
                ],
              ),
            ),
            SliverPadding(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverList.separated(
                itemBuilder: (context, index) {
                  final message = controller.form.messages[index];
                  return _TonWeb3TransactionMessageView(
                      message: message, controller: controller);
                },
                itemCount: controller.form.messages.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
                separatorBuilder: (context, index) {
                  return WidgetConstant.divider;
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  TransactionAmountView(
                      title: "total_transaction_const".tr,
                      amount: controller.total,
                      token: controller.network.token),
                  WidgetConstant.height20,
                  Text("transaction_fees".tr,
                      style: context.textTheme.titleMedium),
                  Text("ton_transaction_fee_desc".tr),
                  WidgetConstant.height8,
                  TonTransactionFeeView(controller),
                  InsufficientBalanceErrorView(
                      verticalMargin: WidgetConstant.paddingVertical10,
                      balance: controller.remindAmount,
                      token: controller.network.token),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical40,
                          onPressed: () {
                            controller.sendTransaction();
                          },
                          child: controller.isExcute
                              ? Text("send_transaction".tr)
                              : Text("sign_transaction".tr))
                    ],
                  )
                ],
              ),
            )
          ];
        },
        request: request);
  }
}

class _TonWeb3TransactionMessageView extends StatelessWidget {
  const _TonWeb3TransactionMessageView(
      {required this.message, required this.controller});
  final TonWeb3TransactionMessageInfo message;
  final Web3TonTransactionRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
            address: message.destination, title: "destination".tr),
        WidgetConstant.height20,
        TransactionAmountView(
            title: "message_amount".tr,
            subtitle: "amount_of_ton_message".tr,
            amount: message.amount,
            token: controller.network.token),
        if (message.payload != null)
          switch (message.payload!.type) {
            TonWeb3TransactionPayloadType.jetton =>
              _JettonPayloadView(message.payload!.cast()),
            TonWeb3TransactionPayloadType.transfer =>
              _JettonPayloadView(message.payload!.cast()),
            _ => _PayloadContentView(payload: message.payload!)
          },
        if (message.initState != null)
          _JettonInitializeStateView(initState: message.initState!)
      ],
    );
  }
}

class _JettonInitializeStateView extends StatelessWidget {
  const _JettonInitializeStateView({required this.initState});
  final String initState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("deploy_contract".tr, style: context.textTheme.titleMedium),
        Text("initialization_state".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: CopyTextIcon(
                dataToCopy: initState,
                color: context.onPrimaryContainer,
                widget: OneLineTextWidget(initState,
                    maxLine: 3, style: context.onPrimaryTextTheme.bodyMedium))),
      ],
    );
  }
}

class _JettonPayloadView extends StatelessWidget {
  const _JettonPayloadView(this.payload);
  final JettonContractTonTransactionPayload payload;

  @override
  Widget build(BuildContext context) {
    final bool isAccountJetton = payload.isAccountJetton ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("jetton_info".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        TokenDetailsView(
          token: payload.token,
          radius: APPConst.circleRadius25,
          showBalance: isAccountJetton,
          onSelect: isAccountJetton ? null : () {},
          enableTap: false,
          onSelectWidget: TappedTooltipView(
              tooltipWidget: ToolTipView(
            message: "unknow_jetton_owner".tr,
            child: Icon(Icons.warning, color: context.colors.tertiary),
          )),
        ),
        if (payload.amount != null) ...[
          WidgetConstant.height20,
          TransactionAmountView(
              title: "amount".tr,
              subtitle: "jetton_transfer_amount".tr,
              amount: payload.amount,
              token: payload.token.token),
        ],
        _PayloadContentView(payload: payload)
      ],
    );
  }
}

class _PayloadContentView extends StatelessWidget {
  const _PayloadContentView({required this.payload});
  final TonWeb3TransactionPayload payload;
  Map<String, dynamic> get content => payload.contentJson;
  bool get isUnknowPayload => payload.type.isUnknown;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("content".tr, style: context.textTheme.labelLarge),
        Text("content_of_payload".tr),
        WidgetConstant.height8,
        APPExpansionListTile(
            trailing: isUnknowPayload
                ? TappedTooltipView(
                    tooltipWidget: ToolTipView(
                    message: 'unknown_payload_desc'.tr,
                    child: Icon(Icons.warning, color: context.colors.tertiary),
                  ))
                : null,
            title: Text(payload.type.name.camelCase,
                style: context.onPrimaryTextTheme.bodyMedium),
            subtitle: isUnknowPayload
                ? Text("payload_deserialize_failed".tr,
                    style: context.onPrimaryTextTheme.bodySmall)
                : null,
            children: List.generate(content.length, (index) {
              final key = content.keys.elementAt(index);
              final value = content[key];
              if (value == null) {
                return WidgetConstant.sizedBox;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(key.camelCase,
                            style: context.onPrimaryTextTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          constraints: null,
                          child: CopyTextIcon(
                            dataToCopy: value.toString(),
                            isSensitive: false,
                            color: context.primaryContainer,
                            widget: SelectableText(value.toString(),
                                style: context.primaryTextTheme.bodyMedium,
                                maxLines: 4,
                                minLines: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            })),
      ],
    );
  }
}

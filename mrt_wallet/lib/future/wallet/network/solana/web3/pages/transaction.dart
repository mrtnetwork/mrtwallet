import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/solana/models/web3_transaction_info.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/solana/src/rpc/models/models/simulate_transaction_response.dart';

class SolanaWeb3TransactionFieldsView extends StatelessWidget {
  const SolanaWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SolanaRequest<List<Map<String, dynamic>>, Web3SolanaSendTransaction>
      request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      showRequestAccount: false,
      controller: () => Web3SolanaTransactionRequestController(
          walletProvider: wallet, request: request),
      builder: (context, controller) {
        final List<SolanaWeb3TransactionInfo> transaction =
            controller.form.transaction;
        return [
          if (controller.isMultipleTransaction) ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("transactions".tr, style: context.textTheme.titleMedium),
                  Text("multiple_transaction_desc".tr),
                  WidgetConstant.height20,
                ],
              ),
            ),
          ],
          SliverPadding(
            padding: controller.isMultipleTransaction
                ? WidgetConstant.padding20
                : EdgeInsets.zero,
            sliver: SliverList.separated(
              separatorBuilder: (context, index) => WidgetConstant.divider,
              itemBuilder: (context, index) {
                final message = transaction[index];
                return _SolanaWeb3MessageView(
                    message: message, controller: controller);
              },
              itemCount: transaction.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                Text("total_transaction_fee".tr,
                    style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                    enableTap: false,
                    child: CoinPriceView(
                      token: controller.network.coinParam.token,
                      balance: controller.form.fee,
                      style: context.onPrimaryTextTheme.titleMedium,
                      symbolColor: context.onPrimaryContainer,
                    )),
                WidgetConstant.height20,
                Text("total_transaction_const".tr,
                    style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  enableTap: false,
                  onRemove: () {},
                  onRemoveWidget: controller.isReady
                      ? Icon(
                          Icons.check_circle,
                          color: context.onPrimaryContainer,
                        )
                      : TappedTooltipView(
                          tooltipWidget: ToolTipView(
                              message: "simulation_are_not_ready".tr,
                              child: Icon(Icons.warning,
                                  color: context.colors.tertiary)),
                        ),
                  child: CoinPriceView(
                      token: controller.network.coinParam.token,
                      balance: controller.total,
                      style: context.onPrimaryTextTheme.titleMedium,
                      symbolColor: context.onPrimaryContainer),
                ),
                if (controller.isSend) ...[
                  WidgetConstant.height20,
                  AppSwitchListTile(
                      value: controller.replaceBlockHash,
                      title: Text("replace_recent_block_hash".tr,
                          style: context.textTheme.titleMedium),
                      subtitle: Text("replace_block_hash_desc".tr),
                      contentPadding: EdgeInsets.zero,
                      onChanged: controller.toggleReplaceBlockHash)
                ],
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                    padding: WidgetConstant.paddingVertical40,
                    child: Text("submit".tr),
                    onPressed: () {
                      controller.confirm((message) async {
                        return context.openSliverDialog(
                            (context) => DialogTextView(
                                buttonWidget: const DialogDoubleButtonView(),
                                text: message),
                            "submit_transaction".tr);
                      });
                    }),
              ],
            ),
          ),
        ];
      },
      request: request,
    );
  }
}

class _SolanaWeb3MessageView extends StatelessWidget {
  const _SolanaWeb3MessageView(
      {required this.message, required this.controller});
  final SolanaWeb3TransactionInfo message;
  final Web3SolanaTransactionRequestController controller;

  @override
  Widget build(BuildContext context) {
    final status = message.status;
    final feeStatus = message.feeStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("account".tr, style: context.textTheme.titleMedium),
        Text("web3_request_account_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: AddressDetailsView(
                address: message.signer, color: context.onPrimaryContainer)),
        WidgetConstant.height20,
        Text("instructions".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: APPExpansionListTile(
          tilePadding: EdgeInsets.zero,
          title: Text("instructions".tr,
              style: context.onPrimaryTextTheme.bodyMedium),
          children: List.generate(message.instructions.length, (index) {
            final instruction = message.instructions[index];
            final isLastIndex = index == message.instructions.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("program_id".tr,
                    style: context.onPrimaryTextTheme.titleMedium),
                Text(instruction.layout.instruction.name,
                    style: context.onPrimaryTextTheme.bodyMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                    backgroundColor: context.onPrimaryContainer,
                    child: CopyTextIcon(
                      dataToCopy: instruction.programAddress.address,
                      color: context.primaryContainer,
                      widget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instruction.layout.instruction.programName,
                            style: context.primaryTextTheme.labelLarge,
                          ),
                          OneLineTextWidget(instruction.programAddress.address,
                              style: context.primaryTextTheme.bodyMedium)
                        ],
                      ),
                    )),
                if (instruction.content != null) ...[
                  WidgetConstant.height20,
                  APPExpansionListTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text("content".tr,
                          style: context.onPrimaryTextTheme.titleMedium),
                      children: [
                        ListView.separated(
                            shrinkWrap: true,
                            physics: WidgetConstant.noScrollPhysics,
                            itemBuilder: (context, index) {
                              final key =
                                  instruction.content!.keys.elementAt(index);
                              final value = instruction.content![key];
                              if (value == null) {
                                return WidgetConstant.sizedBox;
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ContainerWithBorder(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(key.camelCase,
                                            style: context
                                                .onPrimaryTextTheme.labelLarge),
                                        ContainerWithBorder(
                                          backgroundColor:
                                              context.colors.onPrimaryContainer,
                                          constraints: null,
                                          child: CopyTextIcon(
                                            dataToCopy: value.toString(),
                                            isSensitive: false,
                                            color: context.primaryContainer,
                                            widget: SelectableText(
                                                value.toString(),
                                                style: context.primaryTextTheme
                                                    .bodyMedium,
                                                maxLines: 4,
                                                minLines: 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                Divider(color: context.onPrimaryContainer),
                            itemCount: instruction.content!.length)
                      ]),
                ],
                if (!isLastIndex) ...[
                  Divider(color: context.colors.onPrimaryContainer),
                  WidgetConstant.height8,
                ]
              ],
            );
          }),
        )),
        WidgetConstant.height20,
        Text("simulate_transaction".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveWidget: IconButton(
            onPressed: status.canRetry
                ? () {
                    controller.form.simulate(message);
                  }
                : null,
            icon: switch (status) {
              SolanaWeb3SimulationStatus.pending => SizedBox(
                  width: APPConst.double20,
                  height: APPConst.double20,
                  child: CircularProgressIndicator(
                      color: context.colors.onPrimaryContainer),
                ),
              SolanaWeb3SimulationStatus.success =>
                Icon(Icons.check_circle, color: context.onPrimaryContainer),
              SolanaWeb3SimulationStatus.error =>
                Icon(Icons.error, color: context.colors.error),
              SolanaWeb3SimulationStatus.simulateError =>
                Icon(Icons.error, color: context.colors.error),
              SolanaWeb3SimulationStatus.idle => Icon(
                  Icons.refresh,
                  color: context.onPrimaryContainer,
                )
            },
          ),
          enableTap: status.canRetry,
          onRemove: () {
            if (status.canRetry) {
              controller.form.simulate(message);
            }
          },
          child: _SimulateInfo(message),
        ),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveWidget: IconButton(
            onPressed: feeStatus.canRetry
                ? () {
                    controller.form.getFee(message);
                  }
                : null,
            icon: switch (feeStatus) {
              SolanaWeb3FeeStatus.pending => SizedBox(
                  width: APPConst.double20,
                  height: APPConst.double20,
                  child: CircularProgressIndicator(
                      color: context.onPrimaryContainer),
                ),
              SolanaWeb3FeeStatus.success =>
                Icon(Icons.check_circle, color: context.onPrimaryContainer),
              SolanaWeb3FeeStatus.error =>
                Icon(Icons.error, color: context.colors.error),
              SolanaWeb3FeeStatus.idle => Icon(
                  Icons.refresh,
                  color: context.onPrimaryContainer,
                )
            },
          ),
          onRemove: () {
            if (status.canRetry) {
              controller.form.getFee(message);
            }
          },
          child: _FeeInfo(message: message, network: controller.network),
        ),
        if (!message.accountChange.isZero) ...[
          WidgetConstant.height20,
          Text("change_balance".tr, style: context.textTheme.titleMedium),
          Text("solana_change_balance_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemove: controller.isMultipleWithSameOwner ? () {} : null,
            enableTap: false,
            onRemoveWidget: TappedTooltipView(
                tooltipWidget: ToolTipView(
                    message: "solana_change_balance_desc2".tr,
                    child:
                        Icon(Icons.warning, color: context.colors.tertiary))),
            child: CoinPriceView(
                token: controller.network.coinParam.token,
                balance: message.accountChange,
                style: context.onPrimaryTextTheme.titleMedium,
                symbolColor: context.onPrimaryContainer),
          ),
        ]
      ],
    );
  }
}

class _SimulateInfo extends StatelessWidget {
  const _SimulateInfo(this.message);
  final SolanaWeb3TransactionInfo message;
  SimulateTranasctionResponse get simulate => message.simulateInfo;
  @override
  Widget build(BuildContext context) {
    final status = message.status;
    return Theme(
      data: context.theme.copyWith(dividerColor: context.colors.transparent),
      child: APPAnimatedSwitcher(enable: status, widgets: {
        SolanaWeb3SimulationStatus.success: (context) => APPExpansionListTile(
              title: Text("transaction_simulation_success".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
              tilePadding: EdgeInsets.zero,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: List.generate(simulate.logs?.length ?? 0,
                              (index) {
                            final log = simulate.logs![index];
                            return Text(log,
                                style: context.onPrimaryTextTheme.bodyMedium);
                          })),
                    ),
                  ],
                )
              ],
            ),
        SolanaWeb3SimulationStatus.simulateError: (context) =>
            APPExpansionListTile(
              title: Text("transaction_simulation_failed".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
              tilePadding: EdgeInsets.zero,
              subtitle: ToolTipView(
                  message: simulate.err?.toString() ?? "",
                  child: Text(simulate.err?.toString() ?? "",
                      style: context.onPrimaryTextTheme.bodyMedium)),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: List.generate(simulate.logs?.length ?? 0,
                              (index) {
                            final log = simulate.logs![index];
                            return Text(log,
                                style: context.onPrimaryTextTheme.bodyMedium);
                          })),
                    ),
                  ],
                )
              ],
            ),
        SolanaWeb3SimulationStatus.pending: (context) => Text(
            "transaction_simulate_please_wait".tr,
            style: context.onPrimaryTextTheme.bodyMedium),
        SolanaWeb3SimulationStatus.error: (context) => Text(
            "transaction_simulation_failed_retry".tr,
            style: context.onPrimaryTextTheme.bodyMedium),
      }),
    );
  }
}

class _FeeInfo extends StatelessWidget {
  const _FeeInfo({required this.message, required this.network});
  final SolanaWeb3TransactionInfo message;
  final WalletNetwork network;
  @override
  Widget build(BuildContext context) {
    final status = message.feeStatus;
    return Theme(
      data: context.theme.copyWith(dividerColor: context.colors.transparent),
      child: APPAnimatedSwitcher<SolanaWeb3FeeStatus>(
          width: context.mediaQuery.size.width,
          enable: status,
          widgets: {
            SolanaWeb3FeeStatus.success: (context) => CoinPriceView(
                token: network.token,
                balance: message.fee,
                style: context.onPrimaryTextTheme.titleMedium,
                showTokenImage: true,
                symbolColor: context.onPrimaryContainer),
            SolanaWeb3FeeStatus.pending: (context) => Text(
                  "estimating_fee_please_wait".tr,
                  style: context.onPrimaryTextTheme.bodyMedium,
                ),
            SolanaWeb3FeeStatus.error: (context) => Text(
                "fee_estimate_failed".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          }),
    );
  }
}

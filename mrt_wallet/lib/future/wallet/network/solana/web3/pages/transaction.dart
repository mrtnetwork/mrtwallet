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
    return Web3PageRequestControllerView(
      showRequestAccount: false,
      controller: () => Web3SolanaTransactionRequestController(
          walletProvider: wallet, request: request),
      builder: (context, controller) {
        List<SolanaWeb3TransactionInfo> transaction =
            controller.form.transaction;
        return [
          if (controller.isMultipleTransaction) ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("transactions".tr, style: context.textTheme.titleLarge),
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
                  message: message,
                  controller: controller,
                );
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
                    onTapWhenOnRemove: false,
                    child: CoinPriceView(
                      token: controller.network.coinParam.token,
                      balance: controller.form.fee,
                      style: context.textTheme.titleLarge,
                    )),
                WidgetConstant.height20,
                Text("total_transaction_const".tr,
                    style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  onTapWhenOnRemove: false,
                  onRemove: () {},
                  onRemoveWidget: controller.isReady
                      ? Icon(
                          Icons.check_circle,
                          color: context.colors.onPrimaryContainer,
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
                      style: context.textTheme.titleLarge),
                ),
                if (controller.isSend) ...[
                  WidgetConstant.height20,
                  AppSwitchListTile(
                    value: controller.replaceBlockHash,
                    title: Text("replace_recent_block_hash".tr,
                        style: context.textTheme.titleMedium),
                    subtitle: Text("replace_block_hash_desc".tr),
                    contentPadding: EdgeInsets.zero,
                    onChanged: controller.toggleReplaceBlockHash,
                  )
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
      {required this.message, required this.controller, Key? key})
      : super(key: key);
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
        ContainerWithBorder(child: AddressDetailsView(address: message.signer)),
        WidgetConstant.height20,
        Text("instructions".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Theme(
                data: context.theme
                    .copyWith(dividerColor: context.colors.transparent),
                child: ExpansionTile(
                  title: Text("instructions".tr,
                      style: context.colors.onPrimaryContainer
                          .titleMedium(context)),
                  children: List.generate(message.instructions.length, (index) {
                    final instruction = message.instructions[index];
                    bool isLastIndex = index == message.instructions.length - 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("program_id".tr,
                            style: context.colors.onPrimaryContainer
                                .lableLarge(context)),
                        Text(instruction.layout.instruction.name,
                            style: context.colors.onPrimaryContainer
                                .bodyMedium(context)),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                            backgroundColor: context.colors.onPrimaryContainer,
                            child: CopyTextIcon(
                              dataToCopy: instruction.programAddress.address,
                              color: context.colors.primaryContainer,
                              widget: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    instruction.layout.instruction.programName,
                                    style: context.colors.primaryContainer
                                        .lableLarge(context),
                                  ),
                                  Text(
                                    instruction.programAddress.address,
                                    style: context.colors.primaryContainer
                                        .bodyMedium(context),
                                    maxLines: 1,
                                  )
                                ],
                              ),
                            )),
                        WidgetConstant.height20,
                        Text("accounts".tr,
                            style: context.colors.onPrimaryContainer
                                .lableLarge(context)),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                            backgroundColor: context.colors.onPrimaryContainer,
                            child: Column(
                              children: List.generate(
                                  instruction.accounts.length, (index) {
                                final account =
                                    instruction.accounts[index].account;
                                final String status = instruction
                                    .accounts[index].status
                                    .map((e) => e.tr)
                                    .join(", ");
                                return ContainerWithBorder(
                                    child: CopyTextIcon(
                                  dataToCopy: account.publicKey.address,
                                  widget: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.publicKey.address,
                                        style: context.colors.onPrimaryContainer
                                            .bodyMedium(context),
                                      ),
                                      Text(status,
                                          style: context
                                              .colors.onPrimaryContainer
                                              .bodySmall(context))
                                    ],
                                  ),
                                ));
                              }),
                            )),
                        if (instruction.content != null) ...[
                          WidgetConstant.height20,
                          ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              backgroundColor: context.colors.primaryContainer,
                              collapsedBackgroundColor:
                                  context.colors.primaryContainer,
                              title: Text("content".tr,
                                  style: context.colors.onPrimaryContainer
                                      .lableLarge(context)),
                              children: List.generate(
                                  instruction.content!.length, (index) {
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
                                          Text(
                                            key.camelCase,
                                            style: context
                                                .colors.onPrimaryContainer
                                                .lableLarge(context),
                                          ),
                                          ContainerWithBorder(
                                            backgroundColor: context
                                                .colors.onPrimaryContainer,
                                            constraints: null,
                                            child: CopyTextIcon(
                                              dataToCopy: value.toString(),
                                              isSensitive: false,
                                              color: context
                                                  .colors.primaryContainer,
                                              widget: SelectableText(
                                                value.toString(),
                                                style: context
                                                    .colors.primaryContainer
                                                    .bodyMedium(context),
                                                maxLines: 4,
                                                minLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              })),
                        ],
                        if (!isLastIndex) ...[
                          Divider(color: context.colors.onPrimaryContainer),
                          WidgetConstant.height8,
                        ]
                      ],
                    );
                  }),
                ))),
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
              SolanaWeb3SimulationStatus.success => Icon(Icons.check_circle,
                  color: context.colors.onPrimaryContainer),
              SolanaWeb3SimulationStatus.error =>
                Icon(Icons.error, color: context.colors.error),
              SolanaWeb3SimulationStatus.simulateError =>
                Icon(Icons.error, color: context.colors.error),
              SolanaWeb3SimulationStatus.idle => Icon(
                  Icons.refresh,
                  color: context.colors.onPrimaryContainer,
                )
            },
          ),
          onTapWhenOnRemove: status.canRetry,
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
                      color: context.colors.onPrimaryContainer),
                ),
              SolanaWeb3FeeStatus.success => Icon(Icons.check_circle,
                  color: context.colors.onPrimaryContainer),
              SolanaWeb3FeeStatus.error =>
                Icon(Icons.error, color: context.colors.error),
              SolanaWeb3FeeStatus.idle => Icon(
                  Icons.refresh,
                  color: context.colors.onPrimaryContainer,
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
            onTapWhenOnRemove: false,
            onRemoveWidget: TappedTooltipView(
                tooltipWidget: ToolTipView(
                    message: "solana_change_balance_desc2".tr,
                    child:
                        Icon(Icons.warning, color: context.colors.tertiary))),
            child: CoinPriceView(
                token: controller.network.coinParam.token,
                balance: message.accountChange,
                style: context.textTheme.titleLarge),
          ),
        ]
      ],
    );
  }
}

class _SimulateInfo extends StatelessWidget {
  const _SimulateInfo(this.message, {Key? key}) : super(key: key);
  final SolanaWeb3TransactionInfo message;
  SimulateTranasctionResponse get simulate => message.simulateInfo;
  @override
  Widget build(BuildContext context) {
    final status = message.status;
    return Theme(
      data: context.theme.copyWith(dividerColor: context.colors.transparent),
      child: APPAnimatedSwitcher(enable: status, widgets: {
        SolanaWeb3SimulationStatus.success: (context) => ExpansionTile(
              title: Text(
                "transaction_simulation_success".tr,
                style: context.colors.onPrimaryContainer.titleMedium(context),
              ),
              childrenPadding: WidgetConstant.padding20,
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
                                style: context.colors.onPrimaryContainer
                                    .bodyMedium(context));
                          })),
                    ),
                  ],
                )
              ],
            ),
        SolanaWeb3SimulationStatus.simulateError: (context) => ExpansionTile(
              title: Text(
                "transaction_simulation_failed".tr,
                style: context.colors.onPrimaryContainer.titleMedium(context),
              ),
              subtitle: ToolTipView(
                message: simulate.err?.toString() ?? "",
                child: Text(
                  simulate.err?.toString() ?? "",
                  style: context.colors.onPrimaryContainer.bodyMedium(context),
                ),
              ),
              childrenPadding: WidgetConstant.padding20,
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
                                style: context.colors.onPrimaryContainer
                                    .bodyMedium(context));
                          })),
                    ),
                  ],
                )
              ],
            ),
        SolanaWeb3SimulationStatus.pending: (context) => Text(
              "transaction_simulate_please_wait".tr,
              style: context.colors.onPrimaryContainer.bodyMedium(context),
            ),
        SolanaWeb3SimulationStatus.error: (context) => Text(
              "transaction_simulation_failed_retry".tr,
              style: context.colors.onPrimaryContainer.bodyMedium(context),
            ),
      }),
    );
  }
}

class _FeeInfo extends StatelessWidget {
  const _FeeInfo({required this.message, required this.network, Key? key})
      : super(key: key);
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
                  style: context.textTheme.titleLarge,
                  showTokenImage: true,
                ),
            SolanaWeb3FeeStatus.pending: (context) => Text(
                  "estimating_fee_please_wait".tr,
                  style: context.colors.onPrimaryContainer.bodyMedium(context),
                ),
            SolanaWeb3FeeStatus.error: (context) => Text(
                "fee_estimate_failed".tr,
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
          }),
    );
  }
}

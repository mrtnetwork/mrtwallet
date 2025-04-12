import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/pages/pick_token.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/models/transaction_output.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/models/web3.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/cw20.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class CosmosWeb3TransactionFieldsView extends StatelessWidget {
  const CosmosWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3CosmosRequest<Web3CosmosSignTransactionResponse,
      Web3CosmosSignTransaction> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      showRequestAccount: true,
      controller: () => Web3CosmosTransactionRequestController(
          walletProvider: wallet, request: request),
      builder: (context, controller) {
        return [_SingTransctionView(controller.form)];
      },
      request: request,
    );
  }
}

class _SingTransctionView extends StatelessWidget {
  final Web3CosmosSendTransactionForm form;
  const _SingTransctionView(this.form);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("messages".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ListView.separated(
              shrinkWrap: true,
              physics: WidgetConstant.noScrollPhysics,
              itemBuilder: (context, index) {
                final msg = form.messagesInfos[index];
                return APPExpansionListTile(
                  title: Text(msg.typeUrl),
                  children: [
                    ContainerWithBorder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("message_bytes".tr,
                              style: context.onPrimaryTextTheme.titleMedium),
                          WidgetConstant.height8,
                          ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            child: CopyableTextWidget(
                              text: msg.value,
                              color: context.primaryContainer,
                              widget: SelectableText(msg.value,
                                  style: context.primaryTextTheme.bodyMedium,
                                  maxLines: 3,
                                  minLines: 1),
                            ),
                          ),
                          if (msg.content != null) ...[
                            WidgetConstant.height20,
                            Text("content".tr,
                                style: context.onPrimaryTextTheme.titleMedium),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                                onRemove: () {
                                  context.openDialogPage(
                                    "message_content".tr,
                                    child: (context) => APPTextView(
                                        text: msg.content!,
                                        title: "message_content".tr),
                                  );
                                },
                                onRemoveIcon: Icon(Icons.code,
                                    color: context.primaryContainer),
                                backgroundColor: context.onPrimaryContainer,
                                child: SelectableText(msg.content!,
                                    style: context.primaryTextTheme.bodyMedium,
                                    maxLines: 3,
                                    minLines: 1)),
                          ],
                        ],
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (context, index) => WidgetConstant.divider,
              itemCount: form.messagesInfos.length),
          ConditionalWidget(
              enable: form.showSimulate,
              onActive: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height20,
                        Text("simulate_transaction".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ConditionalWidget(
                            enable: form.status != StreamWidgetStatus.idle,
                            onDeactive: (context) {
                              return _SimulateView(form.simulateContent!);
                            },
                            onActive: (context) => ContainerWithBorder(
                                  onRemove: () {},
                                  enableTap: false,
                                  onTapError: () {
                                    form.simulateTx();
                                  },
                                  onRemoveIcon: ButtonProgress(
                                    key: form.simulateProgressKey,
                                    initialStatus: form.status,
                                    child: (context) => Icon(Icons.check_circle,
                                        color: context.onPrimaryContainer),
                                    onError: (context, result) {
                                      return IconButton(
                                          onPressed: () {
                                            form.simulateTx();
                                          },
                                          icon: Icon(Icons.error,
                                              color: context.colors.error));
                                    },
                                  ),
                                  child:
                                      APPAnimatedSwitcher<StreamWidgetStatus>(
                                    enable: form.status,
                                    widgets: {
                                      StreamWidgetStatus.progress: (context) =>
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    "transaction_simulate_please_wait"
                                                        .tr,
                                                    style: context
                                                        .onPrimaryTextTheme
                                                        .bodyMedium),
                                              ),
                                            ],
                                          ),
                                      StreamWidgetStatus.error: (context) =>
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "transaction_simulation_failed"
                                                      .tr,
                                                  style: context
                                                      .onPrimaryTextTheme
                                                      .bodyMedium),
                                              ErrorTextContainer(
                                                error: form.simulateError!,
                                                maxLine: 3,
                                                oTapError: () {
                                                  context.openDialogPage(
                                                      "simulate_content".tr,
                                                      child: (context) => APPTextView(
                                                          text: form
                                                              .simulateError!,
                                                          title:
                                                              "simulate_content"
                                                                  .tr));
                                                },
                                              ),
                                            ],
                                          ),
                                    },
                                  ),
                                )),
                      ])),
          WidgetConstant.height20,
          Text("setup_memo".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              onRemoveIcon: AddOrEditIconWidget(form.hasMemo),
              onRemove: () {
                form.changeMemo((s) async {
                  final result = await context.openSliverBottomSheet<String>(
                    "transaction_memo".tr,
                    child: StringWriterView(
                      defaultValue: s,
                      title: PageTitleSubtitle(
                          title: "setup_memo".tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("memo_desc1".tr),
                              WidgetConstant.height8,
                              Text("empty_desc".tr),
                            ],
                          )),
                      buttonText: "setup_memo".tr,
                      label: "memo".tr,
                    ),
                  );
                  return result;
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: form.hasMemo
                        ? Text(form.memo ?? "",
                            style: context.onPrimaryTextTheme.bodyMedium)
                        : Text("tap_to_add_memo".tr,
                            style: context.onPrimaryTextTheme.bodyMedium),
                  ),
                ],
              )),
          _FeeView(form: form),
        ],
      ),
    );
  }
}

class _FeeView extends StatelessWidget {
  CosmosWeb3TransactionFeeInfo get fee => form.fee;
  final Web3CosmosSendTransactionForm form;
  const _FeeView({required this.form});

  @override
  Widget build(BuildContext context) {
    bool isLocked = form.status.inProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("gas_limit".tr, style: context.textTheme.titleMedium),
        Text("cosmos_gas_limit_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
          onRemove: isLocked
              ? null
              : () {
                  form.changeGasLimit(
                      (gasLimit) => context.openSliverBottomSheet<BigRational>(
                            "gas_limit".tr,
                            child: NumberWriteView(
                                defaultValue: gasLimit,
                                allowDecimal: false,
                                allowSign: false,
                                title: PageTitleSubtitle(
                                    title: "gas_limit".tr,
                                    body: Text("cosmos_gas_limit_desc".tr)),
                                buttonText: "setup_input".tr,
                                label: "gas_limit".tr),
                          ));
                },
          child: Text(form.fee.gasLimit.toString()),
        ),
        WidgetConstant.height20,
        Text("fee_tokens".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ListView.separated(
            physics: WidgetConstant.noScrollPhysics,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final fee = this.fee.fees[index];
              return ContainerWithBorder(
                child: Column(children: [
                  ContainerWithBorder(
                    onRemove: isLocked
                        ? null
                        : () {
                            form.changeFeeToken(
                              token: fee,
                              onTap: (feeTokens, network) {
                                return context.openSliverBottomSheet<CW20Token>(
                                  "fee_token".tr,
                                  centerContent: false,
                                  child: CosmosTransactionPickTokenView(
                                      tokens: feeTokens, network: network),
                                );
                              },
                            );
                          },
                    onRemoveIcon: EditOrRemoveIconWidget(
                        form.hasMultipleFeeToken,
                        color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    child: TokenDetailsWidget(
                        token: fee.token.token,
                        color: context.primaryContainer,
                        radius: APPConst.circleRadius25),
                  ),
                  ContainerWithBorder(
                    backgroundColor: context.onPrimaryContainer,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    onRemove: isLocked
                        ? null
                        : () {
                            form.ChangeFeeAmount(
                              token: fee,
                              onTap: (token, max) {
                                return context.openSliverBottomSheet<BigInt>(
                                  "fee_amount".tr,
                                  child: SetupNetworkAmount(
                                      token: token, max: max, min: BigInt.zero),
                                );
                              },
                            );
                          },
                    child: CoinPriceView(
                        balance: fee.feeAmount,
                        token: fee.token.token,
                        style: context.primaryTextTheme.titleMedium,
                        symbolColor: context.primaryContainer),
                  ),
                ]),
              );
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: fee.fees.length),
        WidgetConstant.height20,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: () {
                  form.signTransaction();
                },
                child: Text("sign_transaction".tr)),
          ],
        )
      ],
    );
  }
}

class _SimulateView extends StatelessWidget {
  final CosmosWeb3SimulateInfos simulate;
  const _SimulateView(this.simulate);

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: Text("transaction_simulation_success".tr,
          style: context.onPrimaryTextTheme.bodyMedium),
      children: [
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("gas_limit".tr,
                    style: context.primaryTextTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  child: Text(simulate.gasUsed.toString(),
                      style: context.onPrimaryTextTheme.bodyMedium),
                ),
                if (simulate.log != null) ...[
                  WidgetConstant.height8,
                  Text("log".tr, style: context.primaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: CopyableTextWidget(
                      text: simulate.log ?? '',
                      color: context.onPrimaryContainer,
                      widget: SelectableText(
                        simulate.log ?? '',
                        minLines: 1,
                        maxLines: 3,
                        style: context.onPrimaryTextTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
                if (simulate.events.isNotEmpty) ...[
                  WidgetConstant.height20,
                  Text("events".tr,
                      style: context.primaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemoveIcon: Icon(
                      Icons.open_in_new,
                      color: context.onPrimaryContainer,
                    ),
                    onRemove: () {
                      context.openSliverDialog(
                          (context) => _EventsView(simulate.events),
                          "events".tr);
                    },
                    child: Text("tap_to_show_events".tr,
                        style: context.onPrimaryTextTheme.bodyMedium),
                  ),
                ],
                if (simulate.messageResponse.isNotEmpty) ...[
                  WidgetConstant.height20,
                  Text("messages_response".tr,
                      style: context.primaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemoveIcon: Icon(
                      Icons.open_in_new,
                      color: context.onPrimaryContainer,
                    ),
                    onRemove: () {
                      context.openSliverDialog(
                          (context) =>
                              _MessageResponseView(simulate.messageResponse),
                          "messages_response".tr);
                    },
                    child: Text("tap_to_show_response".tr,
                        style: context.onPrimaryTextTheme.bodyMedium),
                  ),
                ],
              ],
            ))
      ],
    );
  }
}

class _EventsView extends StatelessWidget {
  final List<CosmosWeb3SimulateEvent> events;
  const _EventsView(this.events);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: WidgetConstant.noScrollPhysics,
        itemBuilder: (context, index) {
          final event = events[index];
          return ContainerWithBorder(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("type".tr, style: context.onPrimaryTextTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CopyableTextWidget(
                    text: event.type,
                    color: context.primaryContainer,
                    widget: SelectableText(event.type,
                        style: context.primaryTextTheme.bodyMedium),
                  ),
                ),
                WidgetConstant.height20,
                Text("key".tr, style: context.onPrimaryTextTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CopyableTextWidget(
                    text: event.key,
                    color: context.primaryContainer,
                    widget: SelectableText(event.key,
                        style: context.primaryTextTheme.bodyMedium),
                  ),
                ),
                WidgetConstant.height20,
                Text("value".tr, style: context.onPrimaryTextTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CopyableTextWidget(
                    text: event.value,
                    color: context.primaryContainer,
                    widget: SelectableText(event.value,
                        style: context.primaryTextTheme.bodyMedium),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return WidgetConstant.divider;
        },
        itemCount: events.length);
  }
}

class _MessageResponseView extends StatelessWidget {
  final List<CosmosWeb3SimulateMessageResponse> messages;
  const _MessageResponseView(this.messages);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: WidgetConstant.noScrollPhysics,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ContainerWithBorder(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("type".tr, style: context.onPrimaryTextTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CopyableTextWidget(
                    text: message.typeUrl,
                    color: context.primaryContainer,
                    widget: SelectableText(
                      message.typeUrl,
                      style: context.primaryTextTheme.bodyMedium,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                ),
                WidgetConstant.height20,
                Text("message_bytes".tr,
                    style: context.onPrimaryTextTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CopyableTextWidget(
                    text: message.response,
                    color: context.primaryContainer,
                    widget: SelectableText(
                      message.response,
                      style: context.primaryTextTheme.bodyMedium,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                ),
                if (message.content != null) ...[
                  WidgetConstant.height20,
                  Text("content".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    backgroundColor: context.onPrimaryContainer,
                    child: CopyableTextWidget(
                      text: message.content!,
                      color: context.primaryContainer,
                      widget: SelectableText(
                        message.content!,
                        style: context.primaryTextTheme.bodyMedium,
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return WidgetConstant.divider;
        },
        itemCount: messages.length);
  }
}

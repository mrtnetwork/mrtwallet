import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/sui/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/wallet/models/networks/sui/models/types.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class SuiWeb3TransactionFieldsView extends StatelessWidget {
  const SuiWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SuiRequest<Map<String, dynamic>, Web3SuiSignOrExecuteTransaction>
      request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      showRequestAccount: true,
      controller: () => Web3SuiTransactionRequestController(
          walletProvider: wallet, request: request),
      builder: (context, controller) {
        return [_TransactionView(form: controller.form)];
      },
      request: request,
    );
  }
}

class _TransactionView extends StatelessWidget {
  const _TransactionView({required this.form});
  final Web3SuiSendTransactionForm form;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("transaction_content".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemove: () {
              context.openDialogPage(
                "transaction_content".tr,
                child: (context) => APPTextView(
                    text: form.transactionContent,
                    title: "transaction_content".tr),
              );
            },
            onRemoveWidget: Icon(Icons.code, color: context.onPrimaryContainer),
            child: Text("content".tr),
          ),
          WidgetConstant.height20,
          if (form.owner != null) ...[
            ReceiptAddressView(
                address: form.owner, title: "transaction_owner".tr),
            WidgetConstant.height20
          ],
          if (form.feePayer != null) ...[
            ReceiptAddressView(
                address: form.feePayer, title: "transaction_fee_payer".tr),
            WidgetConstant.height20
          ],
          Text("simulate_transaction".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemove: () {},
            enableTap: false,
            onTapError: () {
              form.simulateTx();
            },
            onRemoveIcon: ButtonProgress(
              key: form.simulateProgressKey,
              initialStatus: form.status,
              child: (context) =>
                  Icon(Icons.check_circle, color: context.onPrimaryContainer),
              onError: (context, result) {
                return IconButton(
                    onPressed: () {
                      form.simulateTx();
                    },
                    icon: Icon(Icons.error, color: context.colors.error));
              },
            ),
            child: APPAnimatedSwitcher(
              enable: form.vmStatus == null,
              widgets: {
                true: (context) => Row(
                      children: [
                        Expanded(
                          child: Text("transaction_simulate_please_wait".tr,
                              style: context.onPrimaryTextTheme.bodyMedium),
                        ),
                      ],
                    ),
                false: (context) => Row(
                      children: [
                        Expanded(
                          child: Text(form.vmStatus!,
                              style: context.onPrimaryTextTheme.bodyMedium),
                        ),
                        if (form.simulateContent != null)
                          IconButton(
                              onPressed: () {
                                context.openDialogPage(
                                  "simulate_content".tr,
                                  child: (context) => APPTextView(
                                      text: form.simulateContent!,
                                      title: "simulate_content".tr),
                                );
                              },
                              icon: Icon(Icons.code,
                                  color: context.onPrimaryContainer))
                      ],
                    ),
              },
            ),
          ),
          _BalanceChangedView(form.balanceChanged),
          WidgetConstant.height20,
          Text("transaction_fee".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: CoinPriceView(
                  token: form.network.coinParam.token,
                  balance: form.fee,
                  style: context.onPrimaryTextTheme.titleMedium,
                  symbolColor: context.onPrimaryContainer)),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: () {
                    form.sendTransaction(
                      (s) {
                        return context.openSliverDialog<bool>((context) {
                          return DialogTextView(
                              text: s, buttonWidget: DialogDoubleButtonView());
                        }, "send_transaction".tr);
                      },
                    );
                  },
                  child: form.isExecute
                      ? Text("send_transaction".tr)
                      : Text("sign_transaction".tr))
            ],
          )
        ],
      ),
    );
  }
}

class _BalanceChangedView extends StatelessWidget {
  const _BalanceChangedView(this.changedBalance);
  final List<SuiWeb3AccountChangeBalance>? changedBalance;
  @override
  Widget build(BuildContext context) {
    if (changedBalance == null) return WidgetConstant.sizedBox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("balance_changes".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: APPExpansionListTile(
            tilePadding: EdgeInsets.zero,
            title: Text("balance_changes".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
            children: [
              ListView.separated(
                  shrinkWrap: true,
                  physics: WidgetConstant.noScrollPhysics,
                  itemBuilder: (context, index) {
                    final balance = changedBalance![index];
                    return ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("owner".tr,
                                style: context.primaryTextTheme.titleMedium),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                              child: ConditionalWidget(
                                enable: balance.ownerAddres != null,
                                onActive: (context) {
                                  return ReceiptAddressDetailsView(
                                      address: balance.ownerAddres!,
                                      color: context.onPrimaryContainer);
                                },
                                onDeactive: (context) {
                                  return Text(balance.owner,
                                      style: context
                                          .onPrimaryTextTheme.bodyMedium);
                                },
                              ),
                            ),
                            WidgetConstant.height20,
                            Text("amount".tr,
                                style: context.primaryTextTheme.titleMedium),
                            WidgetConstant.height8,
                            ConditionalWidget(
                                enable: balance.token != null,
                                onActive: (context) => ContainerWithBorder(
                                      child: CoinPriceView(
                                        token: balance.token!.token,
                                        balance: balance.amount,
                                        showTokenImage: true,
                                      ),
                                    ),
                                onDeactive: (context) => ContainerWithBorder(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          OneLineTextWidget(balance.coinType,
                                              style: context.onPrimaryTextTheme
                                                  .labelLarge),
                                          Text(balance.amountStr,
                                              style: context.onPrimaryTextTheme
                                                  .bodyMedium)
                                        ]))),
                          ]),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: changedBalance!.length)
            ],
          ),
        ),
      ],
    );
  }
}

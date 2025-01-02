import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/ton/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/ton/transaction/pages/pages/token_list.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:ton_dart/ton_dart.dart';
import 'fee.dart';
import 'message_settings.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class TonTransactionFieldsView extends StatelessWidget {
  const TonTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<TonTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<TonTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<TheOpenNetworkChain>(
        childBulder: (wallet, chain, switchAccount) {
          return MrtViewBuilder<TonTransactionStateController>(
            repositoryId: StateConst.ton,
            controller: () => TonTransactionStateController(
                walletProvider: wallet,
                account: chain,
                network: chain.network,
                address: chain.address,
                apiProvider: chain.client,
                validator: validator),
            builder: (controller) {
              return PageProgress(
                backToIdle: APPConst.oneSecoundDuration,
                key: controller.progressKey,
                child: (c) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ConstraintsBoxView(
                            padding: WidgetConstant.padding20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("account".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  onRemoveIcon: Icon(
                                    Icons.edit,
                                    color: context.onPrimaryContainer,
                                  ),
                                  child: AddressDetailsView(
                                      address: controller.address,
                                      color: context.onPrimaryContainer,
                                      key: ValueKey<ITonAddress?>(
                                          controller.address)),
                                  onRemove: () {
                                    context
                                        .openSliverBottomSheet<ITonAddress>(
                                          "switch_account".tr,
                                          child: SwitchOrSelectAccountView(
                                              account: controller.account,
                                              showMultiSig: true),
                                          minExtent: 0.5,
                                          maxExtend: 0.9,
                                          initialExtend: 0.7,
                                          centerContent: false,
                                        )
                                        .then(switchAccount);
                                  },
                                ),
                                WidgetConstant.height20,
                                _TonTransactionsFields(
                                    controller: controller,
                                    validator: controller.validator),
                                WidgetConstant.height20,
                                Text("transaction_fees".tr,
                                    style: context.textTheme.titleMedium),
                                Text("ton_transaction_fee_desc".tr),
                                WidgetConstant.height8,
                                TonTransactionFeeView(controller),
                                ErrorTextContainer(
                                    error: controller.error,
                                    showErrorIcon: false),
                                InsufficientBalanceErrorView(
                                    verticalMargin:
                                        WidgetConstant.paddingVertical10,
                                    balance: controller.remindAmount,
                                    token: controller.network.token),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: controller.transactionIsReady
                                          ? controller.sendTransaction
                                          : null,
                                      child: Text("send_transaction".tr),
                                    )
                                  ],
                                )
                              ],
                            )),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        title: validator.validator.name.tr);
  }
}

class _TonTransactionsFields extends StatelessWidget {
  const _TonTransactionsFields(
      {required this.validator, required this.controller});
  final LiveTransactionForm<TonTransactionForm> validator;
  final TonTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as TonTransferForm;
      return _TonTransactionTransferFields(
        controller: controller,
        field: field,
      );
    });
  }
}

class _TonTransactionTransferFields extends StatelessWidget {
  const _TonTransactionTransferFields(
      {required this.controller, required this.field});
  final TonTransactionStateController controller;
  final TonTransferForm field;
  @override
  Widget build(BuildContext context) {
    final receivers = field.destination.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("amount_for_each_output".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(receivers, (index) {
            final TonOutputWithBalance receiver =
                field.destination.value[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              onRemoveIcon:
                  Icon(Icons.remove_circle, color: context.onPrimaryContainer),
              validate: receiver.isReady,
              onRemove: () {},
              enableTap: false,
              onRemoveWidget: Column(
                children: [
                  IconButton(
                      onPressed: () {
                        context
                            .openSliverDialog<bool>(
                                (p0) => DialogTextView(
                                      text: "remove_recipient_desc".tr,
                                      buttonWidget:
                                          const DialogDoubleButtonView(),
                                    ),
                                "remove_recipient".tr)
                            .then((remove) {
                          field.onRemoveReceiver(receiver, remove);
                        });
                      },
                      icon: Icon(Icons.remove_circle,
                          color: context.onPrimaryContainer)),
                  WidgetConstant.height8,
                  IconButton(
                      onPressed: () {
                        context
                            .openSliverBottomSheet<bool>(
                                "internal_message_settings".tr,
                                centerContent: true,
                                child:
                                    TonTransactionMessageSettingsView(receiver))
                            .then(field.updateMessage);
                      },
                      icon: Icon(Icons.settings,
                          color: receiver.hasSetting
                              ? context.colors.green
                              : context.onPrimaryContainer)),
                  WidgetConstant.height8,
                  IconButton(
                      onPressed: () {
                        if (receiver.hasToken) {
                          field.setJetton(receiver, null);
                          return;
                        }
                        context
                            .openSliverBottomSheet<TonJettonToken>(
                                child: TonTransactionSelectTokenList(
                                    account: controller.address),
                                "select_token".tr)
                            .then((jetton) {
                          field.setJetton(receiver, jetton);
                        });
                      },
                      icon: Icon(
                        Icons.token,
                        color: receiver.hasToken
                            ? context.colors.green
                            : context.onPrimaryContainer,
                      ))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                        address: receiver.address,
                        color: context.colors.primaryContainer,
                      )),
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                        receiver.hasToken
                            ? "setup_total_amount".tr
                            : "setup_output_amount".tr,
                        initialExtend: 1,
                        child: SetupNetworkAmount(
                          token: field.network.token,
                          max: controller.remindAmount.balance +
                              receiver.balance.balance,
                          min: BigInt.zero,
                          subtitle: PageTitleSubtitle(
                              title: receiver.hasToken
                                  ? "total_amount".tr
                                  : "receiver".tr,
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (receiver.hasToken) ...[
                                    Text("jetton_total_amount_desc".tr),
                                    WidgetConstant.height8,
                                    Text("ton_total_amount_desc_2".tr),
                                    WidgetConstant.height8,
                                  ],
                                  ContainerWithBorder(
                                    onRemove: () {},
                                    enableTap: false,
                                    onRemoveIcon: CopyTextIcon(
                                      dataToCopy: receiver.address.view,
                                      isSensitive: false,
                                    ),
                                    child: OneLineTextWidget(
                                        receiver.address.view),
                                  ),
                                ],
                              )),
                        ),
                      )
                          .then((amount) {
                        field.setBalance(receiver, amount);
                      });
                    },
                    validate: receiver.hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.colors.onPrimaryContainer,
                    child: CoinPriceView(
                        balance: receiver.balance,
                        token: field.network.token,
                        style: context.primaryTextTheme.titleMedium,
                        symbolColor: context.colors.primaryContainer,
                        showTokenImage: true),
                  ),
                  if (receiver.hasToken) ...[
                    Divider(color: context.colors.onPrimaryContainer),
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "setup_jetton_amount".tr,
                          initialExtend: 1,
                          child: SetupNetworkAmount(
                            token: receiver.jetton!.token,
                            max: field.getActiveTokenBalance(receiver),
                            min: BigInt.zero,
                            subtitle: PageTitleSubtitle(
                                title: "receiver".tr,
                                body: OneLineTextWidget(receiver.address.view)),
                          ),
                        )
                            .then((amount) {
                          field.setJettonBalance(receiver, amount);
                        });
                      },
                      validate: receiver.hasTokenAmount,
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.primaryContainer),
                      backgroundColor: context.onPrimaryContainer,
                      child: CoinPriceView(
                          balance: receiver.tokenBalance,
                          token: receiver.jetton!.token,
                          style: context.primaryTextTheme.titleMedium,
                          symbolColor: context.primaryContainer,
                          showTokenImage: true),
                    ),
                    WidgetConstant.height20,
                    Row(
                      children: [
                        Flexible(
                          child: Text("forward_amount".tr,
                              style: context.onPrimaryTextTheme.titleMedium),
                        ),
                        WidgetConstant.width8,
                        TooltipHelper("ton_total_amount_desc_2".tr,
                            iconColor: context.onPrimaryContainer)
                      ],
                    ),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "setup_forward_amount".tr,
                          initialExtend: 1,
                          child: SetupNetworkAmount(
                            token: field.network.token,
                            max: controller.remindAmount.balance +
                                receiver.balance.balance,
                            min: BigInt.zero,
                            subtitle: PageTitleSubtitle(
                                title: "forward_amount".tr,
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ton_forward_amount_desc".tr),
                                    WidgetConstant.height8,
                                    ContainerWithBorder(
                                        onRemove: () {},
                                        enableTap: false,
                                        onRemoveWidget: CopyTextIcon(
                                            isSensitive: false,
                                            dataToCopy: receiver.address.view),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            OneLineTextWidget(
                                                receiver.address.view),
                                          ],
                                        )),
                                  ],
                                )),
                          ),
                        )
                            .then((amount) {
                          field.setForwardBalance(receiver, amount);
                        });
                      },
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.primaryContainer),
                      backgroundColor: context.onPrimaryContainer,
                      child: CoinPriceView(
                        balance: receiver.forwardBalance,
                        token: field.network.token,
                        style: context.primaryTextTheme.titleMedium,
                        symbolColor: context.primaryContainer,
                        showTokenImage: true,
                      ),
                    ),
                    WidgetConstant.height20,
                    Text("query_id".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.colors.onPrimaryContainer,
                      onRemoveIcon: Icon(Icons.edit,
                          color: context.colors.primaryContainer),
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigRational>(
                          "jetton_transfer_fields".tr,
                          child: NumberWriteView(
                            defaultValue: BigRational.zero,
                            allowDecimal: false,
                            customForm: field.queryIdForm,
                            max: TonConst.maxTransferQueryId,
                            allowSign: false,
                            title: PageTitleSubtitle(
                                title: "query_id".tr,
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextAndLinkView(
                                        text: "arbitrary_request_number".tr,
                                        url: LinkConst.reviewJettonQueryId),
                                  ],
                                )),
                            buttonText: "setup_input".tr,
                            label: "query_id".tr,
                          ),
                        )
                            .then(
                          (value) {
                            field.setQueryId(receiver, value);
                          },
                        );
                      },
                      child: Text(receiver.queryId.toString(),
                          style: context.primaryTextTheme.bodyMedium),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
        if (receivers == 0 || controller.hasMultipleMessage)
          ContainerWithBorder(
            validate: field.destination.hasValue,
            onRemove: () {
              context
                  .openSliverBottomSheet<List<ReceiptAddress<TonAddress>>>(
                      "receiver_address".tr,
                      bodyBuilder: (c) =>
                          SelectRecipientAccountView<TonAddress>(
                            account: controller.account,
                            multipleSelect: true,
                            scrollController: c,
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("jetton_destination_address_desc".tr),
                                WidgetConstant.height8,
                                Text("receiver_address_desc".tr),
                              ],
                            ),
                          ),
                      maxExtend: 1,
                      minExtent: 0.8,
                      initialExtend: 0.9)
                  .then(
                (value) {
                  field.setReceiver(
                    address: value,
                    onExists: () {
                      context.showAlert("some_addresses_exist".tr);
                    },
                  );
                },
              );
            },
            onRemoveIcon:
                Icon(Icons.add_box, color: context.onPrimaryContainer),
            child: Text("tap_to_add_new_receipment".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          ),
      ],
    );
  }
}

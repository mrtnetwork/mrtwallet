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
                apiProvider: chain.provider()!,
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
                                    style: context.textTheme.titleLarge),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  onRemoveIcon: const Icon(Icons.edit),
                                  child: AddressDetailsView(
                                      address: controller.address,
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
                                  validator: controller.validator,
                                ),
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
                                      padding: WidgetConstant.paddingVertical20,
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
    final receivers = field.destination.value?.length ?? 0;

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
                field.destination.value![index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              onRemoveIcon: const Icon(Icons.remove_circle),
              validate: receiver.isReady,
              onRemove: () {},
              onTapWhenOnRemove: false,
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
                          field.onRemoveReceiver(
                              receiver.address.networkAddress, remove);
                        });
                      },
                      icon: const Icon(Icons.remove_circle)),
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
                              : null)),
                  WidgetConstant.height8,
                  IconButton(
                      onPressed: () {
                        if (receiver.hasToken) {
                          field.setJetton(
                              receiver.address.networkAddress, null);
                          return;
                        }
                        context
                            .openSliverBottomSheet<TonJettonToken>(
                                child: TonTransactionSelectTokenList(
                                    account: controller.address),
                                "select_token".tr)
                            .then((jetton) {
                          field.setJetton(
                              receiver.address.networkAddress, jetton);
                        });
                      },
                      icon: Icon(
                        Icons.token,
                        color: receiver.hasToken ? context.colors.green : null,
                      ))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.colors.secondary,
                      child: ReceiptAddressDetailsView(
                          address: receiver.address,
                          color: context.colors.onSecondary)),
                  if (receiver.hasToken) ...[
                    WidgetConstant.height8,
                    Text("jetton_amount".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "setup_jetton_amount".tr,
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
                          field.setJettonBalance(
                              receiver.address.networkAddress, amount);
                        });
                      },
                      validate: receiver.hasTokenAmount,
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.colors.onSecondary),
                      backgroundColor: context.colors.secondary,
                      child: CoinPriceView(
                        balance: receiver.tokenBalance,
                        token: receiver.jetton!.token,
                        style: context.textTheme.titleLarge
                            ?.copyWith(color: context.colors.onSecondary),
                        symbolColor: context.colors.onSecondary,
                        showTokenImage: true,
                      ),
                    ),
                    WidgetConstant.height8,
                    Row(
                      children: [
                        Flexible(
                          child: Text("forward_amount".tr,
                              style: context.textTheme.titleMedium),
                        ),
                        WidgetConstant.width8,
                        TooltipHelper(
                          "ton_total_amount_desc_2".tr,
                          iconColor: context.colors.onPrimaryContainer,
                        )
                      ],
                    ),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigInt>(
                          "setup_forward_amount".tr,
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
                                        onTapWhenOnRemove: false,
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
                          field.setForwardBalance(
                              receiver.address.networkAddress, amount);
                        });
                      },
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.colors.onSecondary),
                      backgroundColor: context.colors.secondary,
                      child: CoinPriceView(
                        balance: receiver.forwardBalance,
                        token: field.network.token,
                        style: context.textTheme.titleLarge
                            ?.copyWith(color: context.colors.onSecondary),
                        symbolColor: context.colors.onSecondary,
                        showTokenImage: true,
                      ),
                    ),
                    WidgetConstant.height8,
                    Text("query_id".tr, style: context.textTheme.titleMedium),
                    Text("arbitrary_request_number".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.colors.secondary,
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.colors.onSecondary),
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
                            field.setQueryId(
                                receiver.address.networkAddress, value);
                          },
                        );
                      },
                      child: Text(receiver.queryId.toString(),
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: context.colors.onSecondary)),
                    ),
                  ],
                  WidgetConstant.height8,
                  Row(
                    children: [
                      Flexible(
                          child: Text("total_amount".tr,
                              style: context.textTheme.titleMedium)),
                      if (receiver.hasToken) ...[
                        WidgetConstant.width8,
                        TooltipHelper("jetton_total_amount_desc".tr,
                            iconColor: context.colors.onPrimaryContainer)
                      ]
                    ],
                  ),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                        receiver.hasToken
                            ? "setup_total_amount".tr
                            : "setup_output_amount".tr,
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
                                    onTapWhenOnRemove: false,
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
                        field.setBalance(
                            receiver.address.networkAddress, amount);
                      });
                    },
                    validate: receiver.hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.colors.onSecondary),
                    backgroundColor: context.colors.secondary,
                    child: CoinPriceView(
                      balance: receiver.balance,
                      token: field.network.token,
                      style: context.textTheme.titleLarge
                          ?.copyWith(color: context.colors.onSecondary),
                      symbolColor: context.colors.onSecondary,
                      showTokenImage: true,
                    ),
                  ),
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
                  .openSliverBottomSheet<ReceiptAddress<TonAddress>>(
                      "receiver_address".tr,
                      bodyBuilder: (c) =>
                          SelectRecipientAccountView<TonAddress>(
                            account: controller.account,
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
                      context.showAlert("address_already_exist".tr);
                    },
                  );
                },
              );
            },
            onRemoveIcon: const Icon(Icons.add_box),
            child: Text("tap_to_add_new_receipment".tr),
          ),
      ],
    );
  }
}

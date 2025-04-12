import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class AptosTransactionFieldsView extends StatelessWidget {
  const AptosTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<AptosTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<AptosTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<AptosChain>(
        childBulder: (wallet, chain, switchAccount) {
          return MrtViewBuilder<AptosTransactionStateController>(
            repositoryId: StateConst.solana,
            controller: () => AptosTransactionStateController(
                walletProvider: wallet, account: chain, validator: validator),
            builder: (controller) {
              return PageProgress(
                initialStatus: StreamWidgetStatus.progress,
                initialWidget: ProgressWithTextView(
                    text: "retrieving_network_condition".tr),
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
                                  onRemoveIcon: Icon(Icons.edit,
                                      color: context.onPrimaryContainer),
                                  onRemove: controller.form.enableSwitchAccount
                                      ? () {
                                          context
                                              .openSliverBottomSheet<
                                                  ISolanaAddress>(
                                                "switch_account".tr,
                                                child:
                                                    SwitchOrSelectAccountView(
                                                        account:
                                                            controller.account,
                                                        showMultiSig: true),
                                                centerContent: false,
                                              )
                                              .then(switchAccount);
                                        }
                                      : null,
                                  child: AddressDetailsView(
                                      color: context.onPrimaryContainer,
                                      address: controller.address,
                                      key: ValueKey<IAptosAddress?>(
                                          controller.address)),
                                ),
                                WidgetConstant.height20,
                                _SolanaTransactionFileds(
                                    validator: controller.validator,
                                    controller: controller),
                                AnimatedSize(
                                  duration: APPConst.animationDuraion,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      WidgetConstant.height20,
                                      Text("transaction_fee".tr,
                                          style: context.textTheme.titleMedium),
                                      WidgetConstant.height8,
                                      ContainerWithBorder(
                                          validateText: controller.feeError?.tr,
                                          validate: controller.fee.isSimulate &&
                                              controller.feeError == null,
                                          onRemove: () {},
                                          onTapError: () {
                                            controller.calculateFees();
                                          },
                                          enableTap: false,
                                          onRemoveIcon: ButtonProgress(
                                            key: controller.feeProgressKey,
                                            initialStatus:
                                                StreamWidgetStatus.idle,
                                            child: (context) => Icon(
                                                Icons.circle,
                                                color:
                                                    context.colors.transparent),
                                          ),
                                          child: CoinPriceView(
                                            token: controller
                                                .network.coinParam.token,
                                            balance: controller.fee.totalFee,
                                            style: context
                                                .onPrimaryTextTheme.titleMedium,
                                            symbolColor:
                                                context.onPrimaryContainer,
                                          )),
                                    ],
                                  ),
                                ),
                                WidgetConstant.height20,
                                InsufficientBalanceErrorView(
                                    verticalMargin:
                                        WidgetConstant.paddingVertical10,
                                    balance: controller.remindAmount.$1,
                                    token: controller.remindAmount.$2),
                                ErrorTextContainer(error: controller.error),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FixedElevatedButton(
                                      activePress:
                                          controller.transactionIsReady,
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: () {
                                        controller.sendTransaction(
                                          () {
                                            return context
                                                .openSliverDialog<bool>(
                                                    (context) {
                                              return DialogTextView(
                                                  text: controller
                                                              .feeError !=
                                                          null
                                                      ? "transaction_simulate_failed_desc"
                                                          .tr
                                                      : "transaction_simulate_not_ready_desc"
                                                          .tr,
                                                  buttonWidget:
                                                      DialogDoubleButtonView());
                                            }, "send_transaction".tr);
                                          },
                                        );
                                      },
                                      child: Text("send_transaction".tr),
                                    ),
                                  ],
                                ),
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

class _SolanaTransactionFileds extends StatelessWidget {
  const _SolanaTransactionFileds(
      {required this.validator, required this.controller});
  final LiveTransactionForm<AptosTransactionForm> validator;
  final AptosTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final field = validator.value as AptosTransferForm;
      return _AptosTransferFields(field: field, controller: controller);
    });
  }
}

class _AptosTransferFields extends StatelessWidget {
  const _AptosTransferFields({required this.field, required this.controller});
  final AptosTransferForm field;
  final AptosTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.transactionType.isTokenTransfer)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              TokenDetailsView(
                token: field.token!,
                onSelectWidget: WidgetConstant.sizedBox,
                radius: APPConst.circleRadius25,
                error: field.token!.isFreeze
                    ? "token_balance_frozen_desc".tr
                    : null,
              ),
              WidgetConstant.height20
            ],
          ),
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("amount_for_each_output".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(field.destination.length, (index) {
            final destination = field.destination.value[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              onRemoveWidget: IconButton(
                  onPressed: () {
                    field.removeReceiver(destination);
                  },
                  icon: Icon(Icons.remove_circle,
                      color: context.colors.onPrimaryContainer)),
              validate: destination.isReady,
              validateText: destination.hasAmount ? "invalid_address".tr : null,
              enableTap: false,
              onRemove: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                          address: destination.address,
                          color: context.primaryContainer)),
                  ContainerWithBorder(
                    onRemove: () {
                      final max =
                          field.max(destination, controller.fee.requiredFee);
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        child: SetupNetworkAmount(
                          token: field.transferToken,
                          max: max,
                          subtitle: PageTitleSubtitle(
                              title: "receiver".tr,
                              body: ContainerWithBorder(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OneLineTextWidget(destination.address.view,
                                      style: context.colors.onPrimaryContainer
                                          .bodyMedium(context))
                                ],
                              ))),
                        ),
                      )
                          .then((amount) {
                        field.setupAccountAmount(destination, amount);
                      });
                    },
                    validate: destination.hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinPriceView(
                      balance: destination.balance,
                      token: field.transferToken,
                      style: context.primaryTextTheme.titleMedium,
                      symbolColor: context.primaryContainer,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        _TransferSelectReceiver(field: field, controller: controller)
      ],
    );
  }
}

class _TransferSelectReceiver extends StatelessWidget {
  const _TransferSelectReceiver(
      {required this.field, required this.controller});
  final AptosTransferForm field;
  final AptosTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSize(
        isActive: field.canAddReceiver,
        onActive: (context) => ContainerWithBorder(
            validate: field.destination.isNotEmpty,
            onRemove: () {
              context
                  .openSliverBottomSheet(
                "receiver_address".tr,
                bodyBuilder: (c) => SelectRecipientAccountView<AptosAddress>(
                    account: controller.account,
                    scrollController: c,
                    onFilterAccount: field.filterAccount,
                    multipleSelect: !field.transactionType.isTokenTransfer),
              )
                  .then(
                (value) {
                  if (field.transactionType.isTokenTransfer) {
                    field.onAddSingleRecever(
                        value, (s) => context.showAlert(s));
                  } else {
                    field.onAddRecever(value, (s) => context.showAlert(s));
                  }
                },
              );
            },
            onRemoveIcon: const Icon(Icons.add_box),
            child: Text("tap_to_add_new_receipment".tr)),
        onDeactive: (context) => WidgetConstant.sizedBox);
  }
}

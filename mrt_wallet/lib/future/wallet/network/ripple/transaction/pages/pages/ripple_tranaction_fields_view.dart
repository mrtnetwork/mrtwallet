import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/pages/pages/payment_fields.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/pages/pages/ripple_memo_fee.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/pages/pages/account_set_fields.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/pages/pages/ripple_global_transaction_fields.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'signer_list_fields.dart';

class RippleTransactionFieldsView extends StatelessWidget {
  const RippleTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<RippleTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<RippleTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<RippleChain>(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, switchAccount) => MrtViewBuilder<
              RippleTransactionStateController>(
          repositoryId: StateConst.ripple,
          controller: () => RippleTransactionStateController(
              walletProvider: wallet,
              account: chain,
              network: chain.network,
              apiProvider: chain.provider()!,
              address: chain.address,
              validator: validator),
          builder: (controller) {
            return PageProgress(
              key: controller.progressKey,
              initialStatus: PageProgressStatus.progress,
              backToIdle: APPConst.oneSecoundDuration,
              child: (c) => CustomScrollView(
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
                                address: controller.owner,
                                key: ValueKey<IXRPAddress?>(controller.owner)),
                            onRemove: () {
                              context
                                  .openSliverBottomSheet<IXRPAddress>(
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
                          PageTitleSubtitle(
                              title: validator.validator.name.tr,
                              body: TextAndLinkView(
                                  text: validator
                                      .validator.validatorDescription.tr,
                                  url: validator.validator.helperUri)),
                          _RippleFormFields(
                              validator: controller.validator,
                              account: chain,
                              address: chain.address),
                          RippleMemoAndFeeView(controller: controller),
                          ErrorTextContainer(
                              error: controller.fieldsError?.tr,
                              verticalMargin: WidgetConstant.paddingVertical10),
                          InsufficientBalanceErrorView(
                            verticalMargin: WidgetConstant.paddingVertical10,
                            balance: controller.remindAmount.$1,
                            token: controller.remindAmount.$2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamWidget(
                                key: controller.buttonKey,
                                backToIdle: APPConst.oneSecoundDuration,
                                buttonWidget: FixedElevatedButton(
                                  padding: WidgetConstant.paddingVertical20,
                                  onPressed: () {
                                    controller.sendTr();
                                  },
                                  child: Text("send_transaction".tr),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _RippleFormFields extends StatelessWidget {
  const _RippleFormFields({
    required this.validator,
    required this.address,
    required this.account,
  });
  final LiveTransactionForm<RippleTransactionForm> validator;
  final ChainAccount address;
  final RippleChain account;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final RippleTransactionForm fields = validator.value;
      switch (fields.transactionType) {
        case XRPLTransactionType.accountSet:
          return RippleAccountSetFieldsView(
            account: account,
            address: address,
            validator: fields as RippleAccountSetForm,
          );
        case XRPLTransactionType.payment:
          return RipplePaymentFieldsView(
            account: account,
            address: address,
            validator: fields as RipplePaymentForm,
          );
        case XRPLTransactionType.signerListSet:
          return RippleSetSignerListFieldsView(
            account: account,
            address: address,
            validator: fields as RippleSignerListForm,
          );
        default:
          return Column(
            children: List.generate(fields.fields.length, (index) {
              final field = fields.fields[index];
              final bool isLastIndex = index == fields.fields.length - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fields.fields[index].name.tr,
                      style: context.textTheme.titleMedium),
                  Text(fields.fields[index].subject!.tr),
                  WidgetConstant.height8,
                  RippleGlobalTransactionFieldsView(
                    field: field,
                    account: account,
                    address: address,
                    validator: validator.validator,
                  ),
                  if (!isLastIndex) WidgetConstant.height20,
                ],
              );
            }),
          );
      }
    });
  }
}

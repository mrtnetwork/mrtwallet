import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/fields/payment_fields.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/global/controll_ripple_transaction_account.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/global/ripple_memo_fee.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/controller.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/fields/account_set_fields.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/fields/ripple_global_transaction_fields.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:xrp_dart/xrp_dart.dart';

import 'fields/signer_list_fields.dart';

class RippleTransactionFieldsView extends StatelessWidget {
  const RippleTransactionFieldsView({super.key, this.field});
  final LiveTransactionValidator<RippleTransactionValidator>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionValidator<RippleTransactionValidator> validator =
        field ?? context.getArgruments();
    return ControllerRippleTransactionAccountView(
      title: validator.validator.name.tr,
      childBulder: (wallet, chain, address, switchAccount) => MrtViewBuilder<
              RippleTransactionStateController>(
          controller: () => RippleTransactionStateController(
              walletProvider: wallet,
              account: chain.account,
              network: chain.network as AppXRPNetwork,
              apiProvider: chain.provider(),
              address: address,
              validator: validator),
          builder: (controller) {
            return PageProgress(
              key: controller.progressKey,
              initialStatus: PageProgressStatus.progress,
              backToIdle: AppGlobalConst.oneSecoundDuration,
              child: () => CustomScrollView(
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
                            child: AnimatedSwitcher(
                              duration: AppGlobalConst.animationDuraion,
                              child: AddressDetailsView(
                                  address: controller.owner,
                                  key: ValueKey<IXRPAddress?>(controller.owner),
                                  isSelected: false),
                            ),
                            onRemove: () {
                              context
                                  .openSliverBottomSheet<IXRPAddress>(
                                    "switch_account".tr,
                                    child: SwitchOrSelectAccountView(
                                        account: controller.account),
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
                                  text: validator.validator.subject.tr,
                                  url: validator.validator.helperUri)),
                          _RippleValidatorFields(
                              validator: controller.validator,
                              account: chain.account,
                              address: address),
                          RippleMemoAndFeeView(controller: controller),
                          ErrorTextContainer(
                              error: controller.fieldsError,
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
                                backToIdle: AppGlobalConst.oneSecoundDuration,
                                buttomWidget: FixedElevatedButton(
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

class _RippleValidatorFields extends StatelessWidget {
  const _RippleValidatorFields({
    required this.validator,
    required this.address,
    required this.account,
  });
  final LiveTransactionValidator<RippleTransactionValidator> validator;
  final CryptoAccountAddress address;
  final NetworkAccountCore account;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final RippleTransactionValidator fields = validator.value;
      switch (fields.transactionType) {
        case XRPLTransactionType.accountSet:
          return RippleAccountSetFieldsView(
            account: account,
            address: address,
            validator: fields as RippleAccountSetValidator,
          );
        case XRPLTransactionType.payment:
          return RipplePaymentFieldsView(
            account: account,
            address: address,
            validator: fields as RipplePaymentValidator,
          );
        case XRPLTransactionType.signerListSet:
          return RippleSetSignerListFieldsView(
            account: account,
            address: address,
            validator: fields as RippleSignerListValidator,
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
                  Text(fields.fields[index].subject.tr),
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

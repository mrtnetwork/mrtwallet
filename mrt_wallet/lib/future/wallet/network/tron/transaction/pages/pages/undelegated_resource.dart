import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/resource_v2/forms/undelegated_resource.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronUnDelegatedResourceFieldsView extends StatelessWidget {
  const TronUnDelegatedResourceFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronUnDelegatedResourceV2Form validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("resource_receiver_address".tr,
            style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        AppDropDownBottom<ReceiptAddress<TronAddress>>(
          items: {
            for (final i in validator.resourceAddresses)
              i: Text(i.networkAddress.toString())
          },
          hint: "resource_receiver_address".tr,
          value: validator.destination.value,
          onChanged: (p0) {
            validator.onChangeResource(p0);
          },
        ),
        APPAnimatedSize(
          duration: APPConst.animationDuraion,
          isActive: validator.isLoadingResource,
          onActive: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetConstant.height20,
              ContainerWithBorder(
                  child: ProgressWithTextView(
                      text: "retrieving_resources".tr,
                      style: context.onPrimaryTextTheme.bodyMedium)),
            ],
          ),
          onDeactive: (context) => ConditionalWidgets(
              enable: validator.inLoadingError == null,
              widgets: {
                false: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height20,
                        ContainerWithBorder(
                          validate: false,
                          validateText: validator.inLoadingError?.tr ?? "",
                          errorIcon: Icons.refresh,
                          onTapError: () {
                            validator
                                .onChangeResource(validator.destination.value);
                          },
                        ),
                      ],
                    ),
                true: (context) {
                  if (validator.resourceInf0 == null) {
                    return WidgetConstant.sizedBox;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetConstant.height20,
                      ListView.separated(
                          shrinkWrap: true,
                          physics: WidgetConstant.noScrollPhysics,
                          itemBuilder: (context, index) {
                            final r = validator.resourceInf0!.resources[index];
                            return _ResourceDetailsView(
                              account: account,
                              selected: validator.selectedResource,
                              onChanged: (p0) {
                                validator.onSetResource(
                                  p0,
                                  () {
                                    context.showAlert(
                                        "undelegated_period_time_desc".tr);
                                  },
                                );
                              },
                              resource: r,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              WidgetConstant.sizedBox,
                          itemCount: validator.resourceInf0!.resources.length),
                      if (validator.selectedResource != null) ...[
                        WidgetConstant.height20,
                        TransactionAmountView(
                          amount: validator.balance.value,
                          title: "balance".tr,
                          subtitle: "undelegated_balance_desc".tr,
                          validate: validator.balance.isCompleted,
                          onTap: () {
                            context
                                .openSliverBottomSheet<BigInt>(
                              "undelegated_resource".tr,
                              initialExtend: 1,
                              child: SetupNetworkAmount(
                                token: account.network.coinParam.token,
                                max:
                                    validator.selectedResource!.balance.balance,
                                min: BigInt.zero,
                                subtitle: Text("undelegated_balance_desc".tr),
                              ),
                            )
                                .then((value) {
                              if (value == null) {
                                validator.setValue(validator.balance, null);
                              } else {
                                validator.setValue(
                                    validator.balance,
                                    IntegerBalance(
                                        value,
                                        account
                                            .network.coinParam.token.decimal!));
                              }
                            });
                          },
                          token: account.network.coinParam.token,
                        ),
                      ]
                    ],
                  );
                }
              }),
        ),
      ],
    );
  }
}

typedef _OnChangeResource = void Function(DelegateResourceDetailsCore?);

class _ResourceDetailsView extends StatelessWidget {
  const _ResourceDetailsView(
      {required this.account,
      required this.resource,
      required this.onChanged,
      required this.selected});
  final DelegateResourceDetailsCore resource;
  final TronChain account;
  final _OnChangeResource onChanged;
  final DelegateResourceDetailsCore? selected;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerWithBorder(
            onRemoveWidget: APPCheckBox(
              ignoring: true,
              activePress: resource.canUnDelegated,
              value: selected == resource,
              onChanged: (p0) {},
            ),
            onRemove: () {
              onChanged(resource);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.resource.name.camelCase,
                    style: context.onPrimaryTextTheme.labelLarge),
                CoinPriceView(
                    token: account.network.coinParam.token,
                    balance: resource.balance,
                    style: context.onPrimaryTextTheme.titleMedium,
                    symbolColor: context.onPrimaryContainer),
                if (!resource.canUnDelegated)
                  Text(resource.expire!.toDateAndTime(),
                      style: context.onPrimaryTextTheme.bodySmall)
              ],
            ))
      ],
    );
  }
}

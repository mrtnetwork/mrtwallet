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
          label: "resource_receiver_address".tr,
          value: validator.destination.value,
          onChanged: (p0) {
            validator.onChangeResource(p0);
          },
        ),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: validator.isLoadingResource
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    ContainerWithBorder(
                        child: ProgressWithTextView(
                            text: "retrieving_resources".tr)),
                  ],
                )
              : validator.inLoadingError != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height20,
                        ContainerWithBorder(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            WidgetConstant.errorIcon,
                            Text(validator.inLoadingError?.tr ?? ""),
                            WidgetConstant.height8,
                            FilledButton.icon(
                                onPressed: () {
                                  validator.onChangeResource(
                                      validator.destination.value);
                                },
                                icon: const Icon(Icons.refresh),
                                label: Text("take_another_shot".tr))
                          ],
                        )),
                      ],
                    )
                  : validator.resourceInf0 == null
                      ? WidgetConstant.sizedBox
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetConstant.height20,
                            ContainerWithBorder(
                                child: _ResourceDetailsView(
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
                              resource: validator.resourceInf0!,
                            )),
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
                                    child: SetupNetworkAmount(
                                      token: account.network.coinParam.token,
                                      max: validator
                                          .selectedResource!.balance.balance,
                                      min: BigInt.zero,
                                      subtitle:
                                          Text("undelegated_balance_desc".tr),
                                    ),
                                  )
                                      .then((value) {
                                    if (value == null) {
                                      validator.setValue(
                                          validator.balance, null);
                                    } else {
                                      validator.setValue(
                                          validator.balance,
                                          IntegerBalance(
                                              value,
                                              account.network.coinParam.token
                                                  .decimal!));
                                    }
                                  });
                                },
                                token: account.network.coinParam.token,
                              ),
                            ]
                          ],
                        ),
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
  final DelegatedAccountResourceInfo resource;
  final TronChain account;
  final _OnChangeResource onChanged;
  final DelegateResourceDetailsCore? selected;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerWithBorder(
            onRemove: resource.bandwidth == null
                ? null
                : () {
                    onChanged(resource.bandwidth);
                  },
            onRemoveWidget: IgnorePointer(
              child: Checkbox(
                  value: selected?.resource == ResourceCode.bandWidth,
                  onChanged: (v) {}),
            ),
            backgroundColor: context.colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("bandwidth".tr, style: context.textTheme.labelLarge),
                WidgetConstant.height8,
                if (resource.bandwidth == null)
                  Text("no_bandwidth_resourced".tr)
                else ...[
                  CoinPriceView(
                      token: account.network.coinParam.token,
                      balance: resource.bandwidth!.balance,
                      style: context.textTheme.titleMedium),
                  if (!resource.bandwidth!.canUnDelegated)
                    Text(resource.bandwidth!.expire!.toDateAndTime())
                ],
              ],
            )),
        Divider(color: context.colors.onPrimaryContainer),
        ContainerWithBorder(
            onRemoveWidget: IgnorePointer(
              child: Checkbox(
                  value: selected?.resource == ResourceCode.energy,
                  onChanged: (v) {}),
            ),
            backgroundColor: context.colors.transparent,
            onRemove: resource.energy == null
                ? null
                : () {
                    onChanged(resource.energy);
                  },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("energy".tr, style: context.textTheme.labelLarge),
                WidgetConstant.height8,
                if (resource.energy == null)
                  Text("no_energy_resourced".tr)
                else ...[
                  CoinPriceView(
                      token: account.network.coinParam.token,
                      balance: resource.energy!.balance,
                      style: context.textTheme.titleMedium),
                  if (!resource.energy!.canUnDelegated)
                    Text(resource.energy!.expire!.toDateAndTime())
                ],
              ],
            ))
      ],
    );
  }
}

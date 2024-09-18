import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/select_account_or_contact.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/account/forms/update_account_permission.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronAccountUpdatePermissionFieldsView extends StatelessWidget {
  const TronAccountUpdatePermissionFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronAccountUpdatePermissionForm validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("permissions".tr, style: context.textTheme.titleMedium),
        Text("tron_permission_desc".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          value: validator.permissionId,
          key: UniqueKey(),
          items: {
            for (final i in validator.permissions)
              i.id ?? 0: RichText(
                  text: TextSpan(
                      style: context.textTheme.bodyMedium,
                      text: i.type.name.camelCase,
                      children: [
                    if (i.permissionName != null)
                      TextSpan(
                          text: " (${i.permissionName}) ",
                          style: context.textTheme.bodySmall)
                  ])),
            -1: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.divider,
                Text("new_active_permission".tr)
              ],
            )
          },
          label: "permissions".tr,
          onChanged: (p0) {
            validator.setPermission(
              p0,
              () {
                context.showAlert("tron_permission_validator1".tr);
              },
            );
          },
        ),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: validator.selectedPermission == null
              ? WidgetConstant.sizedBox
              : _EditPermissionView(
                  permission: validator.selectedPermission!,
                  validator: validator,
                  key: ValueKey(validator.selectedPermission),
                  account: account,
                ),
        )
      ],
    );
  }
}

class _EditPermissionView extends StatelessWidget {
  const _EditPermissionView(
      {super.key,
      required this.permission,
      required this.validator,
      required this.account});
  final AccountPermission permission;
  final TronAccountUpdatePermissionForm validator;
  final TronChain account;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("permission_type".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(child: Text(permission.type.name.camelCase)),
        WidgetConstant.height20,
        Text("permission_name".tr, style: context.textTheme.titleMedium),
        Text("input_the_permission_name".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: const Icon(Icons.edit),
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  "update_account_permission".tr,
                  child: StringWriterView(
                    defaultValue: permission.permissionName,
                    title: PageTitleSubtitle(
                        title: "permission_name".tr,
                        body: Text("input_the_permission_name".tr)),
                    buttonText: "setup_input".tr,
                    label: "permission_name".tr,
                  ),
                )
                .then(
                  validator.updatePermissionName,
                );
          },
          child: Text(permission.permissionName ?? "tap_to_input_value".tr),
        ),
        WidgetConstant.height20,
        Text("threshold".tr, style: context.textTheme.titleMedium),
        Text("tron_threshhold_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: NumberTextField(
                label: "threshold".tr,
                onChange: validator.onUpdateTheresHold,
                defaultValue: validator.selectedPermission!.threshold.toInt(),
                max: TronUtils.maxPermissionThreshhold,
                min: 1)),
        if (!permission.isWitnessPermission) ...[
          WidgetConstant.height20,
          Text("operations".tr, style: context.textTheme.titleMedium),
          Text("tron_operations_desc".tr),
          WidgetConstant.height8,
          if (permission.isActivePermission) ...[
            AppSwitchListTile(
              value: validator.allOperationSelected,
              onChanged: (p0) {
                validator.clearOrSelectAll();
              },
              title: Text("choose_all".tr),
            ),
          ],
          ContainerWithBorder(
              child: validator.operations == null
                  ? Text("all_operations".tr)
                  : Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 2.5,
                      spacing: 2.5,
                      children: List.generate(
                          TransactionContractType.values.length,
                          (index) => Chip(
                              deleteIcon: IgnorePointer(
                                child: Checkbox(
                                  value: validator.operations!.contains(
                                      TransactionContractType.values[index]),
                                  onChanged: (value) {},
                                ),
                              ),
                              onDeleted: () {
                                validator.addOrRemoveOperation(
                                  TransactionContractType.values[index],
                                  () {
                                    context.showAlert("operation_disabled".tr);
                                  },
                                );
                              },
                              label: SizedBox(
                                width: 80,
                                child: ToolTipView(
                                  waitDuration:
                                      const Duration(milliseconds: 300),
                                  message: TransactionContractType
                                      .values[index].name,
                                  child: OneLineTextWidget(
                                      TransactionContractType
                                          .values[index].name,
                                      style: context.textTheme.bodySmall),
                                ),
                              ))),
                    )),
        ],
        WidgetConstant.height20,
        Text("tron_permission_key".tr, style: context.textTheme.titleMedium),
        Text("tron_permission_key_desc".tr),
        WidgetConstant.height8,
        ...List.generate(validator.selectedPermission!.keys.length, (index) {
          return ContainerWithBorder(
              onTapWhenOnRemove: false,
              onRemove: () {
                validator
                    .removeSigner(validator.selectedPermission!.keys[index]);
              },
              onRemoveIcon: const Icon(Icons.remove_circle),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("address".tr, style: context.textTheme.labelLarge),
                  OneLineTextWidget(validator
                      .selectedPermission!.keys[index].address
                      .toAddress()),
                  Divider(
                    color: context.colors.onPrimaryContainer,
                  ),
                  Text("weight".tr, style: context.textTheme.labelLarge),
                  NumberTextField(
                      label: "weight".tr,
                      onChange: (p0) {
                        validator.updateKeyThereshHold(
                            validator.selectedPermission!.keys[index], p0);
                      },
                      max: TronUtils.maxPermissionThreshhold,
                      defaultValue: validator
                          .selectedPermission!.keys[index].weight
                          .toInt(),
                      min: 1),
                ],
              ));
        }),
        if (validator.selectedPermission!.keys.length < 5)
          ContainerWithBorder(
            onRemoveIcon: const Icon(Icons.add_box),
            child: Text("tap_to_input_new_signer".tr),
            onRemove: () {
              context
                  .openSliverBottomSheet<ReceiptAddress<TronAddress>>(
                      "update_account_permission".tr,
                      maxExtend: 1,
                      minExtent: 0.8,
                      initialExtend: 0.9,
                      bodyBuilder: (c) =>
                          SelectRecipientAccountView<TronAddress>(
                              account: account,
                              scrollController: c,
                              subtitle: PageTitleSubtitle(
                                  title: "signer".tr,
                                  body: Text("signer_account_address".tr))))
                  .then(
                (value) {
                  validator.addNewSigner(value, () {
                    context.showAlert("signer_already_exist".tr);
                  });
                },
              );
            },
          ),
        ErrorTextContainer(
            error: validator.permissionError?.tr,
            verticalMargin: WidgetConstant.paddingVertical20),
        Padding(
          padding: WidgetConstant.paddingVertical20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton.icon(
                onPressed: validator.savePermission,
                label: Text("Update permission".tr),
                icon: const Icon(Icons.save),
              ),
              if (permission.isActivePermission) ...[
                WidgetConstant.width8,
                FixedElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: Text("remove_permission".tr),
                  onPressed: validator.removePermission,
                )
              ]
            ],
          ),
        )
      ],
    );
  }
}

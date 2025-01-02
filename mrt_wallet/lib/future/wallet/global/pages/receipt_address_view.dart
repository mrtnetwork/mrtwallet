import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class ReceiptAddressView extends StatelessWidget {
  const ReceiptAddressView(
      {this.address,
      this.onTap,
      this.title = "recipient",
      this.errorText,
      super.key,
      this.subtitle,
      this.validate,
      this.onEditIcon,
      this.onEditWidget,
      this.enableTap = true});
  final ReceiptAddress? address;
  final DynamicVoid? onTap;
  final String? title;
  final String? subtitle;
  final bool? validate;
  final Icon? onEditIcon;
  final Widget? onEditWidget;
  final String? errorText;
  final bool enableTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title?.tr ?? "recipient".tr,
              style: context.textTheme.titleMedium),
          if (subtitle != null) LargeTextView([subtitle!], maxLine: 2),
          WidgetConstant.height8,
        ],
        ContainerWithBorder(
            validate: validate ?? (address != null),
            onRemove: onTap,
            enableTap: enableTap,
            onRemoveWidget: onEditWidget,
            onRemoveIcon: address == null
                ? Icon(Icons.add, color: context.onPrimaryContainer)
                : onEditIcon ??
                    Icon(Icons.edit, color: context.onPrimaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                address == null
                    ? Text(
                        "tap_to_choose_address".tr,
                        style: context.onPrimaryTextTheme.bodyMedium,
                      )
                    : Row(
                        children: [
                          Expanded(
                              child: ReceiptAddressDetailsView(
                            address: address!,
                            color: context.onPrimaryContainer,
                          )),
                          CopyTextIcon(
                              dataToCopy: address?.view ?? "",
                              color: context.onPrimaryContainer,
                              isSensitive: false)
                        ],
                      ),
                ErrorTextContainer(
                    error: errorText, padding: WidgetConstant.paddingVertical10)
              ],
            )),
      ],
    );
  }
}

class ReceiptAddressDetailsView extends StatelessWidget {
  const ReceiptAddressDetailsView(
      {required this.address, super.key, this.color});
  final ReceiptAddress address;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.type != null)
          Text(address.type!.tr,
              style: context.textTheme.labelLarge?.copyWith(color: color)),
        if (address.hasContact)
          Text(address.contact!.name,
              style: context.textTheme.labelSmall?.copyWith(color: color))
        else if (address.isAccount)
          AddressDrivationInfo(address.account!.keyIndex, color: color),
        OneLineTextWidget(
          address.view,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';

class ReceiptAddressView extends StatelessWidget {
  const ReceiptAddressView(
      {this.address,
      required this.onTap,
      this.title = "recipient",
      super.key,
      this.subtitle,
      this.validate,
      this.onEditIcon,
      this.onTapWhenOnRemove = true});
  final ReceiptAddress? address;
  final DynamicVoid? onTap;
  final String? title;
  final String? subtitle;
  final bool? validate;
  final Icon? onEditIcon;
  final bool onTapWhenOnRemove;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title?.tr ?? "recipient".tr,
              style: context.textTheme.titleMedium),
          if (subtitle != null) Text(subtitle!),
          WidgetConstant.height8,
        ],
        ContainerWithBorder(
            validate: validate ?? (address != null),
            onRemove: onTap,
            onTapWhenOnRemove: onTapWhenOnRemove,
            onRemoveIcon: address == null
                ? const Icon(Icons.add)
                : onEditIcon ?? const Icon(Icons.edit),
            child: address == null
                ? Text("tap_to_choose_address".tr)
                : ReceiptAddressDetailsView(address: address!)),
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
          Text(address.account!.keyIndex.toString(),
              style: context.textTheme.labelSmall?.copyWith(color: color)),
        OneLineTextWidget(
          address.view,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        )
      ],
    );
  }
}

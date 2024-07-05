import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class AccountAppBarView extends StatelessWidget {
  const AccountAppBarView(
      {super.key, required this.account, required this.onPressed});
  final CryptoAddress account;
  final IntVoid onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.mediaQuery.size.width,
        padding: WidgetConstant.padding10,
        decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: WidgetConstant.borderBottom8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CopyTextIcon(
                dataToCopy: account.address.toAddress,
                isSensitive: false,
                color: context.colors.onPrimary,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    account.accountName != null
                        ? RichText(
                            maxLines: 1,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: account.accountName,
                                  style: context.textTheme.labelLarge?.copyWith(
                                      color: context.colors.onPrimary)),
                              if (account.type != null)
                                TextSpan(
                                    text: " (${account.type!.tr})",
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                            color: context.colors.onPrimary))
                            ]))
                        : account.type == null
                            ? WidgetConstant.sizedBox
                            : Text(
                                account.accountName ?? account.type!.tr,
                                style: context.textTheme.labelLarge
                                    ?.copyWith(color: context.colors.onPrimary),
                              ),
                    if (account.multiSigAccount)
                      Text(
                        "multi_signature".tr,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.onPrimary),
                      ),
                    OneLineTextWidget(
                      account.address.toAddress,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            FocusScope(
              autofocus: false,
              canRequestFocus: false,
              child: SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.north_east_sharp),
                    onPressed: () {
                      onPressed(0);
                    },
                    child: Text("export_private_key".tr),
                  ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.north_east_sharp),
                    onPressed: () {
                      onPressed(1);
                    },
                    child: Text("export_public_key".tr),
                  ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.edit),
                    onPressed: () {
                      onPressed(3);
                    },
                    child: Text("account_name".tr),
                  ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.remove),
                    onPressed: () {
                      onPressed(2);
                    },
                    child: Text("remove_account".tr),
                  ),
                ],
                style: ButtonStyle(
                    iconColor:
                        WidgetStatePropertyAll(context.colors.onPrimary)),
                child: const SizedBox(
                  width: APPConst.double40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.more_vert_sharp),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

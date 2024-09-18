import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/account/forms/update_account.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class TronUpdateAccountFieldsView extends StatelessWidget {
  const TronUpdateAccountFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronUpdateAccountForm validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("account_name".tr, style: context.textTheme.titleMedium),
        Text("account_name_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
              "update_account".tr,
              child: StringWriterView(
                defaultValue: validator.accountName.value,
                title: PageTitleSubtitle(
                    title: "account_name".tr,
                    body: Text("account_name_desc".tr)),
                buttonText: "setup_input".tr,
                label: "account_name".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.accountName, value);
              },
            );
          },
          onRemoveIcon: validator.accountName.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(
              validator.accountName.value?.orEmpty ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
      ],
    );
  }
}

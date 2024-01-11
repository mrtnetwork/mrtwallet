import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/account/update_account.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class TronUpdateAccountFieldsView extends StatelessWidget {
  const TronUpdateAccountFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final CryptoAccountAddress address;
  final NetworkAccountCore account;
  final TronUpdateAccountValidator validator;

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
                buttomText: "setup_input".tr,
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

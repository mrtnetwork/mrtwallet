import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/vote_sr/forms/create_witness.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class TronCreateWitnessFieldsView extends StatelessWidget {
  const TronCreateWitnessFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronCreateWitnessForm validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("url".tr, style: context.textTheme.titleMedium),
        Text("tron_create_witness_url_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
              "create_witness".tr,
              child: StringWriterView(
                defaultValue: validator.url.value,
                title: PageTitleSubtitle(
                    title: "url".tr,
                    body: Text("tron_create_witness_url_desc".tr)),
                buttonText: "setup_input".tr,
                label: "url".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.url, value);
              },
            );
          },
          onRemoveIcon: validator.url.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(validator.url.value?.orEmpty ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
      ],
    );
  }
}

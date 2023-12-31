import 'package:blockchain_utils/numbers/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/receipt_address_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleAccountSetFieldsView extends StatelessWidget {
  const RippleAccountSetFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final CryptoAccountAddress address;
  final NetworkAccountCore account;
  final RippleAccountSetValidator validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("domain".tr, style: context.textTheme.titleMedium),
        Text("domain_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
              "account_set_fields".tr,
              child: StringWriterView(
                defaultValue: validator.domain.value,
                maxLength: RippleConst.maxDomainLength,
                title: PageTitleSubtitle(
                    title: "domain".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("domain_desc".tr),
                        WidgetConstant.height8,
                        Text("hex_desc".tr),
                        WidgetConstant.height8,
                        Text(
                          "character_length_validator_desc"
                              .tr
                              .replaceOne("domain".tr)
                              .replaceTwo(
                                  RippleConst.maxDomainLength.toString())
                              .replaceThere((RippleConst.maxDomainLength ~/ 2)
                                  .toString()),
                        ),
                        WidgetConstant.height8,
                        Text("empty_desc".tr)
                      ],
                    )),
                buttomText: "setup_input".tr,
                label: "domain".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.domain, value);
              },
            );
          },
          onRemoveIcon: validator.domain.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(
              validator.domain.value?.orEmpty ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
        WidgetConstant.height20,
        Text("email_hash".tr, style: context.textTheme.titleMedium),
        Text("ripple_email_hash_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
              "account_set_fields".tr,
              child: StringWriterView(
                defaultValue: validator.email.value,
                maxLength: RippleConst.maxEmailHashLength,
                title: PageTitleSubtitle(
                    title: "email_hash".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ripple_email_hash_desc".tr),
                        WidgetConstant.height8,
                        Text("hex_desc".tr),
                        WidgetConstant.height8,
                        Text(
                          "character_length_validator_desc"
                              .tr
                              .replaceOne("email_hash".tr)
                              .replaceTwo(
                                  RippleConst.maxEmailHashLength.toString())
                              .replaceThere(
                                  (RippleConst.maxEmailHashLength ~/ 2)
                                      .toString()),
                        ),
                        WidgetConstant.height8,
                        Text("empty_desc".tr)
                      ],
                    )),
                buttomText: "setup_input".tr,
                label: "email_hash".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.email, value);
              },
            );
          },
          onRemoveIcon: validator.email.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(validator.email.value?.orEmpty ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
        WidgetConstant.height20,
        Text("ripple_message_key".tr, style: context.textTheme.titleMedium),
        Text("ripple_message_key_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
              "account_set_fields".tr,
              child: StringWriterView(
                defaultValue: validator.messageKey.value,
                customValidator: validator.messageKeyValidator,
                maxLength: RippleConst.maxEmailHashLength,
                title: PageTitleSubtitle(
                    title: "ripple_message_key".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ripple_message_key_desc".tr),
                        WidgetConstant.height8,
                        Text("ripple_message_key_desc2".tr),
                        WidgetConstant.height8,
                        Text("empty_desc".tr)
                      ],
                    )),
                buttomText: "setup_input".tr,
                label: "ripple_message_key".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.messageKey, value);
              },
            );
          },
          onRemoveIcon: validator.messageKey.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(
              validator.messageKey.value?.orEmpty ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
        //
        WidgetConstant.height20,
        ReceiptAddressView(
          address: validator.nftokenMinter.value,
          validate: true,
          title: "ripple_nft_token_minter",
          subtitle: "ripple_nft_token_minter_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress>("account_set_fields".tr,
                    maxExtend: 0.8,
                    minExtent: 0.7,
                    initialExtend: 0.7,
                    child: SelectNetworkAddressView(
                      account: account,
                      subtitle: PageTitleSubtitle(
                          title: "ripple_nft_token_minter".tr,
                          body: Text("ripple_nft_token_minter_desc".tr)),
                    ))
                .then(
              (value) {
                validator.setValue(validator.nftokenMinter, value);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("ripple_transfer_rate".tr, style: context.textTheme.titleMedium),
        Text("ripple_transfer_rate_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: validator.transferRate.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
              "account_set_fields".tr,
              child: NumberWriteView(
                defaultValue: validator.transferRate.value,
                allowDecimal: false,
                customValidator: validator.validateTransferRate,
                allowSign: false,
                title: PageTitleSubtitle(
                    title: "ripple_transfer_rate".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ripple_transfer_rate_desc".tr),
                        WidgetConstant.height8,
                        Text("ripple_transfer_rate_desc2".tr),
                      ],
                    )),
                buttomText: "setup_input".tr,
                label: "ripple_transfer_rate".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.transferRate, value);
              },
            );
          },
          child: Text(validator.transferRate.value?.toString().to3Digits ??
              "tap_to_input_value".tr),
        ),
        WidgetConstant.height20,
        Text("ripple_tick_size".tr, style: context.textTheme.titleMedium),
        Text("ripple_tick_size_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: validator.tickSize.hasValue
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
              "account_set_fields".tr,
              child: NumberWriteView(
                defaultValue: validator.tickSize.value,
                allowDecimal: false,
                customValidator: validator.validateTickSize,
                allowSign: false,
                title: PageTitleSubtitle(
                    title: "ripple_tick_size".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ripple_tick_size_desc".tr),
                        WidgetConstant.height8,
                        Text("ripple_tick_size_desc2".tr),
                      ],
                    )),
                buttomText: "setup_input".tr,
                label: "ripple_tick_size".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.tickSize, value);
              },
            );
          },
          child: Text(validator.tickSize.value?.toString().to3Digits ??
              "tap_to_input_value".tr),
        ),

        WidgetConstant.height20,
        Text("ripple_enable_account_set_flags".tr,
            style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: <AccountSetAsfFlag, Widget>{
            for (var i in AccountSetAsfFlag.values) i: Text(i.name)
          },
          label: "account_set_flags".tr,
          value: validator.setFlag.value,
          key: ValueKey<String>("set_${validator.setFlag.value}"),
          onChanged: (value) {
            validator.setValue(validator.setFlag, value);
          },
          suffixIcon: validator.setFlag.hasValue
              ? IconButton(
                  onPressed: () {
                    validator.setValue(validator.setFlag, null);
                  },
                  icon: const Icon(Icons.remove_circle))
              : null,
        ),
        WidgetConstant.height20,
        Text("ripple_disable_account_set_flags".tr,
            style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: <AccountSetAsfFlag, Widget>{
            for (var i in AccountSetAsfFlag.values) i: Text(i.name)
          },
          label: "account_set_flags".tr,
          value: validator.clearFlag.value,
          key: ValueKey<String>("clear_${validator.clearFlag.value}"),
          onChanged: (value) {
            validator.setValue(validator.clearFlag, value);
          },
          suffixIcon: validator.clearFlag.hasValue
              ? IconButton(
                  onPressed: () {
                    validator.setValue(validator.clearFlag, null);
                  },
                  icon: const Icon(Icons.remove_circle))
              : null,
        ),
        WidgetConstant.height20,
      ],
    );
  }
}

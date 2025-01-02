import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

class RippleAccountSetFieldsView extends StatelessWidget {
  const RippleAccountSetFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final RippleChain account;
  final RippleAccountSetForm validator;
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
                buttonText: "setup_input".tr,
                label: "domain".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.domain, value);
              },
            );
          },
          onRemoveIcon: AddOrEditIconWidget(validator.domain.hasValue),
          child: Text(
            validator.domain.value?.orEmpty ?? "tap_to_input_value".tr,
            maxLines: 3,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
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
                buttonText: "setup_input".tr,
                label: "email_hash".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.email, value);
              },
            );
          },
          onRemoveIcon: AddOrEditIconWidget(validator.email.hasValue),
          child: Text(
            validator.email.value?.orEmpty ?? "tap_to_input_value".tr,
            maxLines: 3,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
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
                customForm: validator.messageKeyForm,
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
                buttonText: "setup_input".tr,
                label: "ripple_message_key".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.messageKey, value);
              },
            );
          },
          onRemoveIcon: AddOrEditIconWidget(validator.messageKey.hasValue),
          child: Text(
            validator.messageKey.value?.orEmpty ?? "tap_to_input_value".tr,
            maxLines: 3,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
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
                .openSliverBottomSheet<ReceiptAddress<XRPAddress>>(
                    "account_set_fields".tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    bodyBuilder: (c) => SelectRecipientAccountView<XRPAddress>(
                        account: account,
                        scrollController: c,
                        subtitle: PageTitleSubtitle(
                          title: "ripple_nft_token_minter".tr,
                          body: Text("ripple_nft_token_minter_desc".tr),
                        )))
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
          onRemoveIcon: AddOrEditIconWidget(validator.transferRate.hasValue),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
              "account_set_fields".tr,
              child: NumberWriteView(
                defaultValue: validator.transferRate.value,
                allowDecimal: false,
                customForm: validator.validateTransferRate,
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
                buttonText: "setup_input".tr,
                label: "ripple_transfer_rate".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.transferRate, value);
              },
            );
          },
          child: Text(
            validator.transferRate.value?.toString().to3Digits ??
                "tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),
        WidgetConstant.height20,
        Text("ripple_tick_size".tr, style: context.textTheme.titleMedium),
        Text("ripple_tick_size_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: AddOrEditIconWidget(validator.tickSize.hasValue),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
              "account_set_fields".tr,
              child: NumberWriteView(
                defaultValue: validator.tickSize.value,
                allowDecimal: false,
                customForm: validator.validateTickSize,
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
                buttonText: "setup_input".tr,
                label: "ripple_tick_size".tr,
              ),
            )
                .then(
              (value) {
                validator.setValue(validator.tickSize, value);
              },
            );
          },
          child: Text(
            validator.tickSize.value?.toString().to3Digits ??
                "tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),

        WidgetConstant.height20,
        Text("ripple_enable_account_set_flags".tr,
            style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: <AccountSetAsfFlag, Widget>{
            for (final i in AccountSetAsfFlag.values) i: Text(i.name)
          },
          value: validator.setFlag.value,
          key: ValueKey<String>("set_${validator.setFlag.value}"),
          onChanged: (value) {
            validator.setValue(validator.setFlag, value);
          },
          hint: "none".tr,
          icon: validator.setFlag.hasValue
              ? InkWell(
                  onTap: () {
                    validator.setValue(validator.setFlag, null);
                  },
                  child: const Icon(Icons.remove_circle))
              : null,
        ),
        WidgetConstant.height20,
        Text("ripple_disable_account_set_flags".tr,
            style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: <AccountSetAsfFlag, Widget>{
            for (final i in AccountSetAsfFlag.values) i: Text(i.name)
          },
          value: validator.clearFlag.value,
          key: ValueKey<String>("clear_${validator.clearFlag.value}"),
          onChanged: (value) {
            validator.setValue(validator.clearFlag, value);
          },
          hint: "none".tr,
          icon: validator.clearFlag.hasValue
              ? InkWell(
                  onTap: () {
                    validator.setValue(validator.clearFlag, null);
                  },
                  child: Icon(
                    Icons.remove_circle,
                    color: context.onPrimaryContainer,
                  ))
              : null,
        ),
        WidgetConstant.height20,
      ],
    );
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/bytes_utils/quick_bytes.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/receipt_address_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class RippleSetSignerListFieldsView extends StatelessWidget {
  const RippleSetSignerListFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final CryptoAccountAddress address;
  final NetworkAccountCore account;
  final RippleSignerListValidator validator;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppGlobalConst.animationDuraion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        key: ValueKey(validator.signerEntries.value?.length),
        children: [
          ...List.generate(validator.signerEntries.value?.length ?? 0, (index) {
            final signer = validator.signerEntries.value![index];
            return ContainerWithBorder(
                onRemove: () {
                  validator.removeIndex(validator.signerEntries, index);
                },
                onRemoveIcon: const Icon(Icons.remove_circle),
                child: _SignerEntryView(signer: signer));
          }),
          ReceiptAddressView(
            address: null,
            validate: (validator.signerEntries.value?.isNotEmpty ?? false),
            title: null,
            onTap: () {
              context
                  .openSliverBottomSheet<XRPSignerEntries>(
                    validator.fieldsName.tr,
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9,
                    child: _SetupRippleSignerEntries(account: account),
                  )
                  .then((value) =>
                      validator.setListValue(validator.signerEntries, value));
            },
          ),
          WidgetConstant.height20,
          Text(validator.signerQuorum.name.tr,
              style: context.textTheme.titleMedium),
          Text(validator.signerQuorum.subject.tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            validate: validator.signerQuorum.isCompleted,
            onRemoveIcon: validator.signerQuorum.hasValue
                ? const Icon(Icons.edit)
                : const Icon(Icons.add),
            onRemove: () {
              context
                  .openSliverBottomSheet<BigRational>(
                    validator.fieldsName.tr,
                    child: NumberWriteView(
                      defaultValue: validator.signerQuorum.value,
                      min: BigRational.zero,
                      max: RippleConst.max32UnsignedRational,
                      allowDecimal: false,
                      allowSign: false,
                      title: PageTitleSubtitle(
                          title: validator.signerQuorum.name.tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextAndLinkView(
                                  text: validator.signerQuorum.subject.tr,
                                  url: validator.helperUri),
                            ],
                          )),
                      buttomText: "setup_input".tr,
                      label: validator.signerQuorum.name.tr,
                    ),
                  )
                  .then(
                    (value) =>
                        validator.setValue(validator.signerQuorum, value),
                  );
            },
            child: Text(validator.signerQuorum.value?.toString().to3Digits ??
                "tap_to_input_value".tr),
          ),
        ],
      ),
    );
  }
}

class _SignerEntryView extends StatelessWidget {
  const _SignerEntryView({required this.signer});
  final XRPSignerEntries signer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("account".tr, style: context.textTheme.titleMedium),
        OneLineTextWidget(signer.address.view),
        WidgetConstant.height8,
        Text("ripple_signer_weight".tr, style: context.textTheme.titleMedium),
        Text(signer.weight.toString())
      ],
    );
  }
}

class _SetupRippleSignerEntries extends StatefulWidget {
  const _SetupRippleSignerEntries({required this.account});
  final NetworkAccountCore account;

  @override
  State<_SetupRippleSignerEntries> createState() =>
      _SetupRippleSignerEntriesState();
}

class _SetupRippleSignerEntriesState extends State<_SetupRippleSignerEntries>
    with SafeState {
  ReceiptAddress? address;
  BigRational? signerWegith;
  String? walletLocator;

  bool isReady = false;

  void _isReady() {
    isReady = address != null && signerWegith != null;
    setState(() {});
  }

  void onSelectAddress(ReceiptAddress? newAddress) {
    address = newAddress;
    _isReady();
  }

  void onSelectWeight(BigRational? sw) {
    if (sw == null ||
        sw.isNegative ||
        sw.isDecimal ||
        sw.isZero ||
        sw > RippleConst.max32UnsignedRational) {
      signerWegith = null;
    } else {
      signerWegith = sw;
    }
    _isReady();
  }

  String? validatorLocator(String? v) {
    final isHash256 = QuickBytesUtils.ensureIsHash256(v);
    if (isHash256 == null) {
      return "hash256_validator".tr;
    }
    return null;
  }

  void onSetLocator(String? locator) {
    walletLocator = QuickBytesUtils.ensureIsHash256(locator);
    _isReady();
  }

  void onSetup() {
    _isReady();
    if (!isReady) return;
    final signer = XRPSignerEntries(
        address: address!, weight: signerWegith!, walletLocator: walletLocator);
    context.pop(signer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "ripple_signer_entery".tr,
            body: Text(
              "ripple_signer_entery_desc".tr,
            )),
        ReceiptAddressView(
          address: address,
          validate: address != null,
          title: null,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress>(
                  "ripple_signer_enteris_fields".tr,
                  maxExtend: 0.8,
                  minExtent: 0.7,
                  initialExtend: 0.7,
                  child: SelectNetworkAddressView(
                    account: widget.account,
                    subtitle: PageTitleSubtitle(
                        title: "account".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ripple_signer_entry_account_desc".tr,
                            ),
                          ],
                        )),
                  ),
                )
                .then(onSelectAddress);
          },
        ),
        WidgetConstant.height20,
        Text("ripple_signer_weight".tr, style: context.textTheme.titleMedium),
        Text("ripple_signer_weight_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: signerWegith != null,
          onRemoveIcon: signerWegith != null
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
                  "ripple_signer_enteris_fields".tr,
                  child: NumberWriteView(
                    defaultValue: signerWegith ?? BigRational.one,
                    min: BigRational.one,
                    max: RippleConst.max32UnsignedRational,
                    allowDecimal: false,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "ripple_signer_weight".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_signer_weight_desc".tr),
                          ],
                        )),
                    buttomText: "setup_input".tr,
                    label: "ripple_signer_weight".tr,
                  ),
                )
                .then(onSelectWeight);
          },
          child: Text(
              signerWegith?.toString().to3Digits ?? "tap_to_input_value".tr),
        ),
        WidgetConstant.height20,
        Text("ripple_wallet_locator".tr, style: context.textTheme.titleMedium),
        Text("ripple_signer_entry_wallet_locator_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  "ripple_signer_enteris_fields".tr,
                  child: StringWriterView(
                    defaultValue: walletLocator,
                    maxLength: RippleConst.maxWalletLocatorLength,
                    customValidator: validatorLocator,
                    title: PageTitleSubtitle(
                        title: "ripple_wallet_locator".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ripple_signer_entry_wallet_locator_desc".tr),
                          ],
                        )),
                    buttomText: "setup_input".tr,
                    label: "ripple_wallet_locator".tr,
                  ),
                )
                .then(onSetLocator);
          },
          onRemoveIcon: walletLocator != null
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(walletLocator ?? "tap_to_input_value".tr, maxLines: 3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical20,
                  onPressed: isReady ? onSetup : null,
                  child: Text("setup_signer".tr),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}

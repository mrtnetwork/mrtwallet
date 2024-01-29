import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/types/typedef.dart';

class WalletSigningPassword extends StatefulWidget {
  const WalletSigningPassword(
      {super.key, required this.request, required this.onPasswordValidator});
  final SigningRequest request;
  final FuncFutureBoolString onPasswordValidator;

  @override
  State<WalletSigningPassword> createState() => _WalletSigningPasswordState();
}

class _WalletSigningPasswordState extends State<WalletSigningPassword>
    with SafeState {
  final GlobalKey<StreamWidgetState> keyState =
      GlobalKey<StreamWidgetState>(debugLabel: "WalletSigningPassword_1");
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(debugLabel: "WalletSigningPassword");
  late final Set<AddressDerivationIndex> signers =
      widget.request.signers.toSet();
  late final Set<CryptoAccountAddress> addresses =
      widget.request.addresses.toSet();
  List<String> singerPubKeys = [];

  String _password = "";
  String? _error;
  int _attemped = 0;
  bool get toManyRequest => _attemped > 3;
  void onChagePassword(String v) {
    if (toManyRequest) return;
    _password = v;
    if (_error != null) {
      _error = null;
      setState(() {});
    }
  }

  String? validator(String? v) {
    if (!AppStringUtility.isStrongPassword(v)) {
      return "password_desc".tr;
    }
    return null;
  }

  void _updaateProgress(MethodResult result) async {
    if (result.hasError || !result.result) {
      _attemped++;
      if (_attemped > 3) {
        keyState.updateStream(StreamWidgetStatus.hide);
      } else {
        keyState.error();
      }
      if (result.hasError) {
        _error = result.error!.tr;
      } else {
        _error = "incorrect_password".tr;
      }
      if (_attemped > 3) {
        _error = "to_many_request".tr;
      }
    } else {
      keyState.success();
      await Future.delayed(AppGlobalConst.milliseconds100);
      if (context.mounted) {
        context.pop(_password);
      }
    }
  }

  void onPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    keyState.process();
    setState(() {});
    final result = await MethodCaller.call(() async {
      return await widget.onPasswordValidator(_password);
    });
    _updaateProgress(result);
    setState(() {});
  }

  late bool showAllPrivateKeys = signers.length == 1;
  late bool showAllAddresses = addresses.length == 1;

  void toggleShowAllPrivateKey() {
    showAllPrivateKeys = !showAllPrivateKeys;
    setState(() {});
  }

  void toggleShowAllAddresses() {
    showAllAddresses = !showAllAddresses;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "sign_transaction".tr,
              body: Column(
                children: [
                  Text("signing_tx_desc1".tr),
                  WidgetConstant.height8,
                  Text("signing_tx_desc".tr),
                ],
              )),
          WidgetConstant.height20,
          Text("accounts".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          AnimatedSize(
              duration: AppGlobalConst.animationDuraion,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: context.mediaQuery.size.width,
                child: ContainerWithBorder(
                    onRemove: () {
                      toggleShowAllAddresses();
                    },
                    iconAlginment: showAllAddresses
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    onRemoveIcon: showAllAddresses
                        ? const Icon(Icons.arrow_drop_up_sharp)
                        : const Icon(Icons.arrow_drop_down_sharp),
                    key: ValueKey(showAllAddresses),
                    child: showAllAddresses
                        ? Column(
                            children: List.generate(addresses.length, (index) {
                              final address = addresses.elementAt(index);
                              final bool isLastIndex =
                                  index == addresses.length - 1;
                              return Column(
                                children: [
                                  AddressDetailsView(address: address),
                                  if (!isLastIndex)
                                    Divider(
                                        color:
                                            context.colors.onPrimaryContainer)
                                ],
                              );
                            }),
                          )
                        : Text("transaction_generated_with_number_accounts"
                            .tr
                            .replaceOne(addresses.length.toString()))),
              )),
          WidgetConstant.height20,
          Text("private_keys".tr, style: context.textTheme.titleMedium),
          Text("private_keys__signing_access_desc".tr),
          WidgetConstant.height8,
          AnimatedSize(
              duration: AppGlobalConst.animationDuraion,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: context.mediaQuery.size.width,
                child: ContainerWithBorder(
                  onRemove: () {
                    toggleShowAllPrivateKey();
                  },
                  iconAlginment: showAllPrivateKeys
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  onRemoveIcon: showAllPrivateKeys
                      ? const Icon(Icons.arrow_drop_up_sharp)
                      : const Icon(Icons.arrow_drop_down_sharp),
                  key: ValueKey(showAllPrivateKeys),
                  child: showAllPrivateKeys
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(signers.length, (index) {
                            final keyIndex = signers.elementAt(index);
                            final bool isLastIndex =
                                index == signers.length - 1;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _KeyIndexDetails(keyIndex: keyIndex),
                                if (!isLastIndex)
                                  Divider(
                                      color: context.colors.onPrimaryContainer)
                              ],
                            );
                          }),
                        )
                      : Text("transaction_need_number_private_key_to_complete"
                          .tr
                          .replaceOne(signers.length.toString())),
                ),
              )),
          WidgetConstant.height20,
          AppTextField(
            label: "password".tr,
            validator: validator,
            error: _error,
            onChanged: onChagePassword,
            obscureText: true,
            initialValue: _password,
            readOnly: keyState.inProgress,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamWidget(
                key: keyState,
                buttomWidget: FixedElevatedButton(
                    onPressed: onPassword, child: Text("sign_transaction".tr)),
                backToIdle: AppGlobalConst.oneSecoundDuration,
                padding: WidgetConstant.paddingVertical20,
              )
            ],
          )
        ],
      ),
    );
  }
}

class _KeyIndexDetails extends StatelessWidget {
  const _KeyIndexDetails({required this.keyIndex});
  final AddressDerivationIndex keyIndex;
  @override
  Widget build(BuildContext context) {
    switch (keyIndex.runtimeType) {
      case ImportedAddressIndex:
        return _ImportedKeyDerivationDetails(
            keyIndex: keyIndex as ImportedAddressIndex);
      default:
        return _HDWalletDerivationDetails(
            keyIndex: keyIndex as Bip32AddressIndex);
    }
  }
}

class _ImportedKeyDerivationDetails extends StatelessWidget {
  const _ImportedKeyDerivationDetails({required this.keyIndex});
  final ImportedAddressIndex keyIndex;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("imported".tr, style: context.textTheme.labelLarge),
        Text(keyIndex.accountId),
        if (keyIndex.bip32KeyIndex != null) ...[
          Text(keyIndex.bip32KeyIndex!.toString(),
              style: context.textTheme.bodySmall)
        ]
      ],
    );
  }
}

class _HDWalletDerivationDetails extends StatelessWidget {
  const _HDWalletDerivationDetails({required this.keyIndex});
  final Bip32AddressIndex keyIndex;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("hd_wallet".tr, style: context.textTheme.labelLarge),
        Text(keyIndex.toString()),
      ],
    );
  }
}

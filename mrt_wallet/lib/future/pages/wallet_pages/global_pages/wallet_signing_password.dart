import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

class WalletSigningPassword extends StatefulWidget {
  const WalletSigningPassword(
      {super.key, required this.signers, required this.onPasswordValidator});
  final List<CryptoAddress> signers;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.signers.length, (index) {
              return ContainerWithBorder(
                  child: _ShowSignerDetails(address: widget.signers[index]));
            }),
          ),
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

class _ShowSignerDetails extends StatelessWidget {
  const _ShowSignerDetails({required this.address});
  final CryptoAddress address;
  @override
  Widget build(BuildContext context) {
    switch (address.runtimeType) {
      case IBitcoinAddress:
        return _BitcoinSignerDetais(address: address as IBitcoinAddress);
      case IBitcoinMultiSigAddress:
        return _BitcoinSignerDetais(address: address as IBitcoinAddress);
      default:
        return const SizedBox();
    }
  }
}

class _BitcoinSignerDetais extends StatelessWidget {
  const _BitcoinSignerDetais({required this.address});
  final IBitcoinAddress address;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address.addressType.value, style: context.textTheme.labelLarge),
        OneLineTextWidget(address.address.toAddress),
        Text(address.keyIndex.path.tr, style: context.textTheme.bodySmall),
        if (address.isMultiSigAccounts) ...[
          WidgetConstant.height8,
          Text("public_key_signatories".tr,
              style: context.textTheme.labelLarge),
          WidgetConstant.height8,
          Column(
            children: List.generate(address.signers.length, (index) {
              return Padding(
                  padding: WidgetConstant.padding5,
                  child: OneLineTextWidget(address.signers[index]));
            }),
          )
        ]
      ],
    );
  }
}

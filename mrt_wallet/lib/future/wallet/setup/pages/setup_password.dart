import 'package:flutter/material.dart';

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SetupWalletPassword extends StatefulWidget {
  const SetupWalletPassword({super.key});

  @override
  State<SetupWalletPassword> createState() => _SetupWalletPasswordState();
}

class _SetupWalletPasswordState extends State<SetupWalletPassword>
    with SafeState {
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(debugLabel: "SetupWalletPassword");
  final FocusNode nextFocus = FocusNode();
  String password = "";
  void onChangePassword(String v) {
    password = v;
  }

  bool _obscureText = true;

  void toggleObscure() {
    _obscureText = !_obscureText;
    setState(() {});
  }

  String? validator(String? value) {
    if (StrUtils.isStrongPassword(value)) {
      return null;
    }
    return "weak_password".tr;
  }

  String? confirmForm(String? value) {
    if (value != password) {
      return "p_does_not_match".tr;
    }
    return null;
  }

  void setupPassword() {
    if (formKey.currentState?.validate() ?? false) {
      final model = context.watch<SetupWalletController>(StateConst.setup);
      model.setPassword(password);
    }
  }

  @override
  void dispose() {
    nextFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
            title: "setup_password".tr,
            body: LargeTextView(
              [
                "p_note1".tr,
                "p_note2".tr,
                "p_note3".tr,
                "p_note4".tr,
              ],
            ),
          ),
          AppTextField(
            obscureText: _obscureText,
            onChanged: onChangePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.go,
            disableContextMenu: true,
            nextFocus: nextFocus,
            validator: validator,
            label: "e_password".tr,
            helperText: "password_desc".tr,
          ),
          AppTextField(
            obscureText: _obscureText,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            focusNode: nextFocus,
            disableContextMenu: true,
            validator: confirmForm,
            label: "c_password".tr,
          ),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  onPressed: setupPassword, child: Text("setup_password".tr)),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class MnemonicExtraOptionView extends StatefulWidget {
  const MnemonicExtraOptionView({super.key});

  @override
  State<MnemonicExtraOptionView> createState() =>
      _MnemonicExtraOptionViewState();
}

class _MnemonicExtraOptionViewState extends State<MnemonicExtraOptionView>
    with SafeState {
  bool usePassphrase = false;
  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "MnemonicExtraOptionView_1");
  final FocusNode nextFocus = FocusNode();
  String _passphrase = "";

  void onChange(bool? v) {
    usePassphrase = v ?? usePassphrase;
    _passphrase = "";
    setState(() {});
  }

  void onChangedText(String v) {
    _passphrase = v;
  }

  @override
  void dispose() {
    nextFocus.dispose();
    super.dispose();
  }

  void setup() async {
    if (!(form.currentState?.validate() ?? false)) return;
    final model = context.watch<SetupWalletController>(StateConst.setup);
    progressKey.progressText("launch_the_wallet".tr);
    final result = await MethodUtils.call(() async {
      final String? passPhrase = usePassphrase ? _passphrase : null;
      await model.setup(passPhrase);
    });
    if (result.hasError) {
      progressKey.errorText(result.error?.tr ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
              title: "passphrase".tr,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("mn_password_desc".tr),
                  WidgetConstant.height8,
                  Text(
                    "extra_opetion_desc".tr,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.error),
                  )
                ],
              ),
            ),
            AppSwitchListTile(
              title: Text("enable_mnemonic_password".tr),
              value: usePassphrase,
              onChanged: onChange,
            ),
            AnimatedSize(
              duration: APPConst.animationDuraion,
              alignment: Alignment.center,
              child: !usePassphrase
                  ? WidgetConstant.sizedBox
                  : Padding(
                      padding: WidgetConstant.paddingHorizontal20,
                      child: Column(
                        children: [
                          AppTextField(
                            label: "mn_password".tr,
                            obscureText: true,
                            nextFocus: nextFocus,
                            disableContextMenu: true,
                            initialValue: _passphrase,
                            onChanged: onChangedText,
                            validator: (p0) {
                              if (!usePassphrase) return null;
                              if (p0?.isEmpty ?? true) {
                                return "password_should_not_be_empty".tr;
                              }
                              return null;
                            },
                          ),
                          AppTextField(
                            label: "c_password".tr,
                            obscureText: true,
                            disableContextMenu: true,
                            focusNode: nextFocus,
                            validator: (p0) {
                              if (!usePassphrase) return null;
                              if (_passphrase == p0) return null;
                              return "p_does_not_match".tr;
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical20,
                  onPressed: setup,
                  child: Text("wallet_settings".tr),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

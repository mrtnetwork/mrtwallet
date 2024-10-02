import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/importing_custom_key_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class StellarKeyConversionView extends StatelessWidget {
  const StellarKeyConversionView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<StellarChain>(
      title: "stellar_key_conversion".tr,
      childBulder: (wallet, chain, switchAccount) {
        return _StellarConversionView(chain.network);
      },
    );
  }
}

class _StellarConversionView extends StatefulWidget {
  const _StellarConversionView(this.network, {Key? key}) : super(key: key);
  final WalletStellarNetwork network;

  @override
  State<_StellarConversionView> createState() =>
      __StellarKeyConversionViewState();
}

class __StellarKeyConversionViewState extends State<_StellarConversionView>
    with SafeState {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> keyController =
      GlobalKey<AppTextFieldState>(
          debugLabel: "__StellarKeyConversionViewState");
  XRPKeyAlgorithm algorithm = XRPKeyAlgorithm.secp256k1;

  String key = "";

  void onChangeKey(String v) => key = v;

  void onChangeKeyAlgorithm(XRPKeyAlgorithm? updateAlgorithm) {
    algorithm = updateAlgorithm ?? algorithm;
    setState(() {});
  }

  String? validate(String? v) {
    if (v == null || v.length != StellarConst.stellarBase32SecretKeyLength) {
      return "stellar_base32_secret_key_validator".tr;
    }

    return null;
  }

  ImportCustomKeys? generatedKey;

  void onSubmit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("generating_private_key".tr);
    final result = await MethodUtils.call(() async {
      final value = keyController.currentState?.getValue();
      final key = StellarUtils.stellarBase32SecretKeyToImportKey(value);
      return ImportCustomKeys.fromBytes(
        privateKey: key.toBytes(),
        publicKey: key.toPublicKey().toBytes(),
        coin: widget.network.coins.first,
      );
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: true);
    } else {
      generatedKey = result.result;
      progressKey.success();
    }
  }

  void onBackButton(bool didPop, _) {
    if (!didPop) {
      generatedKey = null;
      key = "";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: generatedKey == null,
      onPopInvokedWithResult: onBackButton,
      child: PageProgress(
        key: progressKey,
        backToIdle: APPConst.oneSecoundDuration,
        child: (c) => Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: CustomScrollView(
            slivers: [
              SliverConstraintsBoxView(
                  padding: WidgetConstant.paddingHorizontal20,
                  sliver: SliverToBoxAdapter(
                    child: APPAnimatedSwitcher(
                        enable: generatedKey != null,
                        widgets: {
                          false: (c) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PageTitleSubtitle(
                                      title: "stellar_key_conversion".tr,
                                      body: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "stellar_key_conversion_desc".tr),
                                          WidgetConstant.height8,
                                          Text(
                                              "secret_key_conversion_desc2".tr),
                                        ],
                                      )),
                                  Text("secret_key".tr,
                                      style: context.textTheme.titleMedium),
                                  Text("stellar_base32_secret_key_desc2".tr),
                                  WidgetConstant.height8,
                                  AppTextField(
                                    key: keyController,
                                    label: "secret_key".tr,
                                    initialValue: key,
                                    onChanged: onChangeKey,
                                    validator: validate,
                                    obscureText: true,
                                    pasteIcon: true,
                                    isSensitive: true,
                                    hint: "example_s"
                                        .tr
                                        .replaceOne(APPConst.exampleBase32),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FixedElevatedButton(
                                        padding:
                                            WidgetConstant.paddingVertical40,
                                        onPressed: onSubmit,
                                        child: Text("generate".tr),
                                      )
                                    ],
                                  )
                                ],
                              ),
                          true: (c) => ImportCustomKeyToWalletView(
                              keypair: generatedKey!)
                        }),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

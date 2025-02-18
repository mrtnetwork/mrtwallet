import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/importing_custom_key_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:on_chain/aptos/src/keypair/utils/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class AptosKeyConversionView extends StatelessWidget {
  const AptosKeyConversionView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SuiChain>(
      title: "aptos_key_conversion".tr,
      childBulder: (wallet, chain, switchAccount) {
        return _AptosConversionView(chain.network);
      },
    );
  }
}

class _AptosConversionView extends StatefulWidget {
  const _AptosConversionView(this.network);
  final WalletSuiNetwork network;

  @override
  State<_AptosConversionView> createState() => __AptosKeyConversionViewState();
}

class __AptosKeyConversionViewState extends State<_AptosConversionView>
    with SafeState<_AptosConversionView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> keyController =
      GlobalKey<AppTextFieldState>(debugLabel: "__AptosKeyConversionViewState");
  String key = "";

  void onChangeKey(String v) => key = v;

  String? validate(String? v) {
    final key = MethodUtils.nullOnException(
        () => AptosCryptoUtils.decodeAptosPrivateKey(v ?? ''));
    if (key == null) {
      return "invalid_aptos_private_key".tr;
    }

    return null;
  }

  ImportCustomKeys? generatedKey;

  void onSubmit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("generating_private_key".tr);
    final result = await MethodUtils.call(() async {
      final value = keyController.currentState?.getValue();
      final key = AptosCryptoUtils.decodeAptosPrivateKey(value ?? '');
      final privateKey = IPrivateKey.fromBytes(key.$2, key.$1.curveType);
      final coin = widget.network.coins
          .firstWhere((e) => e.conf.type == key.$1.curveType);
      return ImportCustomKeys.fromBytes(
          privateKey: privateKey.raw,
          publicKey: BlockchainUtils.toPublicBytes(privateKey.publicKey),
          coin: coin);
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
      updateState(() {});
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
        child: (context) => Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: UnfocusableChild(
            child: CustomScrollView(
              slivers: [
                SliverConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    sliver: APPSliverAnimatedSwitcher(
                        enable: generatedKey != null,
                        widgets: {
                          false: (c) => SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PageTitleSubtitle(
                                        title: "aptos_key_conversion".tr,
                                        body: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("aptos_key_conversion_desc".tr)
                                          ],
                                        )),
                                    Text("secret_key".tr,
                                        style: context.textTheme.titleMedium),
                                    Text("aptos_aip80_private_key_desc2".tr),
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
                                          .replaceOne(APPConst.exampleBase58),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              ),
                          true: (c) => ImportCustomKeyToWalletView(
                              keypair: generatedKey!)
                        })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

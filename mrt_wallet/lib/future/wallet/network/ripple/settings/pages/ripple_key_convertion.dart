import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/importing_custom_key_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum _KeyType {
  seed,
  entropy;

  String get example {
    if (this == _KeyType.seed) return APPConst.exampleBase58;
    return APPConst.exampleHex;
  }
}

class RippleKeyConversionView extends StatelessWidget {
  const RippleKeyConversionView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<RippleChain>(
      title: "ripple_key_conversion".tr,
      childBulder: (wallet, chain, switchAccount) {
        return _RippleKeyConversionView(chain.network.toNetwork());
      },
    );
  }
}

class _RippleKeyConversionView extends StatefulWidget {
  const _RippleKeyConversionView(this.network, {Key? key}) : super(key: key);
  final WalletXRPNetwork network;

  @override
  State<_RippleKeyConversionView> createState() =>
      __RippleKeyConversionViewState();
}

class __RippleKeyConversionViewState extends State<_RippleKeyConversionView>
    with SafeState {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> keyController =
      GlobalKey<AppTextFieldState>(
          debugLabel: "__RippleKeyConversionViewState");
  XRPKeyAlgorithm algorithm = XRPKeyAlgorithm.secp256k1;
  _KeyType keyType = _KeyType.seed;

  String key = "";

  void onChangeKey(String v) => key = v;

  void onChangeKeyAlgorithm(XRPKeyAlgorithm? updateAlgorithm) {
    algorithm = updateAlgorithm ?? algorithm;
    setState(() {});
  }

  void onChangeKeyType(_KeyType? updateKeyType) {
    keyType = updateKeyType ?? keyType;
    setState(() {});
  }

  String? validate(String? v) {
    if (v == null || v.length < BlockchainConst.minimumKeysLength) {
      return "ripple_seed_entropy_validator".tr.replaceOne(keyType.name);
    }

    return null;
  }

  ImportCustomKeys? generatedKey;

  void onSubmit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("generating_private_key".tr);
    final result = await MethodUtils.call(() async {
      final value = keyController.currentState?.getValue();
      XRPPrivateKey key;
      switch (keyType) {
        case _KeyType.seed:
          key = RippleUtils.seedToPrivateKey(value!);
          break;
        default:
          key = RippleUtils.entropyToPrivateKey(value!, algorithm);
          break;
      }
      return ImportCustomKeys.fromBytes(
        privateKey: key.toBytes(),
        publicKey: key.getPublic().toBytes(),
        coin: widget.network.coins.firstWhere(
            (element) => element.conf.type == key.algorithm.curveType),
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
        child: (c) => ConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child:
                    APPAnimatedSwitcher(enable: generatedKey != null, widgets: {
                  false: (c) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PageTitleSubtitle(
                              title: "ripple_key_conversion".tr,
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ripple_key_conversion_desc".tr),
                                  WidgetConstant.height8,
                                  Text("secret_key_conversion_desc2".tr),
                                ],
                              )),
                          Text("ripple_key_type".tr,
                              style: context.textTheme.titleMedium),
                          Text("inidicate_type_of_ripple_key".tr),
                          WidgetConstant.height8,
                          AppDropDownBottom(
                              items: {
                                for (final i in _KeyType.values)
                                  i: Text(i.name.tr)
                              },
                              value: keyType,
                              label: "ripple_key_type".tr,
                              onChanged: onChangeKeyType),
                          WidgetConstant.height20,
                          APPAnimatedSize(
                              isActive: keyType == _KeyType.entropy,
                              onActive: (c) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("key_algorithm".tr,
                                          style: context.textTheme.titleMedium),
                                      Text("choose_key_algorithm_desc".tr),
                                      WidgetConstant.height8,
                                      AppDropDownBottom(
                                        items: {
                                          for (final i
                                              in XRPKeyAlgorithm.values)
                                            i: Text(i.curveType.name.camelCase)
                                        },
                                        value: algorithm,
                                        label: "key_algorithm".tr,
                                        onChanged: onChangeKeyAlgorithm,
                                      ),
                                      WidgetConstant.height20,
                                    ],
                                  ),
                              onDeactive: (c) => WidgetConstant.sizedBox),
                          Text("ripple_key".tr,
                              style: context.textTheme.titleMedium),
                          Text("select_ripple_seed_or_entropy".tr),
                          WidgetConstant.height8,
                          AppTextField(
                            key: keyController,
                            label: keyType.name.tr,
                            initialValue: key,
                            onChanged: onChangeKey,
                            validator: validate,
                            obscureText: true,
                            hint: "example_s".tr.replaceOne(keyType.example),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FixedElevatedButton(
                                padding: WidgetConstant.paddingVertical40,
                                onPressed: onSubmit,
                                child: Text("generate".tr),
                              )
                            ],
                          )
                        ],
                      ),
                  true: (c) =>
                      ImportCustomKeyToWalletView(keypair: generatedKey!)
                }),
              ),
            )),
      ),
    );
  }
}

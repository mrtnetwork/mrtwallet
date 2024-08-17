import 'package:blockchain_utils/bip/bip/bip39/bip39_mnemonic.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'mnemonic_view.dart';

class GenerateMnemonicView extends StatelessWidget {
  const GenerateMnemonicView({super.key});
  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<SetupWalletController>(
      controller: () => context.watch<SetupWalletController>(StateConst.setup),
      repositoryId: StateConst.setup,
      removable: false,
      builder: (model) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PageTitleSubtitle(
              title: "generate_mnemonic".tr,
              body: LargeTextView(["show_mnemonic_desc".tr]),
            ),
            APPAnimatedSize(
              duration: APPConst.animationDuraion,
              alignment: Alignment.center,
              isActive: model.hasMnemonic,
              onActive: (c) => SizedBox(
                width: context.mediaQuery.size.width,
                key: ValueKey<int?>(model.mnemonic?.hashCode),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MnemonicView(mnemonic: model.mnemonic!.toList()),
                    WidgetConstant.height20,
                  ],
                ),
              ),
              onDeactive: (p0) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("n_of_mnemonic_words".tr,
                      style: context.textTheme.titleMedium),
                  Text("choose_mnemonic_desc".tr),
                  WidgetConstant.height8,
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      label: Text("n_of_mnemonic_words".tr),
                    ),
                    value: model.mnemonicWord,
                    items: Bip39WordsNum.values.map((count) {
                      return DropdownMenuItem<int>(
                          value: count.value,
                          child: Text("count_words"
                              .tr
                              .replaceOne(count.value.toString())));
                    }).toList(),
                    onChanged: model.updateMnemonicCount,
                  ),
                  WidgetConstant.height20,
                  Text("Language".tr, style: context.textTheme.titleMedium),
                  Text("choose_mnemonic_lang_desc".tr),
                  WidgetConstant.height8,
                  DropdownButtonFormField<Bip39Languages>(
                    value: model.language,
                    decoration: InputDecoration(
                      label: Text("Language".tr),
                    ),
                    items: Bip39Languages.values.map((language) {
                      return DropdownMenuItem<Bip39Languages>(
                        value: language,
                        child: Text(language.name.camelCase),
                      );
                    }).toList(),
                    onChanged: model.updateLanguage,
                  ),
                  WidgetConstant.height20,
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamWidget(
                      padding: WidgetConstant.paddingVertical40,
                      key: model.generateMnemonicKey,
                      backToIdle: APPConst.oneSecoundDuration,
                      fixedSize: false,
                      buttonWidget: FixedElevatedButton(
                          child: model.mnemonic == null
                              ? Text("generate".tr)
                              : Text("v_mnemonic".tr),
                          onPressed: () {
                            model.generateMnemonic();
                          }),
                    ),
                  ],
                ),
                APPAnimatedSize(
                    isActive: model.hasMnemonic,
                    onActive: (c) => TextButton.icon(
                          onPressed: () {
                            model.regenerate();
                          },
                          label: Text("r_generate".tr),
                          icon: const Icon(Icons.refresh),
                        ),
                    onDeactive: (c) => WidgetConstant.sizedBox)
              ],
            )
          ],
        );
      },
    );
  }
}

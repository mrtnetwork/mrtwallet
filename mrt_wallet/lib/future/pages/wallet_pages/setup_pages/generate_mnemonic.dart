import 'package:blockchain_utils/bip/bip/bip39/bip39_mnemonic.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';

class GenerateMnemonicView extends StatelessWidget {
  const GenerateMnemonicView({super.key});
  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<SetupWalletController>(
      controller: () => context.watch<SetupWalletController>("setup_wallet"),
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
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                label: Text("n_of_mnemonic_words".tr),
              ),
              value: model.mnemonicWord,
              items: Bip39WordsNum.values.map((count) {
                return DropdownMenuItem<int>(
                    value: count.value,
                    child: Text(
                        "count_words".tr.replaceOne(count.value.toString())));
              }).toList(),
              onChanged: model.updateMnemonicCount,
            ),
            WidgetConstant.height20,
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
            AnimatedSize(
              duration: AppGlobalConst.animationDuraion,
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: AppGlobalConst.animationDuraion,
                child: model.mnemonic == null
                    ? const SizedBox()
                    : SizedBox(
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
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        onPressed: () {
                          if (model.mnemonic == null) {
                            model.generate();
                          } else {
                            model.toConfirm();
                          }
                        },
                        child: model.mnemonic == null
                            ? Text("generate".tr)
                            : Text("v_mnemonic".tr)),
                  ],
                ),
                if (model.mnemonic != null)
                  TextButton(
                      onPressed: () {
                        model.generate();
                      },
                      child: Text("r_generate".tr))
              ],
            )
          ],
        );
      },
    );
  }
}

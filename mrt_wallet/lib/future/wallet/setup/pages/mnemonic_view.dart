import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class MnemonicView extends StatelessWidget {
  const MnemonicView({super.key, required this.mnemonic});
  final List<String> mnemonic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: WidgetConstant.border8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: WidgetConstant.border8,
        ),
        padding: WidgetConstant.padding10,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: List.generate(
              mnemonic.length,
              (index) => AnimatedSize(
                    duration: APPConst.animationDuraion,
                    child: Padding(
                      key: ValueKey<String>(mnemonic[index]),
                      padding: WidgetConstant.padding10,
                      child: Stack(
                        children: [
                          Chip(
                            elevation: 3,
                            padding: WidgetConstant.padding10,
                            backgroundColor: context.colors.primaryContainer,
                            label: Text(
                              mnemonic[index],
                            ),
                          ),
                          Badge.count(
                            count: index + 1,
                            backgroundColor: context.colors.tertiary,
                            textColor: context.colors.onTertiary,
                          )
                        ],
                      ),
                    ),
                  )),
        ),
      ),
    );
  }
}

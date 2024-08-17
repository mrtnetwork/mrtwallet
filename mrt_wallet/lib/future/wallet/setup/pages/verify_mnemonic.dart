import 'package:blockchain_utils/utils/compare/compare.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/constant/constant.dart';

import 'mnemonic_view.dart';

typedef OnValidateMnemonic = void Function(List<String>);

class VerifyMnemonicView extends StatefulWidget {
  const VerifyMnemonicView(
      {required this.mnemonic,
      required this.onValidate,
      this.submitText,
      super.key});
  final List<String> mnemonic;
  final OnValidateMnemonic onValidate;
  final String? submitText;
  @override
  State<VerifyMnemonicView> createState() => _VerifyMnemonicViewState();
}

class _VerifyMnemonicViewState extends State<VerifyMnemonicView>
    with SafeState {
  late final List<String> shuffleMnemonic = List<String>.from(widget.mnemonic)
    ..shuffle();

  late final List<SelectedMnemonic> inSelectMnemonic =
      List<SelectedMnemonic>.filled(
          widget.mnemonic.length, SelectedMnemonic.notSelected());
  bool equal = false;
  bool compelte = false;
  bool get wrongFilled => compelte && !equal;

  void isEqual() {
    equal = CompareUtils.iterableIsEqual(selectedMnemonic, widget.mnemonic);
    compelte = inSelectMnemonic.where((element) => element.selected).length ==
        inSelectMnemonic.length;
  }

  List<String> get selectedMnemonic =>
      inSelectMnemonic.map((e) => e.word ?? "").toList();
  final List<int> selectedIndex = [];
  void tap(int index) {
    try {
      if (selectedIndex.contains(index)) {
        final selcetIndex =
            inSelectMnemonic.indexWhere((element) => element.index == index);
        inSelectMnemonic[selcetIndex] = SelectedMnemonic.notSelected();
        selectedIndex.remove(index);

        return;
      }
      selectedIndex.add(index);
      final word = shuffleMnemonic.elementAt(index);
      final emptyIndex =
          inSelectMnemonic.indexWhere((element) => element.index == null);
      inSelectMnemonic[emptyIndex] = SelectedMnemonic.select(index, word);
    } finally {
      setState(() {
        isEqual();
      });
    }
  }

  void clear() {
    for (int i = 0; i < inSelectMnemonic.length; i++) {
      inSelectMnemonic[i] = SelectedMnemonic.notSelected();
    }
    selectedIndex.clear();
    isEqual();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _debugConfirm();
  }

  void _debugConfirm() {
    if (kDebugMode) {
      for (int i = 0; i < widget.mnemonic.length; i++) {
        inSelectMnemonic[i] = SelectedMnemonic.select(i, widget.mnemonic[i]);
      }
      isEqual();
      setState(() {});
    }
  }

  void validate() {
    if (!equal) return;
    widget.onValidate(selectedMnemonic);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
          title: "v_mnemonic".tr,
          body: LargeTextView(["v_mnemonic_desc".tr]),
        ),
        Align(
            alignment: Alignment.center,
            child: MnemonicView(mnemonic: selectedMnemonic)),
        WidgetConstant.height20,
        AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: equal
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: APPConst.double80,
                          color: ColorConst.green,
                        ),
                        FixedElevatedButton(
                            padding: WidgetConstant.paddingVertical20,
                            onPressed: validate,
                            child: Text(widget.submitText ?? "passphrase".tr)),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    PageTitleSubtitle(
                        title: "select_the_mnemonic".tr,
                        body: Text("select_mnemonic_desc".tr)),
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: WidgetConstant.border8),
                      child: Padding(
                        padding: WidgetConstant.padding10,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          children:
                              List.generate(shuffleMnemonic.length, (index) {
                            return Card(
                              surfaceTintColor: Colors.transparent,
                              color: selectedIndex.contains(index)
                                  ? context.colors.primaryFixed
                                  : null,
                              shape: RoundedRectangleBorder(
                                  borderRadius: WidgetConstant.border4,
                                  side: const BorderSide(width: 1)),
                              child: InkWell(
                                onTap: () {
                                  tap(index);
                                },
                                child: Padding(
                                    padding: WidgetConstant.padding20,
                                    child: Text(
                                      shuffleMnemonic[index],
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  selectedIndex.contains(index)
                                                      ? context
                                                          .colors.onPrimaryFixed
                                                      : null),
                                    )),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    ErrorTextContainer(
                        error: wrongFilled
                            ? "invalid_mnemonic_ordering".tr
                            : null),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FixedElevatedButton(
                            padding: WidgetConstant.paddingVertical40,
                            onPressed: clear,
                            child: Text("reset".tr))
                      ],
                    )
                  ],
                ),
        )
      ],
    );
  }
}

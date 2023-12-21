import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum AddressDerivationMode { hdWallet, importedKey }

typedef OnSelectDerivation = void Function(
    AddressDerivationMode mode, EncryptedCustomKey? selectedKey);

class SetupAddressDerivation extends StatefulWidget {
  const SetupAddressDerivation(this.onSelectDerivation, {super.key});
  final OnSelectDerivation onSelectDerivation;
  @override
  State<SetupAddressDerivation> createState() =>
      _SetupAddressDerivationViewState();
}

class _SetupAddressDerivationViewState extends State<SetupAddressDerivation>
    with SafeState {
  String? _error;
  final GlobalKey visibleContinue =
      GlobalKey(debugLabel: "visibleGenerateAddress");
  AddressDerivationMode? selectedDerivationMode;
  EncryptedCustomKey? selectedCustomKey;
  bool showCustomKes = false;
  bool showSetupPage = false;
  bool inAddressPage = false;

  void onChangeCustomKey(EncryptedCustomKey? newSelected) {
    selectedCustomKey = newSelected;
    if (selectedCustomKey != null && showCustomKes) {
      showSetupPage = true;
    } else {
      showSetupPage = false;
    }
    setState(() {});
  }

  late final Map<AddressDerivationMode, Widget> derivationModes = {
    AddressDerivationMode.hdWallet: Text("hd_wallet".tr),
    AddressDerivationMode.importedKey: Text("imported_key".tr)
  };

  void onChangeDerivationMode<T>(AddressDerivationMode? mode) async {
    if (mode == selectedDerivationMode) return;
    selectedDerivationMode = mode ?? selectedDerivationMode;
    _error = null;
    showCustomKes = false;
    showSetupPage = false;
    selectedCustomKey = null;

    try {
      if (selectedDerivationMode == AddressDerivationMode.importedKey) {
        if (customKeys.isEmpty) {
          _error = "empty_custom_key_desc".tr;
        } else {
          showCustomKes = true;
          selectedCustomKey = customKeys.first;
          showSetupPage = true;
        }
      } else {
        showSetupPage = true;
      }
      setState(() {});
    } finally {
      if (showSetupPage) {
        ensureKeyVisible(key: visibleContinue);
      }
    }
  }

  List<EncryptedCustomKey> customKeys = [];
  bool _inited = false;
  void _setupIAccount() {
    if (!_inited) {
      _inited = true;
      final model = context.watch<WalletProvider>(StateIdsConst.main);
      customKeys = model.getNetworkImportedKeys();
    }
  }

  @override
  void didChangeDependencies() {
    _setupIAccount();
    super.didChangeDependencies();
  }

  void onSubmitDerivation() {
    widget.onSelectDerivation(selectedDerivationMode!, selectedCustomKey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "select_derivation_type".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("select_derivation_desc".tr)],
            )),
        AppDropDownBottom<AddressDerivationMode>(
          items: derivationModes,
          onChanged: onChangeDerivationMode,
          label: "derivation_type".tr,
          value: selectedDerivationMode,
          error: _error,
        ),
        WidgetConstant.height20,
        AnimatedSize(
          duration: AppGlobalConst.animationDuraion,
          child: showCustomKes
              ? _SelectCustomKeys(
                  existsKeys: customKeys,
                  selectedKey: selectedCustomKey,
                  onChangeCustomKey: onChangeCustomKey,
                )
              : const SizedBox(),
        ),
        AnimatedSwitcher(
          duration: AppGlobalConst.animationDuraion,
          child: showSetupPage
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FixedElevatedButton(
                    padding: WidgetConstant.paddingVertical20,
                    onPressed: onSubmitDerivation,
                    key: visibleContinue,
                    child: Text("continue".tr),
                  )
                ])
              : const SizedBox(),
        )
      ],
    );
  }
}

typedef _OnChangeCustomKey = void Function(EncryptedCustomKey?);

class _SelectCustomKeys extends StatelessWidget {
  const _SelectCustomKeys(
      {required this.existsKeys,
      required this.selectedKey,
      required this.onChangeCustomKey});
  final List<EncryptedCustomKey> existsKeys;
  final EncryptedCustomKey? selectedKey;
  final _OnChangeCustomKey onChangeCustomKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "choose_public_key".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("generate_from_imported_keys".tr),
                WidgetConstant.height8,
                Text("select_imported_key_desc".tr),
                WidgetConstant.height8,
              ],
            )),
        Column(
          children: List.generate(existsKeys.length, (index) {
            return RadioListTile(
              value: existsKeys[index],
              groupValue: selectedKey,
              onChanged: onChangeCustomKey,
              title: OneLineTextWidget(existsKeys[index].publicKey),
              subtitle: Text("imported_at"
                  .tr
                  .replaceOne(existsKeys[index].created.toString())),
            );
          }),
        ),
      ],
    );
  }
}

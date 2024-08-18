import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/secure_state/secure_state.dart';
import 'package:mrt_wallet/future/wallet/security/security.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class ExportSeedView extends StatelessWidget {
  const ExportSeedView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.seed,
        onAccsess: (crendential, password, network) {
          return _ExportSeedView(
              mnemonic: crendential.first as AccessMnemonicResponse,
              password: password);
        },
        title: "export_mnemonic".tr,
        subtitle: PageTitleSubtitle(
            title: "export_mnemonic_desc".tr,
            body: Text("export_mnemonic_desc2".tr)));
  }
}

class _ExportSeedView extends StatefulWidget {
  const _ExportSeedView({required this.mnemonic, required this.password});
  final AccessMnemonicResponse mnemonic;
  final String password;

  @override
  State<_ExportSeedView> createState() => _ExportSeedViewState();
}

class _ExportSeedViewState extends State<_ExportSeedView>
    with SafeState, SecureState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "ExportSeedView");
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  late final String _mnemonic = widget.mnemonic.mnemonic.toStr();
  late final List<String> mnemonicList = widget.mnemonic.mnemonic.toList();
  bool _showMnemonic = false;

  void onChangeShowMnemonic() {
    _showMnemonic = !_showMnemonic;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => ConstraintsBoxView(
        alignment: Alignment.center,
        padding: WidgetConstant.paddingHorizontal20,
        child: AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: SingleChildScrollView(
            child: Column(
              children: [
                WidgetConstant.height20,
                PageTitleSubtitle(
                    title: "export_mnemonic_desc".tr,
                    body: LargeTextView([
                      "export_mnemonic_desc2".tr,
                      "mnemonic_security_des1".tr,
                      "mnemonic_security_des2".tr,
                      "mnemonic_security_des3".tr
                    ])),
                Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: APPConst.animationDuraion,
                      child: Container(
                        key: ValueKey<bool>(_showMnemonic),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: WidgetConstant.border8,
                        ),
                        foregroundDecoration: _showMnemonic
                            ? null
                            : BoxDecoration(
                                color: context.colors.secondary,
                                borderRadius: WidgetConstant.border8,
                              ),
                        child: Stack(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                  mnemonicList.length,
                                  (index) => Padding(
                                        padding: WidgetConstant.padding5,
                                        child: Stack(
                                          children: [
                                            Chip(
                                                padding:
                                                    WidgetConstant.padding10,
                                                label:
                                                    Text(mnemonicList[index])),
                                            Badge.count(count: index + 1),
                                          ],
                                        ),
                                      )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedSize(
                          duration: APPConst.animationDuraion,
                          child: _showMnemonic
                              ? const SizedBox()
                              : FilledButton.icon(
                                  onPressed: onChangeShowMnemonic,
                                  icon: const Icon(Icons.remove_red_eye),
                                  label: Text("show_mnemonic".tr)),
                        ),
                      ),
                    )
                  ],
                ),
                WidgetConstant.height20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CopyTextIcon(
                      dataToCopy: _mnemonic,
                      size: APPConst.double40,
                      isSensitive: true,
                    ),
                    WidgetConstant.width8,
                    IconButton(
                      icon: const Icon(Icons.qr_code, size: APPConst.double40),
                      onPressed: () {
                        context.openSliverDialog(
                            (ctx) => BarcodeView(
                                underBarcodeWidget: ErrorTextContainer(
                                    margin: WidgetConstant.paddingVertical10,
                                    error: "image_store_alert_keys".tr),
                                secure: true,
                                title: ContainerWithBorder(
                                    child: CopyTextIcon(
                                        dataToCopy: _mnemonic,
                                        isSensitive: true,
                                        widget: ObscureTextView(_mnemonic,
                                            maxLine: 5))),
                                barcodeData: _mnemonic),
                            "share_mnemonic".tr);
                      },
                    ),
                    WidgetConstant.width8,
                    FilledButton.icon(
                        label: Text("create_backup".tr),
                        onPressed: () {
                          context.openSliverDialog(
                              (ctx) => GenerateBackupView(
                                  data: _mnemonic,
                                  password: widget.password,
                                  type: MrtBackupTypes.mnemonic),
                              "backup_mnemonic".tr);
                        },
                        icon: const Icon(Icons.backup))
                  ],
                ),
                WidgetConstant.height20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

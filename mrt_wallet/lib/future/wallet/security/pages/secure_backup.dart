import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/backup/backup.dart';

class GenerateBackupView extends StatefulWidget {
  const GenerateBackupView(
      {super.key,
      required this.data,
      required this.password,
      required this.type,
      this.descriptions = const []});
  final String data;
  final String password;
  final List<Widget> descriptions;
  final MrtBackupTypes type;

  @override
  State<GenerateBackupView> createState() => _SecureBackupViewState();
}

class _SecureBackupViewState extends State<GenerateBackupView> with SafeState {
  bool get canUseKeyStore => widget.type == MrtBackupTypes.privatekey;

  bool useKeyStore = false;

  void onChangeUseKeystore(bool? _) {
    useKeyStore = !useKeyStore;
    updateState();
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  String? backup;
  void createBackup() async {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    progressKey.progressText("creating_backup_desc".tr, sliver: false);
    final MethodResult<String> result;
    if (widget.type == MrtBackupTypes.wallet) {
      result = await wallet.wallet.generateWalletBackup(widget.password);
    } else {
      result = await wallet.wallet.generateMrtBackup(
        data: widget.data,
        type: useKeyStore ? MrtBackupTypes.keystore : widget.type,
        password: widget.password,
      );
    }
    if (result.hasError) {
      progressKey.errorText(result.error?.tr ?? "");
    } else {
      backup = result.result;
      progressKey.success();
    }
  }

  final GlobalKey<StreamWidgetState> buttonState = GlobalKey();
  String? _shareError;

  void share() async {
    if (backup == null) return;
    if (_shareError != null) {
      _shareError = null;
      setState(() {});
    }
    buttonState.process();
    final result = await MethodUtils.call(() async {
      final name = "credentials_${StrUtils.toFileName(DateTime.now())}.txt";
      final toFile = await PlatformUtils.writeString(backup!, name);
      return await ShareUtils.shareFile(
        toFile,
        name,
        subject: "account credentials",
        mimeType: FileMimeTypes.textPlain,
      );
    });
    if (result.hasError || !result.result) {
      buttonState.error();
      _shareError = result.error?.tr;
      setState(() {});
    } else {
      buttonState.success();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "b_using_web3_secret_defination".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextAndLinkView(
                  text: "about_web3_secret_defination".tr,
                  url: LinkConst.aboutWeb3StorageDefination,
                ),
                WidgetConstant.height8,
                Text("backup_desc2".tr),
                WidgetConstant.height8,
                APPAnimatedSwitcher(enable: useKeyStore, widgets: {
                  true: (c) => Text("use_key_store_backup_desc".tr),
                  false: (c) => Text("mrt_backup_encoding_desc".tr,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.error)),
                }),
                if (widget.descriptions.isNotEmpty) ...[
                  WidgetConstant.height8,
                  ...widget.descriptions
                ]
              ],
            )),
        PageProgress(
            key: progressKey,
            backToIdle: APPConst.oneSecoundDuration,
            child: (c) => backup == null
                ? Column(
                    children: [
                      if (canUseKeyStore)
                        AppCheckListTile(
                          title: Text("generate_keystore".tr),
                          subtitle: Text("generate_keystore_desc".tr),
                          value: useKeyStore,
                          onChanged: onChangeUseKeystore,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FixedElevatedButton(
                            padding: WidgetConstant.paddingVertical40,
                            onPressed: createBackup,
                            child: Text("create_backup".tr),
                          )
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: WidgetConstant.border8,
                        ),
                        child: Padding(
                            padding: WidgetConstant.padding10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConstraintsBoxView(
                                    maxHeight: 100,
                                    child: SingleChildScrollView(
                                        child: SelectableText(backup!))),
                                WidgetConstant.height8,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    StreamWidget(
                                      buttonWidget: FilledButton.icon(
                                          onPressed: share,
                                          icon: const Icon(Icons.share),
                                          label: Text("share_as_file".tr)),
                                      backToIdle: APPConst.oneSecoundDuration,
                                      key: buttonState,
                                    ),
                                    WidgetConstant.width8,
                                    CopyTextIcon(
                                        isSensitive: false,
                                        dataToCopy: backup!,
                                        size: APPConst.double40),
                                  ],
                                ),
                              ],
                            )),
                      ),
                      ErrorTextContainer(
                          error: _shareError,
                          margin: WidgetConstant.paddingVertical10)
                    ],
                  ))
      ],
    );
  }
}

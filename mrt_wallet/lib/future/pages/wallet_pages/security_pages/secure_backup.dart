import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/file/file.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';

class SecureBackupView extends StatefulWidget {
  const SecureBackupView(
      {super.key,
      required this.data,
      required this.password,
      this.descriptions = const [],
      this.isWalletBackup = false});
  final String data;
  final String password;
  final List<Widget> descriptions;
  final bool isWalletBackup;

  @override
  State<SecureBackupView> createState() => _SecureBackupViewState();
}

class _SecureBackupViewState extends State<SecureBackupView> with SafeState {
  String? _error;
  SecretWalletEncoding encoding = SecretWalletEncoding.json;

  void onChangeEncoding(SecretWalletEncoding? updateEncoding) {
    encoding = updateEncoding ?? encoding;
    if (encoding != SecretWalletEncoding.json) {
      if (!widget.isWalletBackup) {
        _error = "encoding_desc".tr;
      }
    } else {
      _error = null;
    }
    setState(() {});
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  String? backup;
  void createBackup() async {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    progressKey.progressText("creating_backup_desc".tr, sliver: false);
    final result = widget.isWalletBackup
        ? await wallet.generateWalletBackup(widget.password, encoding)
        : await wallet.generateBackup(widget.data, widget.password, encoding);
    if (result?.hasError ?? true) {
      progressKey.errorText(result?.error?.tr ?? "");
    } else {
      backup = result!.result;
      progressKey.success();
    }
  }

  final GlobalKey<StreamWidgetState> buttomState = GlobalKey();
  String? _shareError;

  void share() async {
    if (backup == null) return;
    if (_shareError != null) {
      _shareError = null;
      setState(() {});
    }
    buttomState.process();
    final result = await MethodCaller.call(() async {
      final name = "credentials_${DateTime.now().toFileName()}.txt";
      final toFile = await CrossFileWriter.writeString(backup!, name);
      return await ShareUtility.shareFile(toFile, name,
          subject: "account credentials", mimeType: FileMimeTypes.textPlain);
    });

    if (result.hasError || !result.result) {
      buttomState.error();
      _shareError = result.error?.tr;
      setState(() {});
    } else {
      buttomState.success();
    }
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
                  url: AppLinkConst.aboutWeb3StorageDefination,
                ),
                WidgetConstant.height8,
                Text("backup_desc2".tr),
                ...widget.descriptions
              ],
            )),
        PageProgress(
            key: progressKey,
            backToIdle: AppGlobalConst.oneSecoundDuration,
            child: () => backup == null
                ? Column(
                    children: [
                      DropdownButtonFormField<SecretWalletEncoding>(
                        value: encoding,
                        decoration: InputDecoration(
                            label: Text("encoding".tr),
                            helperText: _error,
                            helperStyle: context.textTheme.bodySmall
                                ?.copyWith(color: context.colors.error),
                            helperMaxLines: 3),
                        items: SecretWalletEncoding.values.map((enc) {
                          return DropdownMenuItem<SecretWalletEncoding>(
                            value: enc,
                            child: Text(enc.name.camelCase),
                          );
                        }).toList(),
                        onChanged: onChangeEncoding,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FixedElevatedButton(
                            padding: WidgetConstant.paddingOnlyTop20,
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
                                      buttomWidget: FilledButton.icon(
                                          onPressed: share,
                                          icon: const Icon(Icons.share),
                                          label: Text("share_as_file".tr)),
                                      backToIdle:
                                          AppGlobalConst.oneSecoundDuration,
                                      key: buttomState,
                                    ),
                                    WidgetConstant.width8,
                                    CopyTextIcon(
                                        dataToCopy: backup!,
                                        size: AppGlobalConst.double40),
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

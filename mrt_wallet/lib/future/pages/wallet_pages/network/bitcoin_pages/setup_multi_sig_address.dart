import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/file/file.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SetupBitcoinMultiSigAddressView extends StatefulWidget {
  const SetupBitcoinMultiSigAddressView({super.key});

  @override
  State<SetupBitcoinMultiSigAddressView> createState() =>
      _SetupBitcoinMultiSigAddressViewState();
}

class _SetupBitcoinMultiSigAddressViewState
    extends State<SetupBitcoinMultiSigAddressView> with SafeState {
  final Map<String, BitcoinMultiSigSignerDetais> _signers = {};
  List<BitcoinMultiSigSignerDetais> get signers => _signers.values.toList();
  final GlobalKey visibleReview = GlobalKey();
  late final AppBitcoinNetwork network;
  String? _errorText;
  int? _thresHold;
  bool isValidThreshHold = false;
  bool isReady = false;
  bool signersReady = false;
  void onAddSigner(IBitcoinAddress? acc) {
    if (acc == null) return;
    if (acc.multiSigAccount) {
      context.showAlert("unavailable_multi_sig_public_key".tr);
      return;
    }
    final newAcc = BitcoinMultiSigSignerDetais(
        publicKey: acc.publicKey, keyIndex: acc.keyIndex);
    if (_signers.containsKey(newAcc.publicKey)) {
      context.showAlert("public_key_already_exist".tr);
      return;
    }
    _signers.addAll({newAcc.publicKey: newAcc});
    setState(() {});
  }

  void onRemoveAcc(BitcoinMultiSigSignerDetais acc) {
    final remove = _signers.remove(acc.publicKey);
    if (remove != null) {
      _validate();
    }
  }

  void onChangeSignerWeight(BitcoinMultiSigSignerDetais address, String v) {
    if (!_signers.containsKey(address.publicKey)) return;
    final weight = int.tryParse(v);
    if (weight == null) return;
    _signers[address.publicKey] = BitcoinMultiSigSignerDetais(
        publicKey: BytesUtils.fromHexString(address.publicKey),
        keyIndex: address.keyIndex,
        weight: weight);

    _validate();
  }

  bool showOnVisible = false;
  void _validate() {
    isValidThreshHold = isValid();

    final signerWeight = _signerWeight();
    signersReady = signerWeight != null;
    isReady = isValidThreshHold && signersReady && signerWeight! >= _thresHold!;
    if (isValidThreshHold && signersReady && !isReady) {
      _errorText = "threshhold_desc3".tr;
    }
    setState(() {});
    if (isReady && !showOnVisible) {
      ensureKeyVisible(
        key: visibleReview,
        onScroll: () {
          showOnVisible = true;
        },
      );
    }
  }

  void onChangeThreshHold(String v) {
    _thresHold = int.tryParse(v);
    _validate();
  }

  int? _signerWeight() {
    if (!isValidThreshHold) return null;
    if (signers.isEmpty) return null;
    int sum = 0;
    for (final i in signers) {
      if (i.weight > _thresHold!) {
        return null;
      } else if (i.weight < 1) {
        return null;
      }
      sum += i.weight;
    }
    return sum;
  }

  bool isValid() => _thresHold != null && _thresHold! >= 2 && _thresHold! <= 16;
  bool inReview = false;
  final Map<BitcoinAddressType, String> supportedMultisigTypes = {};
  late final NetworkAccountCore account;
  BitcoinAddressType multiSigAddressTye = BitcoinAddressType.p2pkhInP2sh;
  BitcoinMultiSignatureAddress? _multiSigAddress;
  MultiSignatureAddress get multiSigAddress => _multiSigAddress!;
  BitcoinAddress get bitcoinAddress {
    switch (multiSigAddressTye) {
      case BitcoinAddressType.p2wsh:
        return multiSigAddress.toP2wshAddress(
            network: network.coinParam.transacationNetwork);
      case BitcoinAddressType.p2pkhInP2sh:
        return multiSigAddress.toP2shAddress();
      default:
        return multiSigAddress.toP2wshInP2shAddress(
            network: network.coinParam.transacationNetwork);
    }
  }

  late String? _multiSigViewAddress;
  void _toMultiSigAddress() {
    _multiSigViewAddress =
        bitcoinAddress.toAddress(network.coinParam.transacationNetwork);
  }

  void onReview() {
    if (!isReady) return;
    _multiSigAddress = BitcoinMultiSignatureAddress(
        threshold: _thresHold!,
        signers: signers,
        addressType: multiSigAddressTye);
    _toMultiSigAddress();
    inReview = true;
    setState(() {});
  }

  void _onBack() {
    try {
      if (progressKey.isSuccess) return;
      if (!inReview) return;
      inReview = false;

      _multiSigAddress = null;
      _multiSigViewAddress = null;
    } finally {
      setState(() {});
    }
  }

  void onChangeAddressType(BitcoinAddressType? selectType) {
    if (selectType == null || multiSigAddressTye == selectType) return;
    multiSigAddressTye = selectType;
    _toMultiSigAddress();
    setState(() {});
  }

  String get toText {
    String backup = "Address: $_multiSigViewAddress\n";
    backup += "=====================================\n";
    backup += "Type: ${multiSigAddressTye.value}\n";
    backup += "Threshold: ${multiSigAddress.threshold}\n";
    backup += "=====================================\n";
    backup += "Public keys and weight:\n";

    for (final i in signers) {
      backup +=
          "Public key: ${i.publicKey}\nWeight:${i.weight}\nHd Wallet path: ${i.path}\n";
      backup += "=====================================\n";
    }
    backup += "Script details:\n";
    backup +=
        "multisig Script: ${multiSigAddress.multiSigScript.script.join(" ")}\n";
    backup +=
        "multisig Script in hex: ${multiSigAddress.multiSigScript.toHex()}\n";
    backup +=
        "Script pub key of address: ${bitcoinAddress.toScriptPubKey().script.join(" ")}\n";
    backup +=
        "Script pub key of address in hex: ${bitcoinAddress.toScriptPubKey().toHex()}\n";
    backup += "=====================================\n";

    return backup;
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "SetupBitcoinMultiSigAddressView");

  void onSetupAddress() async {
    progressKey.progressText("setup_address".tr);

    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final accountParams = await MethodCaller.call(() async {
      final network = wallet.network as AppBitcoinNetwork;
      final newAccountParams = BitcoinMultiSigNewAddressParams(
          coin: network.findCOinFromBitcoinAddressType(multiSigAddressTye),
          bitcoinAddressType: multiSigAddressTye,
          multiSignatureAddress: _multiSigAddress!);
      return newAccountParams;
    });
    if (accountParams.hasError) {
      progressKey.errorText(accountParams.error!.tr);
    } else {
      final result = await wallet.deriveNewAccount(accountParams.result);
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        progressKey.successText("address_added_to_accounts".tr,
            backToIdle: false);
      }
    }
    setState(() {});
  }

  final GlobalKey<StreamWidgetState> buttomState = GlobalKey();
  String? _shareError;
  void share() async {
    if (_shareError != null) {
      _shareError = null;
      setState(() {});
    }
    buttomState.process();
    final result = await MethodCaller.call(() async {
      final name =
          "credentials_${_multiSigViewAddress}_${DateTime.now().toFileName()}.txt";
      final toFile = await CrossFileWriter.writeString(toText, name);
      return await ShareUtility.shareFile(toFile, name,
          subject: "account credentials");
    });

    if (result.hasError || !result.result) {
      buttomState.error();
      _shareError = result.error?.tr;
    } else {
      buttomState.success();
    }
    setState(() {});
  }

  bool _init = false;
  void init() {
    if (_init) return;
    _init = true;
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    network = wallet.network as AppBitcoinNetwork;
    account = wallet.networkAccount;
    supportedMultisigTypes[BitcoinAddressType.p2pkhInP2sh] = "P2SH";
    if (network.coinParam.transacationNetwork.supportedAddress
        .contains(BitcoinAddressType.p2wpkh)) {
      supportedMultisigTypes[BitcoinAddressType.p2wshInP2sh] =
          BitcoinAddressType.p2wshInP2sh.value;
      supportedMultisigTypes[BitcoinAddressType.p2wsh] =
          BitcoinAddressType.p2wsh.value;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: progressKey.isSuccess || !inReview,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _onBack();
        }
      },
      child: ScaffolPageView(
          appBar: AppBar(title: Text("multi_sig_addr".tr)),
          child: UnfocusableChild(
            child: PageProgress(
              key: progressKey,
              backToIdle: AppGlobalConst.oneSecoundDuration,
              child: () => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                      padding: WidgetConstant.padding20,
                      child: AnimatedSwitcher(
                        duration: AppGlobalConst.animationDuraion,
                        child: inReview
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                key: const ValueKey<bool>(true),
                                children: [
                                  PageTitleSubtitle(
                                      title: "review_address".tr,
                                      body: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("review_address_desc".tr),
                                        ],
                                      )),
                                  Text("type_of_address".tr,
                                      style: context.textTheme.titleMedium),
                                  WidgetConstant.height8,
                                  Column(
                                    children: List.generate(
                                        supportedMultisigTypes.length, (index) {
                                      final supportTypes =
                                          supportedMultisigTypes.keys.toList();
                                      return RadioListTile(
                                          title:
                                              Text(supportTypes[index].value),
                                          value: supportTypes[index],
                                          groupValue: multiSigAddressTye,
                                          onChanged: onChangeAddressType);
                                    }),
                                  ),
                                  AnimatedSwitcher(
                                    duration: AppGlobalConst.animationDuraion,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      key: ValueKey(multiSigAddressTye),
                                      children: [
                                        WidgetConstant.height20,
                                        Text("address".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        ContainerWithBorder(
                                            child: CopyTextIcon(
                                          widget: SelectableText(
                                              _multiSigViewAddress!),
                                          dataToCopy: _multiSigViewAddress!,
                                        )),
                                        WidgetConstant.height20,
                                        Text(
                                            "public_keys_and_weight_of_each".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        Column(
                                          children: List.generate(
                                              signers.length, (index) {
                                            return ContainerWithBorder(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("publick_key".tr,
                                                    style: context
                                                        .textTheme.labelLarge),
                                                OneLineTextWidget(
                                                    signers[index].publicKey),
                                                WidgetConstant.height8,
                                                Text("weight".tr,
                                                    style: context
                                                        .textTheme.labelLarge),
                                                Text(signers[index]
                                                    .weight
                                                    .toString()),
                                              ],
                                            ));
                                          }),
                                        ),
                                        WidgetConstant.height20,
                                        Text("threshold".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        ContainerWithBorder(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_thresHold!.toString()),
                                          ],
                                        )),
                                        WidgetConstant.height20,
                                        Text("multi_sig_script".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        ContainerWithBorder(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(multiSigAddress
                                                .multiSigScript.script
                                                .join(" ")),
                                          ],
                                        )),
                                        WidgetConstant.height20,
                                        Text("address_script".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        ContainerWithBorder(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(bitcoinAddress
                                                .toScriptPubKey()
                                                .script
                                                .join(" ")),
                                          ],
                                        )),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FixedElevatedButton(
                                              padding: WidgetConstant
                                                  .paddingVertical20,
                                              onPressed: onSetupAddress,
                                              child: Text("setup_address".tr),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            FilledButton.icon(
                                              icon: const Icon(Icons.backup),
                                              label: Text("backup_as_text".tr),
                                              onPressed: () {
                                                context.openSliverDialog(
                                                    (ctx) => Column(
                                                          children: [
                                                            PageTitleSubtitle(
                                                                title:
                                                                    "address_details2"
                                                                        .tr,
                                                                body: Text(
                                                                    "address_backup_desc1"
                                                                        .tr)),
                                                            WidgetConstant
                                                                .height8,
                                                            ContainerWithBorder(
                                                                child:
                                                                    ConstraintsBoxView(
                                                              maxHeight: 200,
                                                              child:
                                                                  SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.vertical,
                                                                child:
                                                                    SelectableText(
                                                                        toText),
                                                              ),
                                                            )),
                                                            WidgetConstant
                                                                .height20,
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                StreamWidget(
                                                                  buttomWidget: FilledButton.icon(
                                                                      onPressed:
                                                                          share,
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .share),
                                                                      label: Text(
                                                                          "share_as_file"
                                                                              .tr)),
                                                                  backToIdle:
                                                                      AppGlobalConst
                                                                          .oneSecoundDuration,
                                                                  key:
                                                                      buttomState,
                                                                ),
                                                                WidgetConstant
                                                                    .width8,
                                                                CopyTextIcon(
                                                                    dataToCopy:
                                                                        toText,
                                                                    size: AppGlobalConst
                                                                        .double40),
                                                              ],
                                                            ),
                                                            ErrorTextContainer(
                                                                error:
                                                                    _shareError,
                                                                margin: WidgetConstant
                                                                    .paddingVertical10)
                                                          ],
                                                        ),
                                                    "address_details".tr);
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PageTitleSubtitle(
                                      title: "establishing_multi_sig_addr".tr,
                                      body: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("multi_sig_desc".tr),
                                          WidgetConstant.height8,
                                          Text("mutli_sig_desc2".tr),
                                          WidgetConstant.height8,
                                          Text("multi_sig_desc3".tr),
                                          WidgetConstant.height8,
                                          Text("multi_sig_desc4".tr),
                                          WidgetConstant.height8,
                                        ],
                                      )),
                                  Text("list_of_public_keys".tr,
                                      style: context.textTheme.titleMedium),
                                  Text("multi_sig_desc5".tr),
                                  WidgetConstant.height8,
                                  ContainerWithBorder(
                                      validate: _signers.isNotEmpty,
                                      onRemoveIcon: const Icon(Icons.add),
                                      onRemove: () {
                                        context
                                            .openSliverBottomSheet<
                                                IBitcoinAddress>(
                                              "select_account".tr,
                                              minExtent: 0.5,
                                              child: SwitchOrSelectAccountView(
                                                  account: account),
                                              maxExtend: 0.9,
                                              initialExtend: 0.7,
                                            )
                                            .then(onAddSigner);
                                      },
                                      child: Text("tap_to_select".tr)),
                                  AnimatedSize(
                                    duration: AppGlobalConst.animationDuraion,
                                    child: Column(
                                      key: ValueKey<int>(signers.length),
                                      children: List.generate(signers.length,
                                          (index) {
                                        return ContainerWithBorder(
                                            onRemove: () {
                                              onRemoveAcc(signers[index]);
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(signers[index].path,
                                                    style: context
                                                        .textTheme.labelLarge),
                                                OneLineTextWidget(
                                                    signers[index].publicKey)
                                              ],
                                            ));
                                      }),
                                    ),
                                  ),
                                  WidgetConstant.height20,
                                  Text("threshold_configuration".tr,
                                      style: context.textTheme.titleMedium),
                                  Text("threshhold_desc".tr),
                                  WidgetConstant.height8,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: NumberTextField(
                                          label: "threshold".tr,
                                          disableWriting: true,
                                          onChange: onChangeThreshHold,
                                          max: 16,
                                          min: 2,
                                          defaultValue: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedSize(
                                    duration: AppGlobalConst.animationDuraion,
                                    child: isValidThreshHold
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              WidgetConstant.height20,
                                              Text(
                                                  "signers_weight_configuration"
                                                      .tr,
                                                  style: context
                                                      .textTheme.titleMedium),
                                              Text("signer_wight_desc1".tr),
                                              WidgetConstant.height8,
                                              Column(
                                                children: List.generate(
                                                    signers.length,
                                                    (index) =>
                                                        ContainerWithBorder(
                                                            validate: signers[
                                                                            index]
                                                                        .weight >=
                                                                    1 &&
                                                                signers[index]
                                                                        .weight <=
                                                                    _thresHold!,
                                                            validateText:
                                                                "threshhold_desc2"
                                                                    .tr,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    signers[index]
                                                                        .path,
                                                                    style: context
                                                                        .textTheme
                                                                        .labelLarge),
                                                                OneLineTextWidget(
                                                                    signers[index]
                                                                        .publicKey),
                                                                WidgetConstant
                                                                    .height8,
                                                                NumberTextField(
                                                                    label:
                                                                        "weight"
                                                                            .tr,
                                                                    disableWriting:
                                                                        true,
                                                                    onChange:
                                                                        (p0) {
                                                                      onChangeSignerWeight(
                                                                          signers[
                                                                              index],
                                                                          p0);
                                                                    },
                                                                    max:
                                                                        _thresHold ??
                                                                            0,
                                                                    min: 1)
                                                              ],
                                                            ))),
                                              )
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: AnimatedSize(
                                          duration:
                                              AppGlobalConst.animationDuraion,
                                          child: isReady
                                              ? FixedElevatedButton(
                                                  padding: WidgetConstant
                                                      .paddingVertical20,
                                                  onPressed:
                                                      isReady ? onReview : null,
                                                  key: visibleReview,
                                                  child:
                                                      Text("review_address".tr),
                                                )
                                              : ErrorTextContainer(
                                                  error: _errorText),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

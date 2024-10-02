import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/bitcoin/bitcoin.dart';

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
  WalletBitcoinNetwork get network => chainAccount.network;

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
        publicKey: acc.publicKey, keyIndex: acc.keyIndex as Bip32AddressIndex);
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

  void onChangeSignerWeight(BitcoinMultiSigSignerDetais address, int weight) {
    if (!_signers.containsKey(address.publicKey)) return;
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
      visibleReview.ensureKeyVisible(
        onScroll: () {
          showOnVisible = true;
        },
      );
    }
  }

  void onChangeThreshHold(int v) {
    _thresHold = v;
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
  late final BitcoinChain chainAccount;
  BitcoinAddressType multiSigAddressTye = P2shAddressType.p2pkhInP2sh;
  BitcoinMultiSignatureAddress? _multiSigAddress;
  MultiSignatureAddress get multiSigAddress => _multiSigAddress!;
  BitcoinBaseAddress get bitcoinAddress {
    switch (multiSigAddressTye) {
      case SegwitAddresType.p2wsh:
        return multiSigAddress.toP2wshAddress(
            network: network.coinParam.transacationNetwork);
      case P2shAddressType.p2pkhInP2sh:
      case P2shAddressType.p2pkhInP2sh32:
      case P2shAddressType.p2pkhInP2shwt:
      case P2shAddressType.p2pkhInP2sh32wt:
        return multiSigAddress
            .toP2shAddress(multiSigAddressTye as P2shAddressType);
      default:
        return multiSigAddress.toP2wshInP2shAddress(
            network: network.coinParam.transacationNetwork);
    }
  }

  late String? _multiSigViewAddress;
  void _toMultiSigAddress() {
    _multiSigViewAddress =
        bitcoinAddress.toAddress(network.coinParam.transacationNetwork);
    setState(() {});
  }

  void onReview() {
    if (!isReady) return;
    _multiSigAddress = BitcoinMultiSignatureAddress(
        threshold: _thresHold!,
        signers: signers,
        addressType: multiSigAddressTye);
    inReview = true;
    _toMultiSigAddress();
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

  void onSetupAddress(bool? accept) async {
    if (accept != true) return;
    progressKey.progressText("setup_address".tr);

    final wallet = context.watch<WalletProvider>(StateConst.main).wallet;
    final accountParams = await MethodUtils.call(() async {
      final NewAccountParams newAccountParams;
      if (network.type == NetworkType.bitcoinCash) {
        newAccountParams = BitcoinCashMultiSigNewAddressParams(
            coin: network.findCOinFromBitcoinAddressType(multiSigAddressTye),
            bitcoinAddressType: multiSigAddressTye,
            multiSignatureAddress: _multiSigAddress!);
      } else {
        newAccountParams = BitcoinMultiSigNewAddressParams(
            coin: network.findCOinFromBitcoinAddressType(multiSigAddressTye),
            bitcoinAddressType: multiSigAddressTye,
            multiSignatureAddress: _multiSigAddress!);
      }
      return newAccountParams;
    });
    if (accountParams.hasError) {
      progressKey.errorText(accountParams.error!.tr);
    } else {
      final result = await wallet.deriveNewAccount(
          newAccountParams: accountParams.result, chain: chainAccount);
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        progressKey.success(
            backToIdle: false,
            progressWidget: SuccessWithButtonView(
              buttonWidget: ContainerWithBorder(
                  margin: WidgetConstant.paddingVertical8,
                  child: AddressDetailsView(address: result.result)),
              buttonText: "generate_new_address".tr,
              onPressed: () {
                if (mounted) {
                  progressKey.backToIdle();
                }
              },
            ));
      }
    }
    setState(() {});
  }

  final GlobalKey<StreamWidgetState> buttonState = GlobalKey();
  String? _shareError;
  void share() async {
    if (_shareError != null) {
      _shareError = null;
      setState(() {});
    }
    buttonState.process();
    final result = await MethodUtils.call(() async {
      final name =
          "credentials_${_multiSigViewAddress}_${StrUtils.toFileName(DateTime.now())}.txt";
      final toFile = await PlatformUtils.writeString(toText, name);
      return await ShareUtils.shareFile(
        toFile,
        name,
        subject: "account credentials",
      );
    });

    if (result.hasError || !result.result) {
      buttonState.error();
      _shareError = result.error?.tr;
    } else {
      buttonState.success();
    }
    setState(() {});
  }

  bool _init = false;
  void init() {
    if (_init) return;
    _init = true;
    chainAccount = context.getArgruments();

    final List<BitcoinAddressType> supportTyes =
        network.coinParam.transacationNetwork.supportedAddress;

    supportedMultisigTypes[P2shAddressType.p2pkhInP2sh] = "P2SH";
    if (supportTyes.contains(P2shAddressType.p2pkhInP2sh32)) {
      supportedMultisigTypes[P2shAddressType.p2pkhInP2shwt] =
          P2shAddressType.p2pkhInP2shwt.value;
      supportedMultisigTypes[P2shAddressType.p2pkhInP2sh32] =
          P2shAddressType.p2pkhInP2sh32.value;
      supportedMultisigTypes[P2shAddressType.p2pkhInP2sh32wt] =
          P2shAddressType.p2pkhInP2sh32wt.value;
    }
    if (supportTyes.contains(SegwitAddresType.p2wpkh)) {
      supportedMultisigTypes[P2shAddressType.p2wshInP2sh] =
          P2shAddressType.p2wshInP2sh.value;
      supportedMultisigTypes[SegwitAddresType.p2wsh] =
          SegwitAddresType.p2wsh.value;
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
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onBack();
        }
      },
      child: ScaffolPageView(
          appBar: AppBar(title: Text("multi_sig_addr".tr)),
          child: UnfocusableChild(
            child: PageProgress(
              key: progressKey,
              backToIdle: APPConst.oneSecoundDuration,
              child: (c) => Center(
                child: CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    SliverToBoxAdapter(
                      child: ConstraintsBoxView(
                        padding: WidgetConstant.padding20,
                        child: AnimatedSwitcher(
                          duration: APPConst.animationDuraion,
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
                                    ...List.generate(
                                        supportedMultisigTypes.length, (index) {
                                      final supportTypes =
                                          supportedMultisigTypes.keys.toList();
                                      return RadioListTile(
                                          title:
                                              Text(supportTypes[index].value),
                                          subtitle: Text(
                                              BTCUtils.getAddressDetails(
                                                  supportTypes[index])),
                                          value: supportTypes[index],
                                          groupValue: multiSigAddressTye,
                                          onChanged: onChangeAddressType);
                                    }),
                                    AnimatedSwitcher(
                                      duration: APPConst.animationDuraion,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        key: ValueKey<BitcoinAddressType>(
                                            multiSigAddressTye),
                                        children: [
                                          WidgetConstant.height20,
                                          Text("address".tr,
                                              style: context
                                                  .textTheme.titleMedium),
                                          WidgetConstant.height8,
                                          ContainerWithBorder(
                                              child: CopyTextIcon(
                                            isSensitive: false,
                                            widget: SelectableText(
                                                _multiSigViewAddress!),
                                            dataToCopy: _multiSigViewAddress!,
                                          )),
                                          WidgetConstant.height20,
                                          Text(
                                              "public_keys_and_weight_of_each"
                                                  .tr,
                                              style: context
                                                  .textTheme.titleMedium),
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
                                                      style: context.textTheme
                                                          .labelLarge),
                                                  OneLineTextWidget(
                                                      signers[index].publicKey),
                                                  WidgetConstant.height8,
                                                  Text("weight".tr,
                                                      style: context.textTheme
                                                          .labelLarge),
                                                  Text(signers[index]
                                                      .weight
                                                      .toString()),
                                                ],
                                              ));
                                            }),
                                          ),
                                          WidgetConstant.height20,
                                          Text("threshold".tr,
                                              style: context
                                                  .textTheme.titleMedium),
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
                                              style: context
                                                  .textTheme.titleMedium),
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
                                              style: context
                                                  .textTheme.titleMedium),
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
                                                onPressed: () {
                                                  context
                                                      .openSliverDialog<bool>(
                                                          (p0) =>
                                                              DialogTextView(
                                                                text:
                                                                    "backup_multi_sig_address_desc"
                                                                        .tr,
                                                                buttonWidget:
                                                                    const DialogDoubleButtonView(),
                                                              ),
                                                          "backup".tr)
                                                      .then(onSetupAddress);
                                                },
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
                                                label:
                                                    Text("backup_as_text".tr),
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
                                                                    buttonWidget: FilledButton.icon(
                                                                        onPressed:
                                                                            share,
                                                                        icon: const Icon(Icons
                                                                            .share),
                                                                        label: Text(
                                                                            "share_as_file".tr)),
                                                                    backToIdle:
                                                                        APPConst
                                                                            .oneSecoundDuration,
                                                                    key:
                                                                        buttonState,
                                                                  ),
                                                                  WidgetConstant
                                                                      .width8,
                                                                  CopyTextIcon(
                                                                      isSensitive:
                                                                          false,
                                                                      dataToCopy:
                                                                          toText,
                                                                      size: APPConst
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
                                        body: LargeTextView([
                                          "multi_sig_desc".tr,
                                          "mutli_sig_desc2".tr,
                                          "multi_sig_desc3".tr,
                                          "multi_sig_desc4".tr
                                        ])),
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
                                                child:
                                                    SwitchOrSelectAccountView(
                                                  account: chainAccount,
                                                  showMultiSig: false,
                                                ),
                                                maxExtend: 0.9,
                                                initialExtend: 0.7,
                                                centerContent: false,
                                              )
                                              .then(onAddSigner);
                                        },
                                        child: Text("tap_to_select".tr)),
                                    AnimatedSize(
                                      duration: APPConst.animationDuraion,
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
                                                      style: context.textTheme
                                                          .labelLarge),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      duration: APPConst.animationDuraion,
                                      child:
                                          isValidThreshHold &&
                                                  signers.isNotEmpty
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    WidgetConstant.height20,
                                                    Text(
                                                        "signers_weight_configuration"
                                                            .tr,
                                                        style: context.textTheme
                                                            .titleMedium),
                                                    LargeTextView([
                                                      "signer_wight_desc1".tr
                                                    ]),
                                                    WidgetConstant.height8,
                                                    Column(
                                                      children: List.generate(
                                                          signers.length,
                                                          (index) =>
                                                              ContainerWithBorder(
                                                                  validate: signers[index]
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
                                                                          label: "weight"
                                                                              .tr,
                                                                          disableWriting:
                                                                              true,
                                                                          onChange:
                                                                              (p0) {
                                                                            onChangeSignerWeight(signers[index],
                                                                                p0);
                                                                          },
                                                                          max: _thresHold ??
                                                                              0,
                                                                          min:
                                                                              1)
                                                                    ],
                                                                  ))),
                                                    )
                                                  ],
                                                )
                                              : const SizedBox(),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: AnimatedSize(
                                            duration: APPConst.animationDuraion,
                                            child: isReady
                                                ? FixedElevatedButton(
                                                    padding: WidgetConstant
                                                        .paddingVertical20,
                                                    onPressed: isReady
                                                        ? onReview
                                                        : null,
                                                    key: visibleReview,
                                                    child: Text(
                                                        "review_address".tr),
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
            ),
          )),
    );
  }
}

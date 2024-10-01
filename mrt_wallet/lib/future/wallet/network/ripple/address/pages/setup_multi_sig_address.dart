import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/constant/constant.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum _MultiSigPage { account, info }

enum _MultiSigType { regularKey, signerList }

class SetupRippleMutlisigAddressView extends StatelessWidget {
  const SetupRippleMutlisigAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialPageView(
      child: ScaffolPageView(
        appBar: AppBar(title: Text("multi_sig_addr".tr)),
        child: _SetupRippleMutlisigAddressView(context.getArgruments()),
      ),
    );
  }
}

class _SetupRippleMutlisigAddressView extends StatefulWidget {
  const _SetupRippleMutlisigAddressView(this.account);
  final RippleChain account;
  @override
  State<_SetupRippleMutlisigAddressView> createState() =>
      _SetupRippleMutlisigAddressViewState();
}

class _SetupRippleMutlisigAddressViewState
    extends State<_SetupRippleMutlisigAddressView> with SafeState {
  late WalletProvider wallet;
  final Map<AccountObjectSignerEntry, RippleMultiSigSignerDetails?> signers =
      {};
  int sumOfWeight = 0;
  bool get sigerListIsReady => sumOfWeight >= signerList!.signerQuorum;

  void onAddSigner(IXRPAddress? acc, AccountObjectSignerEntry signer) {
    try {
      if (acc == null) {
        signers[signer] = null;
        return;
      }
      if (acc.multiSigAccount) {
        context.showAlert("unavailable_multi_sig_public_key".tr);
        return;
      }
      if (acc.networkAddress.toString() != signer.account) {
        context.showAlert("account_does_not_match_with_signer_account".tr);
        return;
      }
      if (signers[signer] != null) {
        context.showAlert("address_already_exist".tr);
        return;
      }

      final newAcc = RippleMultiSigSignerDetails(
          publicKey: acc.publicKey,
          keyIndex: acc.keyIndex as Bip32AddressIndex,
          weight: signer.signerWeight);

      signers.addAll({signer: newAcc});
    } finally {
      sumOfWeight = signers.values.fold<int>(0,
          (previousValue, element) => previousValue + (element?.weight ?? 0));
      setState(() {});
    }
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  _MultiSigPage page = _MultiSigPage.account;
  bool get inInfoPage => page == _MultiSigPage.info;
  _MultiSigType? addressType;
  ReceiptAddress? address;
  void onSelectAddress(ReceiptAddress? newAddr) {
    address = newAddr;
    setState(() {});
  }

  String? regularKey;
  XRPAccountObjectEntry? signerList;
  bool get hasRegularKey => pickedRegular != null;
  RippleMultiSignatureAddress? pickedRegular;
  WalletXRPNetwork get network => widget.account.network;

  void onAccountInformation() async {
    if (address == null || progressKey.inProgress) return;
    progressKey.progressText("retrieving_account_information".tr);
    final result = await MethodUtils.call(() async {
      final account = await widget.account
          .provider()!
          .getAccountRegularAndSignerList(
              RippleUtils.ensureClassicAddress(address!.view));
      return account;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else if (result.result == null) {
      progressKey.errorText("ripple_mutlti_sig_address_not_found".tr);
    } else {
      page = _MultiSigPage.info;
      regularKey = result.result!.$1;
      signerList = result.result!.$2;
      if (signerList != null) {
        for (final i in signerList!.signerEntries) {
          signers[i] = null;
        }
      }

      progressKey.success();
    }
  }

  void onCheckRegularKey(IXRPAddress? addr) {
    if (addr == null || regularKey == null) return;
    if (addr.multiSigAccount) {
      context.showAlert("unavailable_multi_sig_public_key".tr);
      return;
    }
    if (addr.networkAddress.toString() != regularKey) {
      context.showAlert("account_does_not_match_with_signer_account".tr);
      return;
    }
    pickedRegular = RippleMultiSignatureAddress(
        threshold: 1,
        signers: [
          RippleMultiSigSignerDetails(
              keyIndex: addr.keyIndex as Bip32AddressIndex,
              publicKey: addr.publicKey,
              weight: 1)
        ],
        isRegularKey: true);
    setState(() {});
  }

  void onBack() {
    page = _MultiSigPage.account;
    setState(() {});
  }

  void onSetupRegularKey() async {
    if (!hasRegularKey) return;
    progressKey.progressText("setup_address".tr);
    final rippleAddress = XRPAddress(address!.view);
    final addrParam = RippleMultiSigNewAddressParams(
      coin: network.coins.first,
      masterAddress: rippleAddress,
      tag: rippleAddress.tag,
      multiSigAccount: pickedRegular!,
    );
    final result = await wallet.wallet
        .deriveNewAccount(newAccountParams: addrParam, chain: widget.account);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText("address_added_to_accounts".tr,
          backToIdle: false);
    }
  }

  void onSetupSignerList() async {
    progressKey.progressText("setup_address".tr);
    final wallet = context.watch<WalletProvider>(StateConst.main).wallet;
    final accountParams = await MethodUtils.call(() async {
      final rippleAddress =
          XRPAddress(address!.view, isTestnet: !network.coinParam.mainnet);
      final newAccountParams = RippleMultiSigNewAddressParams(
        coin: network.coins.first,
        masterAddress: rippleAddress,
        tag: rippleAddress.tag,
        multiSigAccount: RippleMultiSignatureAddress(
            signers: signers.values
                .where((element) => element != null)
                .toList()
                .cast(),
            threshold: signerList!.signerQuorum,
            isRegularKey: false),
      );
      return newAccountParams;
    });
    if (accountParams.hasError) {
      progressKey.errorText(accountParams.error!.tr);
    } else {
      final result = await wallet.deriveNewAccount(
          newAccountParams: accountParams.result, chain: widget.account);
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        progressKey.success(
            backToIdle: false,
            progressWidget: SuccessWithButtonView(
              buttonWidget: ContainerWithBorder(
                  margin: WidgetConstant.paddingVertical8,
                  child: AddressDetailsView(address: result.result)),
              buttonText: "close".tr,
              onPressed: () {
                if (mounted) {
                  context.pop();
                }
              },
            ));
      }
    }
    setState(() {});
  }

  void onChangeType(_MultiSigType? type) {
    addressType = type;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    wallet = context.watch<WalletProvider>(StateConst.main);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: progressKey.isSuccess || !inInfoPage,
      onPopInvokedWithResult: (didPop, _) {
        if (inInfoPage) onBack();
      },
      child: PageProgress(
        key: progressKey,
        backToIdle: APPConst.oneSecoundDuration,
        initialStatus: PageProgressStatus.idle,
        child: (c) => UnfocusableChild(
          child: Center(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                        padding: WidgetConstant.paddingHorizontal20,
                        child: AnimatedSwitcher(
                            duration: APPConst.animationDuraion,
                            child: AnimatedSwitcher(
                              duration: APPConst.animationDuraion,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetConstant.height20,
                                  PageTitleSubtitle(
                                      title: "multi_sig_addr".tr,
                                      body: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("ripple_multi_sig_address_desc"
                                              .tr),
                                          if (inInfoPage) ...[
                                            WidgetConstant.height8,
                                            Text(
                                                "ripple_multi_sig_address_desc2"
                                                    .tr)
                                          ]
                                        ],
                                      )),
                                  inInfoPage
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          key: ValueKey(page),
                                          children: [
                                            Text("multi_sig_feature_type".tr,
                                                style: context
                                                    .textTheme.titleMedium),
                                            WidgetConstant.height8,
                                            RadioListTile<_MultiSigType>(
                                                title: Text("regular_key".tr),
                                                value: _MultiSigType.regularKey,
                                                groupValue: addressType,
                                                subtitle: regularKey == null
                                                    ? Text(
                                                        "account_does_not_support_feature"
                                                            .tr)
                                                    : null,
                                                onChanged: regularKey == null
                                                    ? null
                                                    : onChangeType),
                                            RadioListTile<_MultiSigType>(
                                                value: _MultiSigType.signerList,
                                                title: Text("signer_list".tr),
                                                groupValue: addressType,
                                                subtitle: signerList == null
                                                    ? Text(
                                                        "account_does_not_support_feature"
                                                            .tr)
                                                    : null,
                                                onChanged: signerList == null
                                                    ? null
                                                    : onChangeType),
                                            AnimatedSwitcher(
                                              duration:
                                                  APPConst.animationDuraion,
                                              child: addressType == null
                                                  ? WidgetConstant.sizedBox
                                                  : addressType ==
                                                          _MultiSigType
                                                              .regularKey
                                                      ? _RegularKeyFeatureView(
                                                          regularKey:
                                                              regularKey!,
                                                          onSetupRegularKey:
                                                              onSetupRegularKey,
                                                          hasRegularKey:
                                                              hasRegularKey,
                                                          onTapSetup: () {
                                                            context
                                                                .openSliverBottomSheet<
                                                                    IXRPAddress>(
                                                                  "select_account"
                                                                      .tr,
                                                                  minExtent:
                                                                      0.5,
                                                                  child: SwitchOrSelectAccountView(
                                                                      account:
                                                                          widget
                                                                              .account,
                                                                      showMultiSig:
                                                                          false),
                                                                  maxExtend:
                                                                      0.9,
                                                                  initialExtend:
                                                                      0.7,
                                                                  centerContent:
                                                                      false,
                                                                )
                                                                .then(
                                                                    onCheckRegularKey);
                                                          },
                                                        )
                                                      : _SignerListFeatureView(
                                                          signerQuorum:
                                                              signerList!
                                                                  .signerQuorum,
                                                          sumOfWeight:
                                                              sumOfWeight,
                                                          onTapSetup:
                                                              onSetupSignerList,
                                                          signers: signers,
                                                          onTapSigner:
                                                              (p0, p1) {
                                                            if (p1 != null) {
                                                              onAddSigner(
                                                                  null, p0);
                                                              return;
                                                            }
                                                            context
                                                                .openSliverBottomSheet<
                                                                    IXRPAddress>(
                                                              "select_account"
                                                                  .tr,
                                                              minExtent: 0.5,
                                                              child: SwitchOrSelectAccountView(
                                                                  account: widget
                                                                      .account,
                                                                  showMultiSig:
                                                                      false),
                                                              maxExtend: 0.9,
                                                              initialExtend:
                                                                  0.7,
                                                            )
                                                                .then(
                                                              (value) {
                                                                if (value ==
                                                                    null) {
                                                                  return;
                                                                }
                                                                onAddSigner(
                                                                    value, p0);
                                                              },
                                                            );
                                                          },
                                                        ),
                                            )
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ReceiptAddressView(
                                              title: "account".tr,
                                              subtitle:
                                                  "ripple_multi_sig_account_desc"
                                                      .tr,
                                              onTap: () {
                                                context
                                                    .openSliverBottomSheet<
                                                        ReceiptAddress<
                                                            XRPAddress>>(
                                                      "multi_sig_addr".tr,
                                                      maxExtend: 1,
                                                      minExtent: 0.8,
                                                      initialExtend: 0.9,
                                                      bodyBuilder: (c) =>
                                                          SelectRecipientAccountView<
                                                                  XRPAddress>(
                                                              account: widget
                                                                  .account,
                                                              scrollController:
                                                                  c,
                                                              subtitle:
                                                                  PageTitleSubtitle(
                                                                      title:
                                                                          "account"
                                                                              .tr,
                                                                      body:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "ripple_multi_sig_account_desc".tr,
                                                                          )
                                                                        ],
                                                                      ))),
                                                    )
                                                    .then(onSelectAddress);
                                              },
                                              address: address,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FixedElevatedButton(
                                                    padding: WidgetConstant
                                                        .paddingVertical20,
                                                    onPressed: address == null
                                                        ? null
                                                        : onAccountInformation,
                                                    child: Text(
                                                        "get_account_information"
                                                            .tr))
                                              ],
                                            )
                                          ],
                                        ),
                                ],
                              ),
                            )))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef _OnTapSigner = void Function(
    AccountObjectSignerEntry, RippleMultiSigSignerDetails?);

class _SignerListFeatureView extends StatelessWidget {
  const _SignerListFeatureView(
      {required this.signerQuorum,
      required this.sumOfWeight,
      required this.signers,
      required this.onTapSigner,
      required this.onTapSetup});
  final int signerQuorum;
  final Map<AccountObjectSignerEntry, RippleMultiSigSignerDetails?> signers;
  final int sumOfWeight;
  final _OnTapSigner onTapSigner;
  final DynamicVoid onTapSetup;
  @override
  Widget build(BuildContext context) {
    final bool hasSigner = signerQuorum == sumOfWeight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        PageTitleSubtitle(
            title: "signer_list".tr,
            body: Text("ripple_multi_sig_addres_signer_list_desc".tr)),
        Text("SignerQuorum".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${signerQuorum.toString()}/${sumOfWeight.toString()}"),
            Icon(Icons.check_circle,
                color: hasSigner ? ColorConst.green : context.colors.disable)
          ]),
        ),
        WidgetConstant.height20,
        Text("signer_list".tr, style: context.textTheme.titleMedium),
        Text("ripple_multi_sig_addres_signer_list_desc2".tr),
        WidgetConstant.height8,
        ...List.generate(signers.length, (index) {
          final signerEntries = signers.keys.toList();
          return ContainerWithBorder(
            onRemove: () {
              onTapSigner(signerEntries[index], signers[signerEntries[index]]);
            },
            onRemoveIcon: Checkbox(
              value: signers[signerEntries[index]] != null,
              onChanged: (value) {},
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("address".tr, style: context.textTheme.labelLarge),
                Text(signerEntries[index].account),
                WidgetConstant.height8,
                Text("weight".tr, style: context.textTheme.labelLarge),
                Text(signerEntries[index].signerWeight.toString())
              ],
            ),
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: hasSigner ? onTapSetup : null,
              child: Text("generate_address".tr),
            )
          ],
        )
      ],
    );
  }
}

class _RegularKeyFeatureView extends StatelessWidget {
  const _RegularKeyFeatureView(
      {required this.regularKey,
      required this.onSetupRegularKey,
      required this.hasRegularKey,
      required this.onTapSetup});
  final String regularKey;
  final DynamicVoid onSetupRegularKey;
  final DynamicVoid onTapSetup;
  final bool hasRegularKey;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        PageTitleSubtitle(
            title: "regular_key".tr,
            body: Text("ripple_multi_sig_regular_key_desc".tr)),
        Text("address".tr, style: context.textTheme.titleMedium),
        Text("ripple_multi_sig_addres_signer_list_desc2".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: onTapSetup,
          onRemoveIcon: IgnorePointer(
            child: Checkbox(
              value: hasRegularKey,
              onChanged: (value) {},
            ),
          ),
          child: Text(regularKey),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: hasRegularKey ? onSetupRegularKey : null,
              child: Text("generate_address".tr),
            )
          ],
        )
      ],
    );
  }
}

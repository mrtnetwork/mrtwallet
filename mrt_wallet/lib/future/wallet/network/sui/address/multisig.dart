import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/sui/account/state.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/sui/sui.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:on_chain/sui/sui.dart';

enum _Pages { threshold, pickAddresses, review }

class SetupSuiMultisigAddress extends StatelessWidget {
  const SetupSuiMultisigAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      accsess: WalletAccsessType.unlock,
      title: "setup_multisig_address".tr,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<SuiChain>(
          clientRequired: false,
          allowEmptyAccount: false,
          childBulder: (wallet, account, onAccountChanged) {
            return _SetupSuiMultisigAddress(account: account, wallet: wallet);
          },
        );
      },
    );
  }
}

class _SetupSuiMultisigAddress extends StatefulWidget {
  const _SetupSuiMultisigAddress({required this.account, required this.wallet});
  final SuiChain account;
  final WalletProvider wallet;

  @override
  State<_SetupSuiMultisigAddress> createState() =>
      __SetupSuiMultisigAddressState();
}

class __SetupSuiMultisigAddressState
    extends SuiAccountState<_SetupSuiMultisigAddress> with ProgressMixin {
  @override
  SuiChain get account => widget.account;
  _Pages page = _Pages.threshold;
  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "__SetupSuiMultisigAddressState_formKey");

  int threshold = 2;
  bool allowAddAccount = true;
  String? error;

  bool get isReady => error == null;

  String? onValidateThreshold(String? v) {
    final threshold = IntUtils.tryParse(v);
    if (threshold == null ||
        threshold < SuiAccountConst.multisigAccountMinThreshold ||
        threshold > SuiAccountConst.multisigAccountMaxThreshold) {
      return "threshold_validator"
          .tr
          .replaceOne(SuiAccountConst.multisigAccountMinThreshold.toString())
          .replaceTwo(SuiAccountConst.multisigAccountMaxThreshold.toString());
    }
    return null;
  }

  String? validateMultisig() {
    if (threshold < SuiAccountConst.multisigAccountMinThreshold ||
        threshold > SuiAccountConst.multisigAccountMaxThreshold) {
      return "threshold_validator"
          .tr
          .replaceOne(SuiAccountConst.multisigAccountMinThreshold.toString())
          .replaceTwo(SuiAccountConst.multisigAccountMaxThreshold.toString());
    }
    if (selectedAccounts.length > SuiAccountConst.multisigAccountMaxPublicKey) {
      return "exceeded_multisig_maximum_publickey".tr;
    }
    if (selectedAccounts.isEmpty) {
      return "at_least_one_account_required".tr;
    }
    for (final i in selectedAccounts.values) {
      if (i.weight < SuiAccountConst.multisigAccountPublicKeyMinWeight ||
          i.weight > SuiAccountConst.multisigAccountPublicKeyMaxWeight) {
        return "address_weight_validator"
            .tr
            .replaceOne(
                SuiAccountConst.multisigAccountPublicKeyMinWeight.toString())
            .replaceTwo(
                SuiAccountConst.multisigAccountPublicKeyMaxWeight.toString());
      }
    }
    final totalWeight = selectedAccounts.values.fold(0, (p, c) => p + c.weight);
    if (totalWeight < threshold) {
      return "threshhold_desc3".tr;
    }
    return null;
  }

  void checkError() {
    error = validateMultisig();
    allowAddAccount =
        selectedAccounts.length < SuiAccountConst.multisigAccountMaxPublicKey;
  }

  void onChangeThreshold(int threshold) {
    this.threshold = threshold;
    updateState();
  }

  void submitThreshold() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    page = _Pages.pickAddresses;
    checkError();
    updateState();
  }

  Map<ISuiAddress, _SelectedAccount> selectedAccounts = {};

  String? filterAccount(ISuiAddress address) {
    if (address.multiSigAccount) {
      return "unavailable_multi_sig_public_key".tr;
    }
    if (selectedAccounts.containsKey(address)) {
      return "address_already_exist".tr;
    }
    return null;
  }

  Future<void> addAddress() async {
    final address = await context.openSliverBottomSheet<ISuiAddress>(
        "select_account".tr,
        child: SwitchOrSelectAccountView(
            account: account, showMultiSig: false, filter: filterAccount),
        centerContent: false);
    if (address == null) return;
    selectedAccounts[address] = _SelectedAccount(address);
    checkError();
    updateState();
  }

  void onChangeWeight(_SelectedAccount address, int weight) {
    address.weight = weight;
    checkError();
    updateState();
  }

  void updateThreshold() {
    page = _Pages.threshold;
    updateState();
  }

  void removeAddress(_SelectedAccount address) {
    selectedAccounts.remove(address.address);
    checkError();
    updateState();
  }

  void reviewAddress() {
    try {
      checkError();
      if (!isReady) return;
      page = _Pages.review;
    } finally {
      updateState();
    }
  }

  void clearState() {
    threshold = 2;
    selectedAccounts.clear();
    page = _Pages.threshold;
    updateState();
  }

  void onBackButton(bool _, Object? __) {
    switch (page) {
      case _Pages.review:
        page = _Pages.pickAddresses;
        break;
      case _Pages.pickAddresses:
        page = _Pages.threshold;
        break;
      default:
    }
    updateState();
  }

  bool get canBack {
    return (page == _Pages.review && progressKey.isSuccess) ||
        page == _Pages.threshold;
  }

  Future<void> generateAddress() async {
    progressKey.progressText("setup_address".tr);
    final r = await MethodUtils.call(() async {
      final publicKeys = selectedAccounts.values
          .map((e) => SuiMultisigAccountPublicKeyInfo.create(
              keyIndex: e.address.keyIndex.cast(),
              keyScheme: e.address.keyScheme,
              publicKey: e.address.publicKey,
              wieght: e.weight))
          .toList();
      final multisig = SuiMultisigAccountInfo.create(
          publicKeys: publicKeys, threshold: threshold);

      final address = SuiAddrEncoder().encodeMultisigKey(
          pubKey: publicKeys.map((e) {
            return SuiPublicKeyAndWeight(
                publicKey: IPublicKey.fromBytes(
                    e.publicKey,
                    e.keyScheme.curve == EllipticCurveTypes.nist256p1Hybrid
                        ? EllipticCurveTypes.nist256p1
                        : e.keyScheme.curve),
                weight: e.weight);
          }).toList(),
          threshold: threshold);
      return SuiMultiSigNewAddressParams(
          multiSignatureAddress: multisig,
          coin: account.network.coins.first,
          address: SuiAddress(address));
    }, delay: APPConst.oneSecoundDuration);
    if (r.hasError) {
      progressKey.errorText(r.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    final import = await widget.wallet.wallet
        .deriveNewAccount(newAccountParams: r.result, chain: account);
    if (import.hasError) {
      progressKey.errorText(import.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    progressKey.success(
        backToIdle: false,
        progressWidget: SuccessWithButtonView(
          buttonWidget: ContainerWithBorder(
              margin: WidgetConstant.paddingVertical8,
              child: AddressDetailsView(address: import.result)),
          buttonText: "generate_new_address".tr,
          onPressed: () {
            clearState();
            progressKey.backToIdle();
          },
        ));
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      canPop: canBack,
      onPopInvokedWithResult: onBackButton,
      child: PageProgress(
        key: progressKey,
        backToIdle: APPConst.twoSecoundDuration,
        child: (context) => CustomScrollView(slivers: [
          SliverConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            sliver: SliverMainAxisGroup(slivers: [
              SliverToBoxAdapter(
                child: PageTitleSubtitle(
                    title: "multisig_address".tr,
                    body: Column(children: [
                      Text("multisig_address_desc".tr),
                      AlertTextContainer(
                          message: "mutlisig_address_alert".tr,
                          enableTap: false)
                    ])),
              ),
              APPSliverAnimatedSwitcher<_Pages>(enable: page, widgets: {
                _Pages.threshold: (context) => _SetupTreshold(this),
                _Pages.pickAddresses: (context) => _PickAddress(this),
                _Pages.review: (context) => _ReviewAddress(this)
              })
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ReviewAddress extends StatelessWidget {
  const _ReviewAddress(this.state);
  final __SetupSuiMultisigAddressState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("threshold".tr, style: context.textTheme.titleMedium),
        Text("threshhold_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: state.updateThreshold,
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: Text(state.threshold.toString(),
                style: context.onPrimaryTextTheme.titleMedium)),
        WidgetConstant.height20,
        Text("list_of_public_keys".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        APPAnimatedSize(
            isActive: true,
            onActive: (context) => ListView.separated(
                  physics: WidgetConstant.noScrollPhysics,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final keys = state.selectedAccounts.keys.toList();
                    final account = state.selectedAccounts[keys[index]]!;
                    return _ShowAddressView(account: account, state: state);
                  },
                  itemCount: state.selectedAccounts.length,
                  separatorBuilder: (context, index) => WidgetConstant.divider,
                ),
            onDeactive: (c) => WidgetConstant.sizedBox),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FixedElevatedButton(
            padding: WidgetConstant.paddingVertical40,
            onPressed: state.generateAddress,
            activePress: state.isReady,
            child: Text("generate_address".tr),
          )
        ])
      ]),
    );
  }
}

class _PickAddress extends StatelessWidget {
  const _PickAddress(this.state);
  final __SetupSuiMultisigAddressState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("threshold".tr, style: context.textTheme.titleMedium),
        Text("threshhold_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: state.updateThreshold,
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: Text(state.threshold.toString(),
                style: context.onPrimaryTextTheme.titleMedium)),
        WidgetConstant.height20,
        Text("list_of_public_keys".tr, style: context.textTheme.titleMedium),
        Text("multi_sig_desc5".tr),
        WidgetConstant.height8,
        APPAnimatedSize(
            isActive: true,
            onActive: (context) => ListView.separated(
                  physics: WidgetConstant.noScrollPhysics,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final keys = state.selectedAccounts.keys.toList();
                    final account = state.selectedAccounts[keys[index]]!;
                    return _SelectedAddressView(account: account, state: state);
                  },
                  itemCount: state.selectedAccounts.length,
                  separatorBuilder: (context, index) => WidgetConstant.divider,
                ),
            onDeactive: (c) => WidgetConstant.sizedBox),
        APPAnimatedSize(
            isActive: true,
            onActive: (context) => ContainerWithBorder(
                validate: state.selectedAccounts.isNotEmpty,
                onRemoveIcon:
                    Icon(Icons.add, color: context.colors.onPrimaryContainer),
                onRemove: state.addAddress,
                child: Text("tap_to_select_account".tr,
                    style:
                        context.colors.onPrimaryContainer.bodyMedium(context))),
            onDeactive: (context) => WidgetConstant.sizedBox),
        ErrorTextContainer(error: state.error),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FixedElevatedButton(
            padding: WidgetConstant.paddingVertical40,
            onPressed: state.reviewAddress,
            activePress: state.isReady,
            child: Text("review_address".tr),
          )
        ])
      ]),
    );
  }
}

class _SetupTreshold extends StatelessWidget {
  const _SetupTreshold(this.state);
  final __SetupSuiMultisigAddressState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("threshold".tr, style: context.textTheme.titleMedium),
          Text("threshhold_desc".tr),
          WidgetConstant.height8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: NumberTextField(
                    label: "threshold".tr,
                    readOnly: false,
                    onChange: state.onChangeThreshold,
                    validator: state.onValidateThreshold,
                    max: SuiAccountConst.multisigAccountMaxThreshold,
                    min: SuiAccountConst.multisigAccountMinThreshold,
                    defaultValue: state.threshold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.submitThreshold,
                  child: Text("continue".tr))
            ],
          )
        ],
      ),
    );
  }
}

class _SelectedAddressView extends StatelessWidget {
  final _SelectedAccount account;
  final __SetupSuiMultisigAddressState state;
  const _SelectedAddressView({required this.account, required this.state});
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      iconAlginment: CrossAxisAlignment.start,
      onRemove: () {
        state.removeAddress(account);
      },
      enableTap: false,
      onRemoveWidget: IconButton(
          onPressed: () {
            state.removeAddress(account);
          },
          icon: Icon(Icons.remove_circle, color: context.onPrimaryContainer)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("account".tr, style: context.onPrimaryTextTheme.labelLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
          backgroundColor: context.onPrimaryContainer,
          child: AddressDetailsView(
              address: account.address, color: context.colors.primaryContainer),
        ),
        WidgetConstant.height20,
        Text("weight".tr, style: context.onPrimaryTextTheme.labelLarge),
        Text("multisig_address_weight_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.colors.surface,
            child: NumberTextField(
                readOnly: false,
                onChange: (p0) {
                  state.onChangeWeight(account, p0);
                },
                max: SuiAccountConst.multisigAccountPublicKeyMaxWeight,
                defaultValue: account.weight,
                min: SuiAccountConst.multisigAccountPublicKeyMinWeight))
      ]),
    );
  }
}

class _ShowAddressView extends StatelessWidget {
  final _SelectedAccount account;
  final __SetupSuiMultisigAddressState state;
  const _ShowAddressView({required this.account, required this.state});
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      iconAlginment: CrossAxisAlignment.start,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("account".tr, style: context.onPrimaryTextTheme.labelLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
          backgroundColor: context.onPrimaryContainer,
          child: AddressDetailsView(
              address: account.address, color: context.colors.primaryContainer),
        ),
        WidgetConstant.height20,
        Text("weight".tr, style: context.onPrimaryTextTheme.labelLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: Text(account.weight.toString(),
                style: context.primaryTextTheme.titleMedium))
      ]),
    );
  }
}

class _SelectedAccount {
  int weight = 1;
  final ISuiAddress address;
  _SelectedAccount(this.address);
}

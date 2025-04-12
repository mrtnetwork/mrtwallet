import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/account/state.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/aptos/aptos/multisig.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/models/networks/aptos/models/types.dart';
import 'package:on_chain/aptos/aptos.dart';

enum _Pages { threshold, pickAddresses, review }

class SetupAptosMultisigAddress extends StatelessWidget {
  const SetupAptosMultisigAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      accsess: WalletAccsessType.unlock,
      title: "setup_multisig_address".tr,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<AptosChain>(
          clientRequired: false,
          allowEmptyAccount: false,
          childBulder: (wallet, account, onAccountChanged) {
            return _SetupAptosMultisigAddress(account: account, wallet: wallet);
          },
        );
      },
    );
  }
}

class _SetupAptosMultisigAddress extends StatefulWidget {
  const _SetupAptosMultisigAddress(
      {required this.account, required this.wallet});
  final AptosChain account;
  final WalletProvider wallet;

  @override
  State<_SetupAptosMultisigAddress> createState() =>
      __SetupAptosMultisigAddressState();
}

class __SetupAptosMultisigAddressState
    extends AptosAccountState<_SetupAptosMultisigAddress> with ProgressMixin {
  @override
  AptosChain get account => widget.account;
  _Pages page = _Pages.threshold;
  AptosSupportKeyScheme algorithm = AptosSupportKeyScheme.multiKey;
  void onChangeAlgorithm(AptosSupportKeyScheme? alg) {
    algorithm = alg ?? algorithm;
    selectedAccounts.clear();
    updateState();
  }

  late final Map<AptosSupportKeyScheme, Widget> algorithmTypesWidget;

  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "__SetupAptosMultisigAddressState_formKey");

  int threshold = 2;
  bool allowAddAccount = true;
  String? error;
  int minThreshold = AptosAccountConst.mulitKeyMinRequiredSignature;

  bool get isReady => error == null;
  String? onValidateThreshold(String? v) {
    final threshold = IntUtils.tryParse(v);
    return _onValidateThreshold(threshold);
  }

  String? _onValidateThreshold(int? threshold) {
    // final threshold = IntUtils.tryParse(v);
    switch (algorithm) {
      case AptosSupportKeyScheme.multiEd25519:
        if (threshold == null ||
            threshold < AptosAccountConst.mulitKeyMinRequiredSignature ||
            threshold > AptosAccountConst.multiKeyMaxRequiredSignature) {
          return "aptos_required_signature_validator"
              .tr
              .replaceOne(
                  AptosAccountConst.mulitKeyMinRequiredSignature.toString())
              .replaceTwo(
                  AptosAccountConst.multiKeyMaxRequiredSignature.toString());
        }
      default:
        if (threshold == null ||
            threshold < AptosAccountConst.multiEd25519MinThreshold ||
            threshold > AptosAccountConst.multiEd25519MaxKeys) {
          return "threshold_validator"
              .tr
              .replaceOne(AptosAccountConst.multiEd25519MinThreshold.toString())
              .replaceTwo(AptosAccountConst.multiEd25519MaxKeys.toString());
        }
    }
    return null;
  }

  String? validateMultiEd25519() {
    if (selectedAccounts.length > AptosAccountConst.multiEd25519MaxKeys) {
      return "exceeded_multisig_maximum_publickey".tr;
    }
    if (selectedAccounts.length < AptosAccountConst.multiEd25519MinKeys) {
      return "at_least_n_account_required"
          .tr
          .replaceOne(AptosAccountConst.multiEd25519MinKeys.toString());
    }
    final totalWeight = selectedAccounts.length;
    if (totalWeight < threshold) {
      return "threshhold_desc3".tr;
    }
    return null;
  }

  String? validateMultiKey() {
    if (selectedAccounts.length > AptosAccountConst.multiEd25519MaxKeys) {
      return "exceeded_multisig_maximum_publickey".tr;
    }
    if (selectedAccounts.length <
        AptosAccountConst.mulitKeyMinRequiredSignature) {
      return "at_least_n_account_required".tr.replaceOne(
          AptosAccountConst.mulitKeyMinRequiredSignature.toString());
    }
    final totalWeight = selectedAccounts.length;
    if (totalWeight < threshold) {
      return "aptos_required_signature_validator2".tr;
    }
    return null;
  }

  String? validateMultisig() {
    final thresholdError = _onValidateThreshold(threshold);
    if (thresholdError != null) return thresholdError;
    switch (algorithm) {
      case AptosSupportKeyScheme.multiKey:
        return validateMultiKey();
      default:
        return validateMultiEd25519();
    }
  }

  void checkError() {
    error = validateMultisig();
    allowAddAccount =
        selectedAccounts.length < AptosAccountConst.multiEd25519MaxKeys;
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

  Set<IAptosAddress> selectedAccounts = {};

  String? filterAccount(IAptosAddress address) {
    if (address.multiSigAccount) {
      return "unavailable_multi_sig_public_key".tr;
    }
    if (selectedAccounts.contains(address)) {
      return "address_already_exist".tr;
    }
    if (selectedAccounts.any((e) =>
        e.keyScheme.curve == address.keyScheme.curve &&
        e.keyIndex == address.keyIndex)) {
      return "public_key_already_exist".tr;
    }
    if (algorithm == AptosSupportKeyScheme.multiEd25519) {
      if (address.keyScheme != AptosSupportKeyScheme.ed25519 &&
          address.keyScheme != AptosSupportKeyScheme.signleKeyEd25519) {
        return "aptos_mutli_ed25519_key_type_validator".tr;
      }
    }
    return null;
  }

  Future<void> addAddress() async {
    final address = await context.openSliverBottomSheet<IAptosAddress>(
        "select_account".tr,
        child: SwitchOrSelectAccountView<IAptosAddress>(
            account: account, showMultiSig: false, filter: filterAccount),
        centerContent: false);
    if (address == null) return;
    final error = filterAccount(address);
    if (error != null) {
      context.showAlert(error.tr);
      return;
    }
    selectedAccounts.add(address);
    checkError();
    updateState();
  }

  void updateThreshold() {
    page = _Pages.threshold;
    updateState();
  }

  void removeAddress(IAptosAddress address) {
    selectedAccounts.remove(address);
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
      final publicKeys = selectedAccounts
          .map((e) => AptosMultisigAccountPublicKeyInfo.create(
              keyIndex: e.keyIndex.cast(),
              keyScheme: e.keyScheme,
              publicKey: e.publicKey))
          .toList();
      final multisigAccount = AptosMultisigAccountInfo.create(
          publicKeys: publicKeys,
          requiredSignature: threshold,
          keyScheme: algorithm);

      return AptosMultiSigNewAddressParams(
          multiSignatureAddress: multisigAccount,
          coin: account.network.coins.first,
          address: multisigAccount.generateAddress());
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
  void onInitOnce() {
    super.onInitOnce();
    algorithmTypesWidget = {
      for (final i in AptosSupportKeyScheme.values)
        if (i.isMultisig) i: Text(i.name)
    };
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
  final __SetupAptosMultisigAddressState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("threshold".tr, style: context.textTheme.titleMedium),
        Text("threshhold_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: () {},
            enableTap: false,
            onRemoveWidget: IconButton(
                onPressed: () {
                  state.updateThreshold();
                },
                icon: Icon(Icons.edit, color: context.onPrimaryContainer)),
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
                    final account = state.selectedAccounts.elementAt(index);
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
  final __SetupAptosMultisigAddressState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ConditionalWidgets(enable: state.algorithm, widgets: {
          AptosSupportKeyScheme.multiEd25519: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("threshold".tr, style: context.textTheme.titleMedium),
                  Text("threshhold_desc".tr)
                ],
              ),
          AptosSupportKeyScheme.multiKey: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("required_signature".tr,
                      style: context.textTheme.titleMedium),
                  Text("required_signature_desc".tr)
                ],
              )
        }),
        WidgetConstant.height8,
        ContainerWithBorder(
            enableTap: false,
            onRemove: () {},
            onRemoveWidget: IconButton(
                onPressed: () {
                  state.updateThreshold();
                },
                icon: Icon(Icons.edit, color: context.onPrimaryContainer)),
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
                    final account = state.selectedAccounts.elementAt(index);
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
  final __SetupAptosMultisigAddressState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("key_scheme".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          AppDropDownBottom(
              items: state.algorithmTypesWidget,
              hint: "key_scheme".tr,
              onChanged: state.onChangeAlgorithm,
              isExpanded: true,
              value: state.algorithm),
          WidgetConstant.height20,
          ConditionalWidgets(enable: state.algorithm, widgets: {
            AptosSupportKeyScheme.multiEd25519: (context) => Column(
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
                              max: AptosAccountConst
                                  .multiKeyMaxRequiredSignature,
                              min: AptosAccountConst
                                  .mulitKeyMinRequiredSignature,
                              defaultValue: state.threshold),
                        ),
                      ],
                    ),
                  ],
                ),
            AptosSupportKeyScheme.multiKey: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("required_signature".tr,
                        style: context.textTheme.titleMedium),
                    Text("required_signature_desc".tr),
                    WidgetConstant.height8,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: NumberTextField(
                              label: "required_signature".tr,
                              readOnly: false,
                              onChange: state.onChangeThreshold,
                              validator: state.onValidateThreshold,
                              max: AptosAccountConst
                                  .multiKeyMaxRequiredSignature,
                              min: AptosAccountConst
                                  .mulitKeyMinRequiredSignature,
                              defaultValue: state.threshold),
                        ),
                      ],
                    ),
                  ],
                )
          }),
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
  final IAptosAddress account;
  final __SetupAptosMultisigAddressState state;
  const _SelectedAddressView({required this.account, required this.state});
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      onRemove: () {},
      onRemoveWidget: IconButton(
          onPressed: () {
            state.removeAddress(account);
          },
          icon: Icon(Icons.remove_circle, color: context.onPrimaryContainer)),
      child: AddressDetailsView(
          address: account, color: context.colors.onPrimaryContainer),
    );
  }
}

class _ShowAddressView extends StatelessWidget {
  final IAptosAddress account;
  final __SetupAptosMultisigAddressState state;
  const _ShowAddressView({required this.account, required this.state});
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      backgroundColor: context.onPrimaryContainer,
      child: AddressDetailsView(
          address: account, color: context.colors.primaryContainer),
    );
  }
}

//

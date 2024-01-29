import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/global/controller_tron_transaction_account.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SetupTronMultiSigAddressView extends StatelessWidget {
  const SetupTronMultiSigAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return ControllerTronTransactionAccountView(
        childBulder: (wallet, account, address, switchRippleAccount) {
          return _SetupTronMultisigAddressView(
            wallet: wallet,
            address: address,
            provider: account.provider()!,
            account: account.account,
            network: account.network as APPTVMNetwork,
          );
        },
        title: "multi_sig_addr".tr);
  }
}

class _SetupTronMultisigAddressView extends StatefulWidget {
  const _SetupTronMultisigAddressView(
      {required this.wallet,
      required this.address,
      required this.provider,
      required this.account,
      required this.network});
  final WalletProvider wallet;
  final ITronAddress address;
  final TVMApiProvider provider;
  final NetworkAccountCore account;
  final APPTVMNetwork network;
  @override
  State<_SetupTronMultisigAddressView> createState() =>
      __SetupTronMultisigAddressViewState();
}

class __SetupTronMultisigAddressViewState
    extends State<_SetupTronMultisigAddressView> with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  ReceiptAddress<TronAddress>? address;
  final Map<PermissionKeys, TronMultiSigSignerDetais?> signers = {};

  void onSelectAddress(ReceiptAddress<TronAddress>? multiSigAddr) {
    address = multiSigAddr;
    setState(() {});
  }

  TronAccountInfo? account;

  List<AccountPermission> get permissions => account!.permissions;
  AccountPermission? permission;
  List<TransactionContractType>? operations;
  bool get isReady =>
      permission != null && sumOfWeight >= permission!.threshold;
  void onSelectPermission(AccountPermission? select) {
    if (select == null) return;
    permission = select;
    if (permission!.operations == null) {
      operations = null;
    } else {
      operations =
          TronHelper.decodePermissionOperation(permission!.operations!);
    }
    signers.clear();
    sumOfWeight = BigInt.zero;
    for (final i in permission!.keys) {
      signers[i] = null;
    }
    setState(() {});
  }

  BigInt sumOfWeight = BigInt.zero;

  void onAddSigner(ITronAddress? acc, PermissionKeys signer) {
    try {
      if (acc == null) {
        signers[signer] = null;
        return;
      }
      if (acc.multiSigAccount) {
        context.showAlert("unavailable_multi_sig_public_key".tr);
        return;
      }
      if (acc.networkAddress.toAddress() != signer.address.toAddress()) {
        context.showAlert("account_does_not_match_with_signer_account".tr);
        return;
      }
      if (signers[signer] != null) {
        context.showAlert("address_already_exist".tr);
        return;
      }

      final newAcc = TronMultiSigSignerDetais(
          publicKey: acc.publicKey,
          keyIndex: acc.keyIndex,
          weight: signer.weight);

      signers.addAll({signer: newAcc});
    } finally {
      sumOfWeight = signers.values.fold<BigInt>(
          BigInt.zero,
          (previousValue, element) =>
              previousValue + (element?.weight ?? BigInt.zero));
      setState(() {});
    }
  }

  void onAccountInformation() async {
    if (address == null) return;
    progressKey.progressText("retrieving_account_information".tr);
    final result = await MethodCaller.call(() async {
      return await widget.provider.getAccount(address!.networkAddress);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!);
    } else {
      account = result.result;
      if (account == null) {
        progressKey.errorText("account_not_found".tr);
      } else {
        progressKey.success();
      }
    }
  }

  void onGenerateAddress() async {
    progressKey.progressText("setup_address".tr);

    final accountParams = await MethodCaller.call(() async {
      final newAccountParams = TronMultisigNewAddressParam(
        coin: widget.network.coins.first,
        masterAddress: address!.networkAddress,
        multiSigAccount: TronMultiSignatureAddress(
            signers: signers.values
                .where((element) => element != null)
                .toList()
                .cast(),
            threshold: permission!.threshold,
            permissionID: permission!.id),
      );
      return newAccountParams;
    });
    if (accountParams.hasError) {
      progressKey.errorText(accountParams.error!.tr);
    } else {
      final result = await widget.wallet.deriveNewAccount(accountParams.result);
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        progressKey.success(
            backToIdle: false,
            progressWidget: SuccessWithButtomView(
              buttomWidget: ContainerWithBorder(
                  margin: WidgetConstant.paddingVertical8,
                  child: AddressDetailsView(address: result.result)),
              buttomText: "close".tr,
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {},
      child: PageProgress(
        key: progressKey,
        backToIdle: AppGlobalConst.oneSecoundDuration,
        initialStatus: PageProgressStatus.idle,
        child: () => UnfocusableChild(
          child: Center(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                        padding: WidgetConstant.paddingHorizontal20,
                        child: AnimatedSwitcher(
                            duration: AppGlobalConst.animationDuraion,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PageTitleSubtitle(
                                    title: "multi_sig_addr".tr,
                                    body: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("tron_multi_sig_desc".tr),
                                      ],
                                    )),
                                AnimatedSwitcher(
                                  duration: AppGlobalConst.animationDuraion,
                                  child: SizedBox(
                                    width: context.mediaQuery.size.width,
                                    child: account != null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            key: const ValueKey<bool>(true),
                                            children: [
                                              Text("permissions".tr,
                                                  style: context
                                                      .textTheme.titleMedium),
                                              Text(
                                                  "tron_multi_sig_select_permission"
                                                      .tr),
                                              WidgetConstant.height8,
                                              AppDropDownBottom(
                                                items: {
                                                  for (final i in permissions)
                                                    i: RichText(
                                                        text: TextSpan(
                                                            style: context
                                                                .textTheme
                                                                .bodyMedium,
                                                            text: i.type.name
                                                                .camelCase,
                                                            children: [
                                                          if (i.permissionName !=
                                                              null)
                                                            TextSpan(
                                                                text:
                                                                    " (${i.permissionName}) ",
                                                                style: context
                                                                    .textTheme
                                                                    .bodySmall)
                                                        ]))
                                                },
                                                label: "permissions".tr,
                                                onChanged: onSelectPermission,
                                              ),
                                              AnimatedSize(
                                                duration: AppGlobalConst
                                                    .animationDuraion,
                                                child: permission == null
                                                    ? WidgetConstant.sizedBox
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          WidgetConstant
                                                              .height20,
                                                          Text("threshold".tr,
                                                              style: context
                                                                  .textTheme
                                                                  .titleMedium),
                                                          WidgetConstant
                                                              .height8,
                                                          ContainerWithBorder(
                                                              child: Text(
                                                                  permission!
                                                                      .threshold
                                                                      .toString())),
                                                          WidgetConstant
                                                              .height20,
                                                          Text("operations".tr,
                                                              style: context
                                                                  .textTheme
                                                                  .titleMedium),
                                                          WidgetConstant
                                                              .height8,
                                                          ContainerWithBorder(
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(permission
                                                                          ?.operations ??
                                                                      "all_operations"
                                                                          .tr),
                                                                ),
                                                                if (operations !=
                                                                    null) ...[
                                                                  WidgetConstant
                                                                      .width8,
                                                                  ToolTipView(
                                                                      waitDuration:
                                                                          null,
                                                                      tooltipWidget:
                                                                          Wrap(
                                                                        alignment:
                                                                            WrapAlignment.spaceBetween,
                                                                        runSpacing:
                                                                            2.5,
                                                                        spacing:
                                                                            2.5,
                                                                        children: List.generate(
                                                                            TransactionContractType.values.length,
                                                                            (index) => Container(
                                                                                  padding: WidgetConstant.padding5,
                                                                                  decoration: BoxDecoration(color: context.colors.background, borderRadius: WidgetConstant.border8),
                                                                                  width: 120,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Expanded(child: OneLineTextWidget(TransactionContractType.values[index].name, style: context.textTheme.bodySmall)),
                                                                                      IgnorePointer(
                                                                                        child: Checkbox(
                                                                                          value: operations!.contains(TransactionContractType.values[index]),
                                                                                          onChanged: (value) {},
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )),
                                                                      ),
                                                                      child: const Icon(
                                                                          Icons
                                                                              .help)),
                                                                ]
                                                              ],
                                                            ),
                                                          ),
                                                          WidgetConstant
                                                              .height20,
                                                          Text(
                                                              "tron_permission_key"
                                                                  .tr,
                                                              style: context
                                                                  .textTheme
                                                                  .titleMedium),
                                                          Text(
                                                              "tron_multi_sig_addres_threshhold"
                                                                  .tr),
                                                          WidgetConstant
                                                              .height8,
                                                          ...List.generate(
                                                              permission!
                                                                  .keys.length,
                                                              (index) {
                                                            final signerEntries =
                                                                permission!.keys
                                                                    .toList();
                                                            return ContainerWithBorder(
                                                              onRemove: () {
                                                                if (signers[signerEntries[
                                                                        index]] !=
                                                                    null) {
                                                                  onAddSigner(
                                                                      null,
                                                                      signerEntries[
                                                                          index]);
                                                                  return;
                                                                }

                                                                context
                                                                    .openSliverBottomSheet<
                                                                        ITronAddress>(
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
                                                                  (value) {
                                                                    if (value ==
                                                                        null) {
                                                                      return;
                                                                    }
                                                                    onAddSigner(
                                                                        value,
                                                                        signerEntries[
                                                                            index]);
                                                                  },
                                                                );
                                                              },
                                                              onRemoveIcon:
                                                                  Checkbox(
                                                                value: signers[
                                                                        signerEntries[
                                                                            index]] !=
                                                                    null,
                                                                onChanged:
                                                                    (value) {},
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "address"
                                                                          .tr,
                                                                      style: context
                                                                          .textTheme
                                                                          .labelLarge),
                                                                  Text(signerEntries[
                                                                          index]
                                                                      .address
                                                                      .toAddress()),
                                                                  WidgetConstant
                                                                      .height8,
                                                                  Text(
                                                                      "weight"
                                                                          .tr,
                                                                      style: context
                                                                          .textTheme
                                                                          .labelLarge),
                                                                  Text(signerEntries[
                                                                          index]
                                                                      .weight
                                                                      .toString())
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                      ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FixedElevatedButton(
                                                    padding: WidgetConstant
                                                        .paddingVertical20,
                                                    onPressed: isReady
                                                        ? onGenerateAddress
                                                        : null,
                                                    child: Text(
                                                        "generate_address".tr),
                                                  )
                                                ],
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
                                                    "tron_multi_sig_desc2".tr,
                                                onTap: () {
                                                  context
                                                      .openSliverBottomSheet<
                                                              ReceiptAddress<
                                                                  TronAddress>>(
                                                          "multi_sig_addr".tr,
                                                          bodyBuilder:
                                                              (controller) =>
                                                                  SelectRecipientAccountView(
                                                                    account: widget
                                                                        .account,
                                                                    scrollController:
                                                                        controller,
                                                                    subtitle: PageTitleSubtitle(
                                                                        title: "account".tr,
                                                                        body: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "tron_multi_sig_desc2".tr,
                                                                            )
                                                                          ],
                                                                        )),
                                                                  ),
                                                          maxExtend: 1,
                                                          minExtent: 0.8,
                                                          initialExtend: 0.9)
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
                                  ),
                                ),
                              ],
                            )))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

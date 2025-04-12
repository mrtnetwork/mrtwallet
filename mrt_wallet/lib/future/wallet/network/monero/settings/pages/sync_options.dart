import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/monero/account/state.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/constant/networks/monero.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

enum _SyncOptionsPage {
  walletRPC("wallet_rpc"),
  transactions("transaction_id"),
  block("block"),
  showPayment("");

  final String tr;
  const _SyncOptionsPage(this.tr);
}

class MoneroSyncOptionsView extends StatelessWidget {
  const MoneroSyncOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      title: "sync_options".tr,
      accsess: WalletAccsessType.unlock,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<MoneroChain>(
            childBulder: (wallet, chain, onAccountChanged) =>
                _MoneroSyncOptionsView(wallet: wallet, chain: chain));
      },
    );
  }
}

class _MoneroSyncOptionsView extends StatefulWidget {
  final WalletProvider wallet;
  final MoneroChain chain;
  const _MoneroSyncOptionsView({required this.wallet, required this.chain});

  @override
  State<_MoneroSyncOptionsView> createState() => _MoneroSyncOptionsViewState();
}

class _MoneroSyncOptionsViewState
    extends MoneroAccountState<_MoneroSyncOptionsView> {
  Map<_SyncOptionsPage, Widget> options = {};
  List<MoneroUnlockedPaymentRequestDetails>? payments;
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<AppTextFieldState> txIdsStateKey = GlobalKey();

  List<MoneroAddress> allRelatedAccountAddresses = [];
  @override
  final List<IMoneroAddress> addresses = [];

  MoneroAPIProvider? walletProvider;
  RPCURL? rpcUrl;
  final GlobalKey<HTTPServiceProviderFieldsState> serviceProviderStateKey =
      GlobalKey(
          debugLabel: "_MoneroSyncOptionsViewState_serviceProviderStateKey");

  WalletProvider get wallet => widget.wallet;
  @override
  MoneroChain get account => widget.chain;
  WalletMoneroNetwork get network => account.network;
  bool walletRpcSync = false;
  bool get walletRpcConnected => walletRpcSync && walletProvider != null;

  _SyncOptionsPage? option;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "_MoneroSyncOptionsViewState_progressKey");

  int startBlock = 0;
  int endBlock = 0;
  int? max;

  void onChangeWalletRpcSync(bool? _) async {
    final provider = walletProvider;
    if (walletRpcSync && provider != null) {
      final accept = await context.openSliverDialog<bool>(
          (p0) => DialogTextView(
              buttonWidget: DialogDoubleButtonView(),
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("disconnect_from_monero_wallet_rpc_desc".tr),
                ],
              )),
          "disconnect_from_wallet_rpc".tr);
      if (accept != true) {
        return;
      }
      await account.updateWalletRPC(null);
      rpcUrl = RPCURL(url: provider.callUrl, auth: provider.auth);
      walletProvider = null;
    }
    walletRpcSync = !walletRpcSync;
    updateState();
  }

  void addAddress(IMoneroAddress? address) {
    if (address == null) return;
    if (addresses.contains(address)) {
      context.showAlert("address_already_exist".tr);
      return;
    }
    addresses.add(address);
    updateState();
  }

  void removeAddress(IMoneroAddress address) {
    final r = addresses.remove(address);
    if (r) {
      updateState();
    }
  }

  Future<void> initOptions() async {
    for (final i in _SyncOptionsPage.values) {
      if (i == _SyncOptionsPage.showPayment) continue;
      options[i] = Text(i.tr.tr);
    }
    max = client.currentHeight?.block;
    allRelatedAccountAddresses =
        account.addresses.map((e) => e.networkAddress).toList();
    walletProvider = await account.getWalletRPC();
    if (walletProvider != null) {
      walletRpcSync = true;
    }
    progressKey.backToIdle();
  }

  void onBlockEnd(int block) {
    endBlock = block;
  }

  void onBlockStart(int block) {
    startBlock = block;
  }

  String? validateOnBlockStart(String? v) {
    final block = int.tryParse(v ?? '');
    return validateBlockFilds(block);
  }

  String? validateBlockFilds(int? block) {
    if (block == null) {
      return "enter_valid_number".tr;
    }
    if (block < network.coinParam.rctHeight) {
      return "monero_rct_block_validator"
          .tr
          .replaceOne(network.coinParam.rctHeight.toString());
    }
    return null;
  }

  String? validateOnBlockEnd(String? v) {
    final block = int.tryParse(v ?? '');
    final err = validateBlockFilds(block);
    if (err != null) return err;
    if (block! <= startBlock) {
      return "monero_sync_block_validator".tr;
    }
    return null;
  }

  void onChangeOption(_SyncOptionsPage? option) {
    this.option = option;
    updateState();
  }

  void syncFromRpc() async {
    rpcUrl = serviceProviderStateKey.currentState?.getEndpoint();
    final url = rpcUrl;
    if (url == null) return;
    final provider = MoneroAPIProvider(
        identifier: APIUtils.getProviderIdentifier(),
        httpNodeUri: url.url,
        auth: url.auth);
    progressKey.progressText("monero_fetching_Wallet_addresses".tr);
    final client = MoneroWalletClient(provider, account.network);
    final walletAddresses =
        await MethodUtils.call(() => client.readMoneroWalletAdresses());
    if (walletAddresses.hasError) {
      progressKey.errorText(walletAddresses.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    final List<MoneroWalletRPCAddress> accountsIndexes = [];
    for (final i in walletAddresses.result) {
      for (final e in i.addresses) {
        if (allRelatedAccountAddresses.contains(e.address)) {
          accountsIndexes.add(e);
        }
      }
    }
    if (accountsIndexes.isEmpty) {
      progressKey.errorText("wallet_rpc_different_account_response_desc".tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.progressText("monero_fetching_Wallet_available_transfers".tr);
      final result = await MethodUtils.call(
          () => client.readMoneroWalletTxes(accountsIndexes.toList()));
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
        return;
      }
      if (walletRpcSync) {
        await account.updateWalletRPC(provider);
        walletProvider = provider;
      }
      final relatedTxIds = MoneroAccountPendingTxes(
          txIDs: result.result.map((e) => e.txHash).toSet().toList(),
          primaryAddress: address.addrDetails.primaryAccount());
      if (relatedTxIds.txIDs.isEmpty) {
        progressKey.errorText("monero_wallet_rpc_sync_no_tx_found_desc".tr,
            backToIdle: false, showBackButton: true);
        return;
      }
      progressKey.progressText("retrieving_transaction".tr);
      final unlockedInfo = await wallet.wallet
          .moneroUpdatePendingTxes(account: account, txIds: [relatedTxIds]);
      if (unlockedInfo.hasError) {
        progressKey.errorText(unlockedInfo.error!.tr);
        return;
      }
      payments = unlockedInfo.result;
      if (payments!.isEmpty) {
        progressKey.successProgress(
            progressWidget: ProgressWithTextView(
              text: "monero_empty_outputs_desc".tr,
              icon: const Icon(Icons.hourglass_empty),
            ),
            backToIdle: true);
        return;
      }
      option = _SyncOptionsPage.showPayment;
      progressKey.success(backToIdle: true);
    }
  }

  void resetToDefault() {
    if (option == null) return;
    option = null;
    progressKey.backToIdle();
    updateState();
  }

  String? validateTransactionIds(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "enter_transaction_ids_validator".tr;
    }
    final txIds = StrUtils.separateBySpace(v).map((e) => e.toLowerCase());
    if (txIds.isEmpty) {
      return "enter_transaction_ids_validator".tr;
    }
    final isValid = txIds.every((e) => APPConst.hex32Bytes.hasMatch(e));
    if (!isValid) return "enter_transaction_ids_validator2".tr;
    if (txIds.toSet().length != txIds.length) {
      return "duplicate_transaction_ids_detected".tr;
    }
    return null;
  }

  void syncBlockHeight() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("submiting_sync_process".tr);
    final result = await MethodUtils.call(() async {
      final request = account.createSyncRequest(
          accounts: addresses, startHeight: startBlock, endHeight: endBlock);
      final sync = await wallet.wallet.moneroAddSyncRequest(
          account: account, address: address, request: request);
      return sync.result;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
      return;
    }
    progressKey.success(backToIdle: false);
  }

  void syncTransactionIds() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final txes = txIdsStateKey.currentState?.getValue();
    final txIds = StrUtils.separateBySpace(txes);
    final relatedTxIds = MoneroAccountPendingTxes(
        txIDs: txIds, primaryAddress: address.addrDetails.primaryAccount());
    if (txIds.isEmpty) return;
    progressKey.progressText("retrieving_transaction".tr);

    final unlockedInfo = await wallet.wallet
        .moneroUpdatePendingTxes(account: account, txIds: [relatedTxIds]);
    if (unlockedInfo.hasError) {
      progressKey.errorText(unlockedInfo.error!.tr);
      return;
    }
    payments = unlockedInfo.result;
    if (payments!.isEmpty) {
      progressKey.successProgress(
          progressWidget: ProgressWithTextView(
            text: "monero_empty_outputs_desc".tr,
            icon: const Icon(Icons.hourglass_empty),
          ),
          backToIdle: true);
      return;
    }
    option = _SyncOptionsPage.showPayment;
    progressKey.success(backToIdle: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => initOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      canPop: option == null,
      key: formKey,
      onPopInvokedWithResult: (didPop, result) {
        resetToDefault();
      },
      child: PageProgress(
          key: progressKey,
          backToIdle: APPConst.twoSecoundDuration,
          initialStatus: StreamWidgetStatus.progress,
          child: (context) {
            return Center(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  WidgetConstant.sliverPaddingVertial20,
                  SliverConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    sliver: APPSliverAnimatedSwitcher<_SyncOptionsPage>(
                        enable: option,
                        widgets: {
                          null: (c) => _SelectOptions(this),
                          _SyncOptionsPage.walletRPC: (c) =>
                              _WalletRPCSynOption(this),
                          _SyncOptionsPage.transactions: (c) =>
                              _TransactionSyncOption(this),
                          _SyncOptionsPage.block: (c) =>
                              _AtHeightSyncOpetion(this),
                          _SyncOptionsPage.showPayment: (c) =>
                              _ShowPayments(state: this, payments: payments!)
                        }),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class _SelectOptions extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _SelectOptions(this.state);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("sync_options".tr, style: context.textTheme.titleMedium),
          Text("monero_sync_options_desc".tr),
          WidgetConstant.height8,
          AppDropDownBottom(
            hint: "sync_options".tr,
            items: state.options,
            onChanged: state.onChangeOption,
          )
        ],
      ),
    );
  }
}

class _WalletRPCSynOption extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _WalletRPCSynOption(this.state);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "monero_wallet_rpc_sync_desc".tr,
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("monero_wallet_rpc_sync_desc1".tr),
                    Text("monero_wallet_rpc_sync_desc2".tr),
                    WidgetConstant.height8,
                    ErrorTextContainer(
                        error: "monero_wallet_rpc_safty_interacting_desc".tr,
                        enableTap: false),
                  ])),
          AppSwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.walletRpcSync,
            onChanged: state.onChangeWalletRpcSync,
            title: Text("maintain_monero_wallet_rpc_connection".tr,
                style: context.textTheme.titleMedium),
            subtitle: Text("store_wallet_rpc_connection".tr),
          ),
          WidgetConstant.height20,
          APPAnimatedSwitcher(enable: state.walletRpcConnected, widgets: {
            false: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("wallet_rpc_url".tr,
                      style: context.textTheme.titleMedium),
                  Text("wallet_rpc_url_desc".tr),
                  WidgetConstant.height8,
                  HTTPServiceProviderFields(
                    key: state.serviceProviderStateKey,
                    initialUrl: state.rpcUrl,
                    hint: MoneroConst.walletRPCLinkExample,
                    enableAuth: true,
                    protocols: [ServiceProtocol.http],
                  ),
                ]),
            true: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("wallet_rpc".tr, style: context.textTheme.titleMedium),
                  Text("already_connected_to_monero_wallet_rpc".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: CopyableTextWidget(
                        text: state.walletProvider!.callUrl,
                        color: context.onPrimaryContainer),
                  ),
                ])
          }),
          APPAnimatedSwitcher(enable: state.walletRpcConnected, widgets: {
            false: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical40,
                        onPressed: state.syncFromRpc,
                        child: Text("sync_now".tr)),
                  ],
                )
          }),
        ],
      ),
    );
  }
}

class _TransactionSyncOption extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _TransactionSyncOption(this.state);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "monero_wallet_transaction_sync_desc".tr,
              body: Text("monero_wallet_transaction_sync_desc2".tr)),
          Text("transaction_id".tr, style: context.textTheme.titleMedium),
          Text("enter_transaction_ids_desc".tr),
          WidgetConstant.height8,
          AppTextField(
              label: "transaction_ids".tr,
              pasteIcon: true,
              maxLines: 5,
              minlines: 2,
              validator: state.validateTransactionIds,
              keyboardType: TextInputType.text,
              key: state.txIdsStateKey),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.syncTransactionIds,
                  child: Text("sync_now".tr)),
            ],
          )
        ],
      ),
    );
  }
}

class _ShowPayments extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  final List<MoneroUnlockedPaymentRequestDetails> payments;
  const _ShowPayments({required this.state, required this.payments});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("payment_information".tr,
                style: context.textTheme.titleMedium),
            Text("monero_payment_synced_desc".tr),
            WidgetConstant.height8,
          ],
        ),
      ),
      SliverList.separated(
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _ShowPayment(payment: payment, network: state.network);
          },
          itemCount: payments.length,
          separatorBuilder: (context, index) => WidgetConstant.divider),
      SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                child: Text("sync_more".tr),
                onPressed: () {
                  state.resetToDefault();
                }),
          ],
        ),
      ),
    ]);
  }
}

class _ShowPayment extends StatelessWidget {
  const _ShowPayment({required this.payment, required this.network});
  final MoneroUnlockedPaymentRequestDetails payment;
  final WalletMoneroNetwork network;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        onRemove: () {},
        enableTap: false,
        onRemoveWidget: ConditionalWidgets<MoneroUnlockPaymentRequestStatus>(
            enable: payment.status,
            widgets: {
              MoneroUnlockPaymentRequestStatus.error: (context) =>
                  WidgetConstant.errorIcon,
              MoneroUnlockPaymentRequestStatus.success: (context) {
                return ConditionalWidgets(
                    enable: payment.output!.status,
                    widgets: {
                      MoneroUnlockPaymentRequestOutputStatus.unspent:
                          (context) => TappedTooltipView(
                                tooltipWidget: ToolTipView(
                                    message: "output_is_ready_to_spent".tr,
                                    child: Icon(Icons.attach_money_rounded,
                                        color: context.colors.green)),
                              ),
                      MoneroUnlockPaymentRequestOutputStatus.spent: (context) =>
                          TappedTooltipView(
                            tooltipWidget: ToolTipView(
                                message: "output_has_already_spent".tr,
                                child: Icon(Icons.money_off_rounded,
                                    color: context.colors.onPrimaryContainer)),
                          ),
                      MoneroUnlockPaymentRequestOutputStatus.pool: (context) =>
                          TappedTooltipView(
                            tooltipWidget: ToolTipView(
                                message: "output_has_already_spent".tr,
                                child: Icon(Icons.money_off_rounded,
                                    color: context.colors.onPrimaryContainer)),
                          ),
                    });
              }
            }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OneLineTextWidget(payment.txID,
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
            ConditionalWidgets<MoneroUnlockPaymentRequestStatus>(
                enable: payment.status,
                widgets: {
                  MoneroUnlockPaymentRequestStatus.success: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoinPriceView(
                            token: network.token,
                            balance: payment.output!.amount,
                            style: context.colors.onPrimaryContainer
                                .lableLarge(context),
                            symbolColor: context.colors.onPrimaryContainer),
                      ],
                    );
                  }
                }),
          ],
        ));
  }
}

class _AtHeightSyncOpetion extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _AtHeightSyncOpetion(this.state);
  @override
  Widget build(BuildContext context) {
    return SliverConstraintsBoxView(
      padding: WidgetConstant.paddingHorizontal20,
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
                title: "monero_block_height_sync_desc".tr,
                body: LargeTextView([
                  "monero_block_height_sync_desc2".tr,
                  "monero_block_height_sync_desc3".tr,
                  "monero_rct_block_validator"
                      .tr
                      .replaceOne(state.network.coinParam.rctHeight.toString())
                ])),
            WidgetConstant.height20,
            Text("select_account".tr, style: context.textTheme.titleMedium),
            Text("select_accounts_for_syncing".tr),
            WidgetConstant.height8,
            Column(
              children: List.generate(state.addresses.length, (index) {
                final address = state.addresses[index];
                return ContainerWithBorder(
                  onRemoveIcon: Icon(Icons.remove_circle,
                      color: context.colors.onPrimaryContainer),
                  onRemove: () {
                    state.removeAddress(address);
                  },
                  child: AddressDetailsView(
                      address: address,
                      showBalance: false,
                      color: context.onPrimaryContainer),
                );
              }),
            ),
            FormField<bool>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: state.addresses.isEmpty,
                validator: (value) => state.addresses.isNotEmpty ? null : "",
                builder: (field) {
                  return ContainerWithBorder(
                      validate: state.addresses.isNotEmpty,
                      validateText: "at_least_one_account_required".tr,
                      onRemove: () {
                        context
                            .openSliverBottomSheet<IMoneroAddress>(
                              "select_account".tr,
                              child: SwitchOrSelectAccountView(
                                  account: state.account, showMultiSig: true),
                              centerContent: false,
                            )
                            .then(state.addAddress);
                      },
                      onRemoveIcon: Icon(
                        Icons.add_box,
                        color: context.onPrimaryContainer,
                      ),
                      child: Text(
                        "tap_to_add_account".tr,
                        style: context.onPrimaryTextTheme.bodyMedium,
                      ));
                }),
            WidgetConstant.height20,
            NumberTextField(
                label: "start_at_block".tr,
                onChange: state.onBlockStart,
                min: state.network.coinParam.rctHeight,
                max: state.max,
                defaultValue: state.startBlock,
                validator: state.validateOnBlockStart),
            WidgetConstant.height20,
            NumberTextField(
                label: "end_at_block".tr,
                onChange: state.onBlockEnd,
                min: state.network.coinParam.rctHeight,
                validator: state.validateOnBlockEnd,
                defaultValue: state.endBlock,
                max: state.max),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                    padding: WidgetConstant.paddingVertical40,
                    onPressed: state.syncBlockHeight,
                    child: Text("sync_now".tr)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

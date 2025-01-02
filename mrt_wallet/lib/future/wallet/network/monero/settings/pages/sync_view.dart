import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/monero/account/state.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';

class MoneroAccountSyncView extends StatelessWidget {
  const MoneroAccountSyncView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<MoneroChain>(
      title: "sync_information".tr,
      allowEmptyAccount: false,
      childBulder: (wallet, chain, onAccountChanged) =>
          _MoneroAccountSyncView(wallet: wallet, chain: chain),
    );
  }
}

class _MoneroAccountSyncView extends StatefulWidget {
  const _MoneroAccountSyncView({required this.wallet, required this.chain});
  final WalletProvider wallet;
  final MoneroChain chain;

  @override
  State<_MoneroAccountSyncView> createState() => _MoneroAccountSyncViewState();
}

class _MoneroAccountSyncViewState
    extends MoneroAccountState<_MoneroAccountSyncView> {
  @override
  MoneroChain get account => widget.chain;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();
  late MoneroAccountBlocksTracker defaultTracker = account.defaultTracker;
  Map<MoneroAccountBlocksTracker, Widget> syncRequests = {};
  List<_SyncedAddressWithHeight> syncAddresses = [];
  List<MoneroBlockTrackingPossition> failedBlocks = [];

  late double currentHeight;

  void onChangeTracker(MoneroAccountBlocksTracker? tracker) {
    if (tracker == null) return;
    defaultTracker = tracker;
    findAddresses();
    updateState();
  }

  void findAddresses() {
    final addresses =
        defaultTracker.accounts.map((e) => e.getAddresses()).expand((e) => e);
    syncAddresses = addresses.map((e) {
      final address = account.getReceiptAddress(e.address.address) ??
          ReceiptAddress<MoneroAddress>(
              networkAddress: e.address, view: e.address.address);
      return _SyncedAddressWithHeight(height: e.startHeight, address: address);
    }).toList();
    failedBlocks = defaultTracker.failedOffsets;
  }

  void updateStatus(MoneroAccountBlocksTrackerStatus status) async {
    progressKey.progressText("updating_status_pls_wait".tr);
    final wallet = context.watch<WalletProvider>(StateConst.main);
    await wallet.wallet.moneroUpdateTrackerStatus(
        tracker: defaultTracker, account: account, status: status);
    progressKey.backToIdle();
  }

  Future<void> init() async {
    final requests = await account.getSyncRequests();
    syncRequests = {
      account.defaultTracker: Text("default_chain_sync".tr),
      for (final i in requests.requests)
        i: Text("requested_synchronizations"
            .tr
            .replaceOne(i.created.toDateAndTime()))
    };

    final result = await MethodUtils.call(() async {
      final height = await client.getHeight();
      return height.block;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
      return;
    }
    currentHeight = result.result.toDouble();
    findAddresses();
    progressKey.backToIdle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => init());
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialStatus: StreamWidgetStatus.progress,
      backToIdle: APPConst.oneSecoundDuration,
      child: (context) => CustomScrollView(
        slivers: [
          SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("available_synchronizations".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        AppDropDownBottom(
                            items: syncRequests,
                            value: defaultTracker,
                            onChanged: onChangeTracker,
                            isExpanded: true),
                        if (defaultTracker.isRequest) ...[
                          WidgetConstant.height20,
                          Text("status".tr),
                          WidgetConstant.height8,
                          ContainerWithBorder(
                            enableTap: false,
                            onRemoveWidget: ConditionalWidgets(
                                enable: defaultTracker.status,
                                widgets: {
                                  MoneroAccountBlocksTrackerStatus.paused:
                                      (context) => ElevatedButton(
                                          onPressed: () {
                                            updateStatus(
                                                MoneroAccountBlocksTrackerStatus
                                                    .pending);
                                          },
                                          child: Text("resume".tr)),
                                  MoneroAccountBlocksTrackerStatus.pending:
                                      (context) => ElevatedButton(
                                          onPressed: () {
                                            updateStatus(
                                                MoneroAccountBlocksTrackerStatus
                                                    .paused);
                                          },
                                          child: Text("pause".tr))
                                }),
                            onRemove: () {
                              //  if (defaultTracker.status.inProcess)
                            },
                            child: Text(defaultTracker.status.name.tr,
                                style: context.onPrimaryTextTheme.bodyMedium),
                          ),
                        ],
                        WidgetConstant.height20,
                        Text("fetched_blocks".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${defaultTracker.startHeight.toString()}/${defaultTracker.currentHeight.toString()}",
                                  style: context.onPrimaryTextTheme.bodyMedium),
                              SliderTheme(
                                data: SliderThemeData(
                                    rangeThumbShape: RoundRangeSliderThumbShape(
                                        enabledThumbRadius: 5,
                                        elevation: 5,
                                        pressedElevation: 0)),
                                child: RangeSlider(
                                    values: RangeValues(
                                        defaultTracker.startHeight.toDouble(),
                                        defaultTracker.currentHeight
                                            .toDouble()),
                                    onChanged: (e) {},
                                    min: defaultTracker.startHeight.toDouble(),
                                    max: defaultTracker.endHeight.toDouble(),
                                    activeColor: context.colors.primary,
                                    inactiveColor: context.onPrimaryContainer),
                              ),
                            ],
                          ),
                        ),
                        WidgetConstant.height20,
                        Text("current_block_height".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          child: Text(currentHeight.toInt().toString(),
                              style: context.onPrimaryTextTheme.bodyMedium),
                        ),
                        WidgetConstant.height20,
                        Text("addresses".tr,
                            style: context.textTheme.titleMedium),
                        Text("addresses_and_initial_sync_block".tr,
                            style: context.textTheme.bodyMedium),
                        WidgetConstant.height8,
                        ListView.separated(
                            shrinkWrap: true,
                            physics: WidgetConstant.noScrollPhysics,
                            itemBuilder: (context, index) {
                              final address = syncAddresses[index];
                              return ContainerWithBorder(
                                child: Column(
                                  children: [
                                    ContainerWithBorder(
                                      backgroundColor:
                                          context.onPrimaryContainer,
                                      child: ReceiptAddressDetailsView(
                                        address: address.address,
                                        color: context.primaryContainer,
                                      ),
                                    ),
                                    Divider(color: context.onPrimaryContainer),
                                    ContainerWithBorder(
                                      backgroundColor:
                                          context.onPrimaryContainer,
                                      child: Text(address.height.toString(),
                                          style: context
                                              .primaryTextTheme.bodyMedium),
                                    )
                                  ],
                                ),
                              );
                            },
                            itemCount: syncAddresses.length,
                            separatorBuilder: (context, index) =>
                                WidgetConstant.divider),
                        if (failedBlocks.isNotEmpty) ...[
                          WidgetConstant.height20,
                          Text(
                            "faliled_blocks".tr,
                            style: context.onPrimaryTextTheme.titleMedium,
                          ),
                          WidgetConstant.height8,
                          ListView.separated(
                              shrinkWrap: true,
                              physics: WidgetConstant.noScrollPhysics,
                              itemBuilder: (context, index) {
                                final failedBlock = failedBlocks[index];
                                return ContainerWithBorder(
                                  child: Text(
                                      "${failedBlock.startHeight.toString()}/${failedBlock.endHeight.toString()}",
                                      style: context
                                          .onPrimaryTextTheme.bodyMedium),
                                );
                              },
                              itemCount: failedBlocks.length,
                              separatorBuilder: (context, index) =>
                                  WidgetConstant.divider),
                        ],
                      ],
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class _SyncedAddressWithHeight {
  final int height;
  final ReceiptAddress<MoneroAddress> address;
  const _SyncedAddressWithHeight({required this.height, required this.address});
}

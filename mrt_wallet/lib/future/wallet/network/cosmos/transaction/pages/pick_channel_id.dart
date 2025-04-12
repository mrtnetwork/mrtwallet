import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/channel_id/account_channel_ids.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

typedef ONSELECTCHANNELID = void Function(BuildContext, String);

class CosmosPickChannelIdView extends StatefulWidget {
  final ScrollController controller;
  final CosmosChain sourceChain;
  final CosmosChain destinationChain;
  final ONSELECTCHANNELID onSelectChannelId;
  const CosmosPickChannelIdView(
      {required this.controller,
      required this.sourceChain,
      required this.destinationChain,
      required this.onSelectChannelId,
      super.key});

  @override
  State<CosmosPickChannelIdView> createState() =>
      _CosmosPickChannelIdViewState();
}

class _CosmosPickChannelIdViewState
    extends CosmosAccountState<CosmosPickChannelIdView> with ProgressMixin {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool checkConnection = true;
  CW20Token? sourceToken;
  CW20Token? destionationToken;
  final _channelIdRegex = RegExp(CosmosConst.ibcChannelRegex);
  @override
  CosmosChain get account => widget.sourceChain;
  List<CosmosIBCChannelId> channelIds = [];

  Live<bool> saveChannelId = Live<bool>(false);

  void checkSaveAbility() {
    saveChannelId.value = _channelIdRegex.hasMatch(channelId) &&
        !channelIds.any((e) => e.channelId == channelId);
  }

  void onChangeCheckConnection(bool? _) {
    checkConnection = !checkConnection;
    updateState();
  }

  String channelId = '';
  void onChangeChannelId(String channelId) {
    this.channelId = channelId;
    checkSaveAbility();
  }

  Future<void> _init() async {
    sourceToken = widget.sourceChain.network.coinParam.nativeToken;
    destionationToken = widget.destinationChain.network.coinParam.nativeToken;
    channelIds = await getAccountIbcChannels();
    progressKey.backToIdle();
  }

  String? validateChannelId(String? channelId) {
    if (channelId == null || !_channelIdRegex.hasMatch(channelId)) {
      return "ibc_channel_validator".tr;
    }
    return null;
  }

  Future<void> saveChannel() async {
    final channelId = this.channelId;
    if (!_channelIdRegex.hasMatch(channelId)) return;
    if (channelIds.any((e) => e.channelId == channelId)) return;
    final name = await context.openSliverBottomSheet<String>(
      "channel_name".tr,
      child: StringWriterView(
        maxLines: null,
        minLines: null,
        minLength: 1,
        maxLength: APPConst.maxNameLength,
        title: PageTitleSubtitle(
            title: "channel_id".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("channel_name_desc".tr),
                ContainerWithBorder(
                  child: Text(channelId,
                      style: context.onPrimaryTextTheme.bodyMedium),
                ),
              ],
            )),
        buttonText: "save_channel_id".tr,
        label: "channel_name".tr,
      ),
    );
    if (name == null) return;
    await account
        .saveChannelId(CosmosIBCChannelId(name: name, channelId: channelId));
    channelIds = await getAccountIbcChannels();
    context.showAlert("channel_id_saved".tr);
    checkSaveAbility();
    updateState();
  }

  Future<IbcChannelChannel?> _checkChannelConnection(
      {required CosmosChain chain, required String channelId}) async {
    progressKey.progressText("checking_chain_channel_id_connection"
        .tr
        .replaceOne(chain.network.networkName));
    final r = await MethodUtils.call(() async {
      return await chain.client.getTransferChannel(channelId);
    });
    if (r.hasError) {
      progressKey.errorText(r.error!.tr,
          backToIdle: false, showBackButton: true);
      return null;
    }
    if (r.result == null) {
      progressKey.errorText(
          "channel_not_found_in".tr.replaceOne(chain.network.networkName),
          backToIdle: false,
          showBackButton: true);
      return null;
    }
    if (r.result!.state != IbcChannelState.open) {
      progressKey.errorText("ibc_channel_incorrect_state".tr,
          backToIdle: false, showBackButton: true);
      return null;
    }
    return r.result!;
  }

  Future<void> checkChannelConnection() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final channelId = this.channelId;
    if (checkConnection) {
      final source = await _checkChannelConnection(
          chain: widget.sourceChain, channelId: channelId);
      if (source == null) return;
      final destination = await _checkChannelConnection(
          chain: widget.destinationChain,
          channelId: source.counterparty.channelId!);
      if (destination == null) return;
      if (source.version != destination.version) {
        progressKey.errorText("ibc_source_destination_version_mismatch".tr,
            backToIdle: false, showBackButton: true);
        return;
      }
    }
    progressKey.success();
    widget.onSelectChannelId(context, channelId);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void safeDispose() {
    super.safeDispose();
    sourceToken?.balance.dispose();
    destionationToken?.balance.dispose();
    sourceToken = null;
    destionationToken = null;
    saveChannelId.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("pick_channel".tr)),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: PageProgress(
          key: progressKey,
          backToIdle: APPConst.oneSecoundDuration,
          initialStatus: StreamWidgetStatus.progress,
          child: (context) {
            return CustomScrollView(
              controller: widget.controller,
              slivers: [
                SliverConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    sliver: SliverToBoxAdapter(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("source_chain".tr,
                                style: context.textTheme.titleMedium),
                            WidgetConstant.height8,
                            TokenDetailsView(
                              token: sourceToken!,
                              radius: APPConst.circleRadius25,
                            ),
                            WidgetConstant.height20,
                            Text("destination_chain".tr,
                                style: context.textTheme.titleMedium),
                            WidgetConstant.height8,
                            TokenDetailsView(
                              token: destionationToken!,
                              radius: APPConst.circleRadius25,
                            ),
                            WidgetConstant.height20,
                            Text("channel_id".tr,
                                style: context.textTheme.titleMedium),
                            Text('ibc_channel_desc'.tr),
                            WidgetConstant.height8,
                            AppTextField(
                              label: 'channel_id'.tr,
                              hint: 'example_s'
                                  .tr
                                  .replaceOne(APPConst.exampleChannelId),
                              validator: validateChannelId,
                              onChanged: onChangeChannelId,
                              initialValue: channelId,
                              pasteIcon: true,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConditionalWidget(
                                    enable: channelIds.isNotEmpty,
                                    onActive: (context) => IconButton(
                                        onPressed: () {
                                          context.openSliverDialog(
                                              (context) =>
                                                  SelectCosmosAccountIbcChannelView(
                                                      channelIds),
                                              'saved_channels'.tr);
                                        },
                                        icon: Icon(Icons.list)),
                                  ),
                                  LiveWidget(() {
                                    final save = saveChannelId.value;
                                    return APPAnimatedSize(
                                        isActive: save,
                                        onActive: (context) => IconButton(
                                            onPressed: saveChannel,
                                            icon: Icon(Icons.save)),
                                        onDeactive: (context) =>
                                            WidgetConstant.sizedBox);
                                  })
                                ],
                              ),
                            ),
                            WidgetConstant.height20,
                            AppCheckListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("check_channel_connection".tr),
                                subtitle:
                                    Text("check_channel_connection_desc".tr),
                                value: checkConnection,
                                onChanged: onChangeCheckConnection),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FixedElevatedButton(
                                    padding: WidgetConstant.paddingVertical40,
                                    onPressed: checkChannelConnection,
                                    child: Text("pick_channel".tr))
                              ],
                            )
                          ]),
                    ))
              ],
            );
          },
        ),
      ),
    );
  }
}

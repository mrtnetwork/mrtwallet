import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateMetadataConstantsView extends StatelessWidget {
  const SubstrateMetadataConstantsView(
      {this.scrollController, this.account, super.key});
  final SubstrateChain? account;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SubstrateChain>(
        clientRequired: true,
        allowEmptyAccount: false,
        title: 'constants'.tr,
        account: account,
        childBulder: (wallet, chain, onAccountChanged) =>
            SubstrateMetadataConstantsWidget(
                account: chain, scrollController: scrollController));
  }
}

class SubstrateMetadataConstantsWidget extends StatefulWidget {
  const SubstrateMetadataConstantsWidget(
      {super.key, required this.account, this.scrollController});
  final SubstrateChain account;
  final ScrollController? scrollController;

  @override
  State<SubstrateMetadataConstantsWidget> createState() =>
      _SubstrateMetadataConstantsWidgetState();
}

class _SubstrateMetadataConstantsWidgetState
    extends SubstrateAccountState<SubstrateMetadataConstantsWidget> {
  late final List<PalletInfo> contantsPallets;
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  Map<PalletInfo, Text> items = {};
  late PalletInfo pallet;
  void onChangePallet(PalletInfo? pallet) {
    this.pallet = pallet ?? this.pallet;
    updateState();
  }

  Future<void> init() async {
    contantsPallets = client.metadata.constantPallets();
    items = {for (final i in contantsPallets) i: Text(i.name)};
    pallet = contantsPallets.first;
    progressKey.backToIdle();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() => init());
  }

  @override
  SubstrateChain get account => widget.account;
  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      initialStatus: StreamWidgetStatus.progress,
      initialWidget:
          ProgressWithTextView(text: 'retrieving_constants_please_wait'.tr),
      child: (context) {
        return CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverMainAxisGroup(slivers: [
                SliverPinnedHeaderSurface(
                    elevation: APPConst.elevation,
                    child: AppDropDownBottom(
                        items: items,
                        onChanged: onChangePallet,
                        value: pallet)),
                SliverPadding(
                  padding: WidgetConstant.paddingHorizontal20,
                  sliver: APPSliverAnimatedSwitcher(enable: pallet, widgets: {
                    pallet: (context) => PalletConstantsView(pallet: pallet)
                  }),
                )
              ]),
            ),
          ],
        );
      },
    );
  }
}

class PalletConstantsView extends StatelessWidget {
  const PalletConstantsView({super.key, required this.pallet});
  final PalletInfo pallet;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        final call = pallet.contants![index];
        return AppListTile(
            title: Text(call.name),
            maxLine: 10,
            trailing: IconButton(
                onPressed: () {
                  context.openSliverDialog((context) {
                    return ContainerWithBorder(
                      child: CopyableTextWidget(
                        text: call.value?.toString() ?? '',
                        color: context.onPrimaryContainer,
                        maxLines: null,
                        widget: APPSelectableText(
                          call.value?.toString() ?? '',
                          style: context.onPrimaryTextTheme.titleMedium,
                        ),
                      ),
                    );
                  }, call.name);
                },
                icon: const Icon(Icons.remove_red_eye)),
            contentPadding: EdgeInsets.zero,
            subtitle: LargeTextView(call.docs, textAligen: TextAlign.start));
      },
      itemCount: pallet.contants!.length,
    );
  }
}

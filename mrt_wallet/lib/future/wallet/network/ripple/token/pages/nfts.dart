import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/widgets/nft_info.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class MonitorRippleNFTsView extends StatelessWidget {
  const MonitorRippleNFTsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<RippleChain>(
      title: "manage_nfts".tr,
      childBulder: (wallet, account, switchRippleAccount) {
        return _MonitorRippleNFTsView(
            account: account, wallet: wallet, provider: account.provider()!);
      },
    );
  }
}

class _MonitorRippleNFTsView extends StatefulWidget {
  const _MonitorRippleNFTsView(
      {required this.account, required this.wallet, required this.provider});
  final RippleChain account;
  final WalletProvider wallet;
  final RippleClient provider;

  @override
  State<_MonitorRippleNFTsView> createState() =>
      ___MonitorRippleNFTsViewState();
}

class ___MonitorRippleNFTsViewState extends State<_MonitorRippleNFTsView>
    with SafeState {
  IXRPAddress get address => widget.account.address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_MonitorRippleNFTsViewState");
  final Set<RippleNFToken> nfts = {};
  final ScrollController controller = ScrollController();
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodUtils.call(() async {
      return await widget.provider.provider.request(XRPRPCAccountNFTs(
          account: address.networkAddress.address, limit: 50000));
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      final rippleNfts = result.result.map((e) => RippleNFToken(
          flags: e.flags,
          nftokenId: e.nftokenId,
          issuer: e.issuer,
          nftokenTaxon: e.nftokenTaxon,
          serial: e.serial,
          uri: e.uri == null ? null : QuickBytesUtils.hexToString(e.uri!)));
      nfts.addAll(rippleNfts);
      progressKey.success();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchingTokens();
  }

  Future<void> add(RippleNFToken nft) async {
    final result = await widget.wallet.wallet
        .addNewNFT(nft: nft, address: address, account: widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeNFT(RippleNFToken nft) async {
    final result = await widget.wallet.wallet
        .removeNFT(nft: nft, address: address, account: widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> onTap(RippleNFToken nft, bool exist) async {
    try {
      if (exist) {
        await removeNFT(nft);
      } else {
        await add(nft);
      }
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialStatus: PageProgressStatus.progress,
      backToIdle: APPConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      child: (c) {
        return EmptyItemWidgetView(
          isEmpty: nfts.isEmpty,
          itemBuilder: () => ConstraintsBoxView(
            padding: WidgetConstant.padding20,
            child: ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                final nft = nfts.elementAt(index);
                return Column(
                  children: [
                    ContainerWithBorder(
                      child: RippleNFTokenView(nft: nft),
                    ),
                    const Divider(),
                  ],
                );
              },
              shrinkWrap: true,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              itemCount: nfts.length,
            ),
          ),
        );
      },
    );
  }
}

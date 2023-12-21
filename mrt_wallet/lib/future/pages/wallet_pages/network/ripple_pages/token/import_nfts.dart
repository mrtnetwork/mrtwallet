import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/bytes_utils/quick_bytes.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/global/controll_ripple_transaction_account.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/widgets/nft_info.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/nfts/networks/ripple/ripple_nft_token.dart';
import 'package:mrt_wallet/provider/api/networks/ripple/custom_request/fetch_nft_request.dart';
import 'package:mrt_wallet/provider/api/networks/ripple/ripple_api_provider.dart';

class MonitorRippleNFTsView extends StatelessWidget {
  const MonitorRippleNFTsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ControllerRippleTransactionAccountView(
      title: "manage_nfts".tr,
      childBulder:
          (wallet, account, address, network, provider, switchRippleAccount) {
        return _MonitorRippleNFTsView(
            address: address, wallet: wallet, provider: provider);
      },
    );
  }
}

class _MonitorRippleNFTsView extends StatefulWidget {
  const _MonitorRippleNFTsView(
      {required this.address, required this.wallet, required this.provider});
  final IXRPAddress address;
  final WalletProvider wallet;
  final RippleApiProvider provider;

  @override
  State<_MonitorRippleNFTsView> createState() =>
      ___MonitorRippleNFTsViewState();
}

class ___MonitorRippleNFTsViewState extends State<_MonitorRippleNFTsView>
    with SafeState {
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_MonitorRippleNFTsViewState");
  final Set<RippleNFToken> nfts = {};
  final ScrollController controller = ScrollController();
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodCaller.call(() async {
      return await widget.provider.provider.request(XRPRPCAccountNFTs(
          account: widget.address.address.toAddress, limit: 50000));
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
    final result = await widget.wallet.addNewNFT(nft, widget.address);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeNFT(RippleNFToken nft) async {
    final result = await widget.wallet.removeNFT(nft, widget.address);
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
      backToIdle: AppGlobalConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      child: () {
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

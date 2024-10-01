import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class ImportTRC20TokenView extends StatelessWidget {
  const ImportTRC20TokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<TronChain>(
        childBulder: (walletProvider, chain, switchRippleAccount) {
          return _ImportTrc20TokenView(
            account: chain,
            apiProvider: chain.provider()!,
          );
        },
        title: "import_token".tr);
  }
}

class _ImportTrc20TokenView extends StatefulWidget {
  const _ImportTrc20TokenView({
    required this.account,
    // required this.network,
    required this.apiProvider,
  });
  final TronChain account;
  final TronClient apiProvider;

  @override
  State<_ImportTrc20TokenView> createState() => __ImportTrc20TokenViewState();
}

class __ImportTrc20TokenViewState extends State<_ImportTrc20TokenView> {
  late final ITronAddress address = widget.account.address;
  WalletTronNetwork get network => widget.account.network;
  ReceiptAddress<TronAddress>? contractAddress;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "__ImportTrc20TokenViewState");
  bool get hasContractAddress => contractAddress != null;

  void onSetupAddress(ReceiptAddress<TronAddress>? addr) {
    contractAddress = addr;
    setState(() {});
  }

  TronTRC20Token? token;
  void onAddToAccount() async {
    if (!hasContractAddress) return;
    final wallet = context.watch<WalletProvider>(StateConst.main);
    progressKey.progressText("retrieving_contract_detauls".tr);
    final result = await MethodUtils.call(() async {
      final data = await widget.apiProvider.solidityProvider
          .getAccountERC20Token(
              address.networkAddress, contractAddress!.networkAddress);
      return data;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else if (result.result == null) {
      progressKey.errorText("smart_contract_not_found".tr);
    } else {
      final addResult = await wallet.wallet.addNewToken(
          token: result.result! as TronToken,
          address: address,
          account: widget.account);

      if (addResult.hasError) {
        progressKey.errorText(addResult.error!.tr);
      } else {
        token = result.result! as TronTRC20Token;
        progressKey.success();
      }
    }
  }

  void onNewToken() {
    contractAddress = null;
    token = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => ConstraintsBoxView(
          padding: WidgetConstant.padding20,
          child: token != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleTokenImageView(token!.token, radius: 60),
                    WidgetConstant.height8,
                    Text(token!.token.name,
                        style: context.textTheme.labelLarge),
                    if (token!.issuer != null)
                      OneLineTextWidget(token!.issuer!),
                    WidgetConstant.height8,
                    CoinPriceView(
                        liveBalance: token!.balance,
                        token: token!.token,
                        style: context.textTheme.titleLarge),
                    WidgetConstant.height20,
                    FilledButton(
                        onPressed: onNewToken,
                        child: Text("import_new_token".tr))
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: "import_trc20_token".tr,
                          body: Text("import_erc20_desc".tr)),
                      ReceiptAddressView(
                        address: contractAddress,
                        title: "contract_address".tr,
                        onTap: () {
                          context
                              .openSliverBottomSheet<
                                      ReceiptAddress<TronAddress>>(
                                  "contract_address".tr,
                                  maxExtend: 1,
                                  minExtent: 0.8,
                                  initialExtend: 0.9,
                                  bodyBuilder: (c) =>
                                      SelectRecipientAccountView<TronAddress>(
                                          account: widget.account,
                                          scrollController: c,
                                          subtitle: PageTitleSubtitle(
                                              title: "contract_address".tr,
                                              body: Text(
                                                  "import_erc20_desc".tr))))
                              .then(onSetupAddress);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FixedElevatedButton(
                            padding: WidgetConstant.paddingVertical20,
                            onPressed:
                                hasContractAddress ? onAddToAccount : null,
                            child: Text("add_to_my_account".tr),
                          )
                        ],
                      )
                    ],
                  ),
                )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class UpdateNetworkView extends StatelessWidget {
  const UpdateNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        title: "update_network".tr,
        accsess: WalletAccsessType.unlock,
        onAccsess: (credential, password, network) =>
            _UpdateNetworkView(network));
  }
}

class _UpdateNetworkView extends StatefulWidget {
  const _UpdateNetworkView(this.network);
  final WalletNetwork network;
  @override
  State<_UpdateNetworkView> createState() => _UpdateNetworkViewState();
}

class _UpdateNetworkViewState extends State<_UpdateNetworkView>
    with SafeState<_UpdateNetworkView> {
  String symbol = '';
  String networkName = '';
  String explorerAddressLink = "";
  String explorerTransaction = "";
  void onChangeSymbol(String v) {
    symbol = v;
  }

  void onChangeNetworkName(String v) {
    networkName = v;
  }

  void onChangeExplorerAddress(String v) {
    explorerAddressLink = v;
  }

  void onChangeExplorerTransaction(String v) {
    explorerTransaction = v;
  }

  String? validateAddressLink(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final link = StrUtils.validateUri(v);
    if (link == null) return "validate_link_desc".tr;
    return null;
  }

  String? validateNetworkName(String? v) {
    if ((v?.isEmpty ?? true) || v!.length < 2 || v.length > 25) {
      return "network_name_validator".tr;
    }
    return null;
  }

  String? validateSymbol(String? v) {
    if ((v?.isEmpty ?? true) || v!.isEmpty || v.length > 6) {
      return "symbol_validator".tr;
    }
    return null;
  }

  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();

  Future<void> updateNetwork() async {
    final network = widget.network;
    final wallet = context.watch<WalletProvider>(StateConst.main);
    pageProgressKey.progressText("updating_network".tr);
    final updateNetwork = network.copyWith(
        coinParam: network.coinParam.updateParams(
            token: Token(
                name: networkName,
                symbol: symbol,
                decimal: network.coinParam.token.decimal!),
            addressExplorer: explorerAddressLink.nullOnEmpty,
            transactionExplorer: explorerTransaction.nullOnEmpty,
            updateProviders: network.coinParam.providers));
    final update = await MethodUtils.call(
        () async => wallet.wallet.updateImportNetwork(updateNetwork));
    if (update.hasError) {
      pageProgressKey.errorText(update.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      pageProgressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
    }
  }

  void _init() {
    final network = widget.network;
    networkName = network.token.name;
    symbol = network.token.symbol;
    explorerAddressLink = network.coinParam.addressExplorer ?? '';
    explorerTransaction = network.coinParam.transactionExplorer ?? '';
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusableChild(
      child: PageProgress(
        key: pageProgressKey,
        // initialStatus: StreamWidgetStatus.progress,
        child: (context) => CustomScrollView(
          slivers: [
            SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverToBoxAdapter(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("network_name".tr,
                          style: context.textTheme.titleMedium),
                      Text("network_name_desc".tr),
                      WidgetConstant.height8,
                      AppTextField(
                        initialValue: networkName,
                        onChanged: onChangeNetworkName,
                        validator: validateNetworkName,
                        label: "network_name".tr,
                      ),
                      WidgetConstant.height20,
                      Text("symbol".tr, style: context.textTheme.titleMedium),
                      Text("symbol_desc".tr),
                      WidgetConstant.height8,
                      AppTextField(
                          initialValue: symbol,
                          onChanged: onChangeSymbol,
                          validator: validateSymbol,
                          label: "symbol".tr),
                      WidgetConstant.height20,
                      Text("network_explorer_address_link".tr,
                          style: context.textTheme.titleMedium),
                      LargeTextView(["network_evm_explorer_address_desc".tr],
                          maxLine: 1),
                      WidgetConstant.height8,
                      AppTextField(
                        initialValue: explorerAddressLink,
                        onChanged: onChangeExplorerAddress,
                        validator: validateAddressLink,
                        label: "network_explorer_address_link".tr,
                        pasteIcon: true,
                      ),
                      WidgetConstant.height20,
                      Text("network_explorer_transaction_link".tr,
                          style: context.textTheme.titleMedium),
                      LargeTextView(
                          ["network_evm_explorer_transaction_desc".tr],
                          maxLine: 1),
                      WidgetConstant.height8,
                      AppTextField(
                        initialValue: explorerAddressLink,
                        onChanged: onChangeExplorerTransaction,
                        validator: validateAddressLink,
                        label: "network_explorer_transaction_link".tr,
                        pasteIcon: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FixedElevatedButton(
                              padding: WidgetConstant.paddingVertical40,
                              onPressed: updateNetwork,
                              child: Text("update_network".tr))
                        ],
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

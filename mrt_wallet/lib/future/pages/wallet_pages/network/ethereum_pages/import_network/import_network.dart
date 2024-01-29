import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class ImportEVMNetwork extends StatelessWidget {
  const ImportEVMNetwork({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImportEVMNetwork();
  }
}

class _ImportEVMNetwork extends StatefulWidget {
  const _ImportEVMNetwork();

  @override
  State<_ImportEVMNetwork> createState() => __ImportEVMNetworkState();
}

class __ImportEVMNetworkState extends State<_ImportEVMNetwork> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  final GlobalKey<AppTextFieldState> explorerFieldKey = GlobalKey();
  final GlobalKey<AppTextFieldState> transactionFieldKey = GlobalKey();
  late List<APPEVMNetwork> evmNetworks;
  String symbol = "";
  String networkName = "";
  String chainId = "";
  late String explorerAddressLink = "";
  late String explorerTransaction = "";
  String rpcUrl = "";
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    evmNetworks = wallet.networks().whereType<APPEVMNetwork>().toList();
  }

  void onPasteUri(String v) {
    uriFieldKey.currentState?.updateText(v);
  }

  void onPasteExplorerAddres(String v) {
    explorerFieldKey.currentState?.updateText(v);
  }

  void onPasteExplorerTransaction(String v) {
    transactionFieldKey.currentState?.updateText(v);
  }

  void onChangeSymbol(String v) {
    symbol = v;
  }

  void onChageUrl(String v) {
    rpcUrl = v;
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

  String? chainError;

  void onChangeChainId(String v) {
    chainId = v;
    if (chainError != null) {
      chainError = null;
      setState(() {});
    }
    final toBig = BigInt.tryParse(v);
    final exists = MethodCaller.nullOnException(() => evmNetworks
        .firstWhere((element) => element.coinParam.chainId == toBig));
    if (exists != null) {
      chainError = "network_chain_id_already_exist".tr;
      setState(() {});
    }
  }

  String? validateChainId(String? v) {
    final toInt = BigInt.tryParse(v ?? "");
    if (toInt == null) return "chain_id_validator".tr;
    return null;
  }

  String? validateNetworkName(String? v) {
    if ((v?.isEmpty ?? true) || v!.length < 2 || v.length > 25) {
      return "network_name_validator".tr;
    }
    return null;
  }

  String? validateRpcUrl(String? v) {
    final path =
        AppStringUtility.validateUri(v, schame: ["http", "https", "ws", "wss"]);
    if (path == null) return "rpc_url_validator".tr;
    return null;
  }

  String? validateSymbol(String? v) {
    if ((v?.isEmpty ?? true) || v!.isEmpty || v.length > 6) {
      return "symbol_validator".tr;
    }
    return null;
  }

  String? validateAddressLink(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final link = AppStringUtility.validateUri(v);
    if (link == null) return "validate_link_desc".tr;
    return null;
  }

  void onAddChain() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("checking_rpc_network_info".tr);
    final result = await MethodCaller.call(() async {
      final wallet = context.watch<WalletProvider>(StateIdsConst.main);

      final chain = BigInt.parse(chainId);
      final uri = Uri.parse(rpcUrl.trim()).normalizePath();
      final serviceProvider = EVMApiProviderService(
          serviceName: uri.toString(),
          websiteUri: AppStringUtility.removeSchame(uri.host),
          uri: uri.toString());
      final rpc = ChainUtils.buildEVMProvider(serviceProvider);
      APPEVMNetwork network = APPEVMNetwork(
          0,
          EVMNetworkParams(
              transactionExplorer: explorerTransaction.nullOnEmpty,
              addressExplorer: explorerAddressLink.nullOnEmpty,
              token: Token(
                  name: networkName,
                  symbol: symbol,
                  decimal: EthereumUtils.decimal),
              providers: [serviceProvider],
              chainId: chain,
              supportEIP1559: false,
              defaultNetwork: false,
              mainnet: false));
      final info = await rpc.getNetworkInfo();

      if (info.$1 != chain) {
        throw WalletException("invalid_chain_id");
      }
      if (info.$2) {
        network = network.copyWith(
            coinParam: network.coinParam.copyWith(supportEIP1559: true));
      }
      return await wallet.updateImportNetwork(network);
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
      appBar: AppBar(
        title: Text("import_network".tr),
      ),
      child: PageProgress(
        key: pageProgressKey,
        backToIdle: AppGlobalConst.twoSecoundDuration,
        child: () => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageTitleSubtitle(
                            title: "import_new_network".tr,
                            body: LargeTextView([
                              "import_new_network_desc1".tr,
                              "import_new_network_desc2".tr
                            ])),
                        Text("chain_id".tr,
                            style: context.textTheme.titleMedium),
                        Text("chain_id_desc".tr),
                        WidgetConstant.height8,
                        NumberTextField(
                            label: "chain_id".tr,
                            defaultValue: BigInt.tryParse(chainId)?.toInt(),
                            onChange: onChangeChainId,
                            validator: validateChainId,
                            error: chainError,
                            max: null,
                            min: 0),
                        WidgetConstant.height20,
                        Text("rpc_url".tr,
                            style: context.textTheme.titleMedium),
                        Text("rpc_url_desc".tr),
                        WidgetConstant.height8,
                        AppTextField(
                          key: uriFieldKey,
                          initialValue: rpcUrl,
                          onChanged: onChageUrl,
                          validator: validateRpcUrl,
                          suffixIcon: PasteTextIcon(onPaste: onPasteUri),
                          label: "rpc_url".tr,
                        ),
                        WidgetConstant.height20,
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
                          label: "symbol".tr,
                        ),
                        WidgetConstant.height20,
                        Text("network_explorer_address_link".tr,
                            style: context.textTheme.titleMedium),
                        Text("network_evm_explorer_address_desc".tr),
                        WidgetConstant.height8,
                        AppTextField(
                          key: explorerFieldKey,
                          initialValue: explorerAddressLink,
                          onChanged: onChangeExplorerAddress,
                          validator: validateAddressLink,
                          label: "network_explorer_address_link".tr,
                          suffixIcon:
                              PasteTextIcon(onPaste: onPasteExplorerAddres),
                        ),
                        WidgetConstant.height20,
                        Text("network_explorer_transaction_link".tr,
                            style: context.textTheme.titleMedium),
                        Text("network_evm_explorer_transaction_desc".tr),
                        WidgetConstant.height8,
                        AppTextField(
                          key: transactionFieldKey,
                          initialValue: explorerAddressLink,
                          onChanged: onChangeExplorerTransaction,
                          validator: validateAddressLink,
                          label: "network_explorer_transaction_link".tr,
                          suffixIcon: PasteTextIcon(
                              onPaste: onPasteExplorerTransaction),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FixedElevatedButton(
                                padding: WidgetConstant.paddingVertical20,
                                onPressed: onAddChain,
                                child: Text("import".tr))
                          ],
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/bip/slip/slip44/slip44.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/http_authenticated.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/utils/ethereum/utils.dart';
import 'package:mrt_wallet/crypto/utils/utils.dart';

enum _Page { chainId, infos }

class ImportEthereumNetwork extends StatelessWidget {
  const ImportEthereumNetwork({super.key}) : web3 = null;
  final EthereumWeb3Form<Web3EthereumAddNewChain>? web3;
  const ImportEthereumNetwork.fromWeb3(
      EthereumWeb3Form<Web3EthereumAddNewChain> this.web3,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return _ImportEthereumNetwork(web3: web3);
  }
}

class _ImportEthereumNetwork extends StatefulWidget {
  const _ImportEthereumNetwork({this.web3});
  final EthereumWeb3Form<Web3EthereumAddNewChain>? web3;
  @override
  State<_ImportEthereumNetwork> createState() => __ImportEthereumNetworkState();
}

class __ImportEthereumNetworkState extends State<_ImportEthereumNetwork>
    with SafeState {
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  final GlobalKey<AppTextFieldState> explorerFieldKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<AppTextFieldState> transactionFieldKey = GlobalKey();
  final GlobalKey<HTTPServiceProviderFieldsState> rpcKey = GlobalKey();
  RPCURL? rpcUrl;
  List<BigInt> existsChainIds = [];
  String symbol = '';
  String networkName = '';
  BigInt chainId = BigInt.one;
  int coinType = Slip44.ethereum;
  String explorerAddressLink = "";
  String explorerTransaction = "";
  late final bool editableChainId = widget.web3 == null;
  late final bool isWeb3 = widget.web3 != null;

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

  // String? chainError;
  void onChangeChainId(int v) {
    chainId = BigInt.from(v);
  }

  void onChangeCoinType(int v) {
    coinType = v;
  }

  String? validateCoinType(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final parse = int.tryParse(v ?? "");
    if (parse == null ||
        parse < 0 ||
        parse > Bip32KeyDataConst.keyIndexMaxVal) {
      return "slip_44_desc".tr;
    }
    return null;
  }

  void changeChainId() {
    if (!editableChainId) return;
    page = _Page.chainId;
    updateState();
  }

  String? validateChainId(String? v) {
    final toInt = BigInt.tryParse(v ?? "");
    if (toInt == null) return "chain_id_validator".tr;
    if (existsChainIds.contains(chainId)) {
      return "network_chain_id_already_exist".tr;
    }
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
        StrUtils.validateUri(v, schame: ["http", "https", "ws", "wss"]);
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
    final link = StrUtils.validateUri(v);
    if (link == null) return "validate_link_desc".tr;
    return null;
  }

  List<EthereumAPIProvider> importedProviders = [];

  _Page page = _Page.infos;

  void confirmChainId() {
    if (formKey.currentState?.validate() ?? false) {
      page = _Page.infos;
      updateState();
    }
  }

  void onTapProvider(EthereumAPIProvider provider) async {
    rpcUrl = RPCURL(url: provider.callUrl, auth: provider.auth);
    updateState();
  }

  void _init() {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final evmNetworks =
        wallet.wallet.getChains().whereType<EthereumChain>().toList();
    existsChainIds = evmNetworks.map((e) => e.chainId).toList();
    final WalletEthereumNetwork network;
    if (widget.web3 == null) {
      network = WalletEthereumNetwork.create();
      page = _Page.chainId;
    } else {
      final param = widget.web3!.request.params;
      final web3Network = WalletEthereumNetwork(
          -1,
          EthereumNetworkParams(
              transactionExplorer: param.blockExplorerUrls?.first,
              addressExplorer: param.blockExplorerUrls?.first,
              token: Token(
                  name: param.name,
                  symbol: param.symbol,
                  decimal: ETHConst.decimals),
              providers: param.rpcUrls
                  .map((e) => EthereumAPIProvider(
                      uri: e, identifier: APIUtils.getProviderIdentifier()))
                  .toList(),
              chainId: param.newChainId,
              supportEIP1559: false,
              chainType: ChainType.mainnet));
      final networkExist = evmNetworks
          .firstWhereOrNull((e) => e.chainId == web3Network.coinParam.chainId);
      network = networkExist?.network ?? web3Network;
      if (networkExist != null) {
        pageProgressKey.errorText("network_chain_id_already_exist".tr,
            backToIdle: false, showBackButton: false);
        return;
      }
      symbol = network.coinParam.token.symbol;
      networkName = network.coinParam.token.name;
      chainId = network.coinParam.chainId;
      coinType = network.coinParam.bip32CoinType ?? Slip44.ethereum;
      explorerAddressLink = network.coinParam.addressExplorer ?? "";
      explorerTransaction = network.coinParam.transactionExplorer ?? "";
      importedProviders = network.coinParam.providers;
    }

    pageProgressKey.backToIdle();
    updateState();
  }

  void onAddChain() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    rpcUrl = rpcKey.currentState?.getEndpoint();
    if (rpcUrl == null) return;
    final provider = EthereumAPIProvider(
        uri: rpcUrl!.url,
        identifier: APIUtils.getProviderIdentifier(),
        auth: rpcUrl!.auth);
    pageProgressKey.progressText("checking_rpc_network_info".tr);
    final result = await MethodUtils.call(() async {
      final wallet = context.watch<WalletProvider>(StateConst.main);
      final chain = chainId;
      final client = APIUtils.buildEthereumProvider(provider: provider);
      final info = await client.getNetworkInfo();
      WalletEthereumNetwork updateNetwork = WalletEthereumNetwork(
          -1,
          EthereumNetworkParams(
              transactionExplorer: explorerTransaction.nullOnEmpty,
              addressExplorer: explorerAddressLink.nullOnEmpty,
              token: Token(
                  name: networkName,
                  symbol: symbol,
                  decimal: EthereumUtils.decimal),
              providers: importedProviders,
              chainId: chain,
              supportEIP1559: info.$2,
              defaultNetwork: false,
              chainType: ChainType.mainnet,
              bip32CoinType: coinType));
      return await wallet.wallet.updateImportNetwork(updateNetwork);
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      pageProgressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
      widget.web3?.onCompleteForm?.call(chainId.toRadix16);
    }
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() async => _init(), duration: APPConst.animationDuraion);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPageView(
      appBar: isWeb3 ? null : AppBar(title: Text("import_network".tr)),
      child: Form(
        key: formKey,
        child: UnfocusableChild(
          child: PageProgress(
            key: pageProgressKey,
            initialStatus: StreamWidgetStatus.progress,
            backToIdle: APPConst.oneSecoundDuration,
            child: (c) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: WidgetConstant.padding20,
                  sliver: SliverConstraintsBoxView(
                      sliver: SliverMainAxisGroup(slivers: [
                    SliverToBoxAdapter(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          PageTitleSubtitle(
                              title: "import_new_network".tr,
                              body: LargeTextView([
                                "import_new_network_desc1".tr,
                                "import_new_network_desc2".tr
                              ])),
                        ])),
                    APPSliverAnimatedSwitcher(enable: page, widgets: {
                      _Page.chainId: (c) => _SetupChainId(this),
                      _Page.infos: (c) => _ChainInfos(this)
                    }),
                  ])),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupChainId extends StatelessWidget {
  const _SetupChainId(this.state);
  final __ImportEthereumNetworkState state;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("chain_id".tr, style: context.textTheme.titleMedium),
          Text("chain_id_desc".tr),
          WidgetConstant.height8,
          NumberTextField(
              label: "chain_id".tr,
              defaultValue: state.chainId.toInt(),
              onChange: state.onChangeChainId,
              validator: state.validateChainId,
              showPasteIcon: true,
              max: null,
              min: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.confirmChainId,
                  child: Text("continue".tr)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChainInfos extends StatelessWidget {
  const _ChainInfos(this.state);
  final __ImportEthereumNetworkState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("chain_id".tr, style: context.textTheme.titleMedium),
          Text("chain_id_of_network".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemoveIcon:
                Icon(Icons.edit, color: context.colors.onPrimaryContainer),
            onRemove: !state.editableChainId
                ? null
                : () {
                    state.changeChainId();
                  },
            child: Text(
              state.chainId.toString(),
              style: context.colors.onPrimaryContainer.bodyMedium(context),
            ),
          ),
          WidgetConstant.height20,
          Text("network_name".tr, style: context.textTheme.titleMedium),
          Text("network_name_desc".tr),
          WidgetConstant.height8,
          AppTextField(
              initialValue: state.networkName,
              onChanged: state.onChangeNetworkName,
              validator: state.validateNetworkName,
              label: "network_name".tr),
          WidgetConstant.height20,
          Text("symbol".tr, style: context.textTheme.titleMedium),
          Text("symbol_desc".tr),
          WidgetConstant.height8,
          AppTextField(
              initialValue: state.symbol,
              onChanged: state.onChangeSymbol,
              validator: state.validateSymbol,
              label: "symbol".tr),
          WidgetConstant.height20,
          Text("coin_type".tr, style: context.textTheme.titleMedium),
          LargeTextView(["slip_44_desc".tr, "coin_type_desc2".tr], maxLine: 1),
          WidgetConstant.height8,
          NumberTextField(
              label: "coin_type".tr,
              defaultValue: state.coinType,
              onChange: state.onChangeCoinType,
              validator: state.validateCoinType,
              max: Bip32KeyDataConst.keyIndexMaxVal,
              min: 0),
          WidgetConstant.height20,
          Text("network_explorer_address_link".tr,
              style: context.textTheme.titleMedium),
          LargeTextView(["network_evm_explorer_address_desc".tr], maxLine: 1),
          WidgetConstant.height8,
          AppTextField(
            key: state.explorerFieldKey,
            initialValue: state.explorerAddressLink,
            onChanged: state.onChangeExplorerAddress,
            validator: state.validateAddressLink,
            label: "network_explorer_address_link".tr,
            pasteIcon: true,
          ),
          WidgetConstant.height20,
          Text("network_explorer_transaction_link".tr,
              style: context.textTheme.titleMedium),
          LargeTextView(["network_evm_explorer_transaction_desc".tr],
              maxLine: 1),
          WidgetConstant.height8,
          AppTextField(
            key: state.transactionFieldKey,
            initialValue: state.explorerAddressLink,
            onChanged: state.onChangeExplorerTransaction,
            validator: state.validateAddressLink,
            label: "network_explorer_transaction_link".tr,
            pasteIcon: true,
          ),
          ConditionalWidget(
              enable: state.importedProviders.isNotEmpty,
              onActive: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height20,
                        Text("providers".tr,
                            style: context.textTheme.titleMedium),
                        Text("select_provider_to_use".tr),
                        WidgetConstant.height8,
                        ...List.generate(state.importedProviders.length,
                            (index) {
                          final provider = state.importedProviders[index];
                          return ContainerWithBorder(
                              onRemove: () {
                                state.onTapProvider(provider);
                              },
                              onRemoveIcon: Icon(Icons.open_in_new,
                                  color: context.colors.onPrimaryContainer),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.protocol.value.tr,
                                      style: context
                                          .onPrimaryTextTheme.labelLarge),
                                  Text(provider.callUrl,
                                      style:
                                          context.onPrimaryTextTheme.bodyMedium,
                                      maxLines: 2),
                                ],
                              ));
                        }),
                      ])),
          WidgetConstant.height20,
          Text("providers".tr, style: context.textTheme.titleMedium),
          LargeTextView(["network_title_http_wss_url".tr], maxLine: 2),
          WidgetConstant.height8,
          HTTPServiceProviderFields(
              key: state.rpcKey,
              protocols: [ServiceProtocol.http, ServiceProtocol.websocket],
              initialUrl: state.rpcUrl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.onAddChain,
                  child: Text("import".tr))
            ],
          )
        ],
      ),
    );
  }
}

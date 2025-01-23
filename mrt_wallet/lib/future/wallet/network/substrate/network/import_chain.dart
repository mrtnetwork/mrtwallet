import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class SubstrateImportChainView extends StatelessWidget {
  const SubstrateImportChainView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      appbar: AppBar(title: Text("import_network".tr)),
      accsess: WalletAccsessType.unlock,
      onAccsess: (wallet, chain, onAccountChanged) {
        return _ImportSubstrateNetwork();
      },
    );
  }
}

mixin AddSubstrateChainState<T extends StatefulWidget> on SafeState<T> {
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "form key!");
  final GlobalKey<HTTPServiceProviderFieldsState> rpcKey = GlobalKey();
  SubstrateNetworkParams? network;
  SubstrateChainMetadata? metadata;
  RPCURL? uri;

  bool isWalletNetwork = false;
  bool isDefaultNetwork = false;
  int decimal = 10;
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

  void onChangeDecimals(int v) {
    decimal = v;
  }

  String? validateDecimals(String? v) {
    final parse = int.tryParse(v ?? "");
    if (parse == null || parse < 0 || parse > APPSubstrateConst.maxDecimals) {
      return "token_decimal_maxn_validator"
          .tr
          .replaceOne(APPSubstrateConst.maxDecimals.toString());
    }
    return null;
  }

  String? validateChainId(String? v) {
    final toInt = BigInt.tryParse(v ?? "");
    if (toInt == null) return "chain_id_validator".tr;
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

  // late WalletProvider wallet;
  bool get showRemoveIcon => isWalletNetwork && !isDefaultNetwork;

  void removeChain(bool? remove) async {}

  Future<void> checkNetwork() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    uri = rpcKey.currentState?.getEndpoint();
    if (uri == null) return;
    pageProgressKey.progressText("checking_rpc_network_info".tr);
    final provider = SubstrateAPIProvider(
        uri: uri!.url,
        identifier: APIUtils.getProviderIdentifier(),
        auth: uri!.auth);
    final client = APIUtils.buildsubstrateClient(provider: provider);
    final init = await MethodUtils.call(() async => client.loadApi());
    if (init.hasError) {
      pageProgressKey.errorText(init.error!.tr,
          backToIdle: false, showBackButton: true);
    } else if (init.result == null) {
      pageProgressKey.errorText("unsuported_network_metadata".tr);
    } else {
      final chainInfo = init.result!;
      metadata = chainInfo;
      network = SubstrateNetworkParams(
          token: Token(name: networkName, symbol: symbol, decimal: decimal),
          providers: [provider],
          chainType: ChainType.mainnet,
          ss58Format: chainInfo.ss58Prefix,
          substrateChainType: chainInfo.type,
          addressExplorer: explorerAddressLink.nullOnEmpty,
          transactionExplorer: explorerTransaction.nullOnEmpty,
          gnesisBlock: chainInfo.genesis,
          keyAlgorithms: chainInfo.supportedAlgorithms,
          specVersion: chainInfo.specVersion);
      pageProgressKey.backToIdle();
    }
  }

  Future<void> addOrUpdateChain() async {
    final params = this.network;
    if (params == null) return;
    pageProgressKey.progressText("add_or_updating_wallet_network".tr);
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final network = WalletSubstrateNetwork(-1, params);
    final import = await MethodUtils.call(
        () async => wallet.wallet.updateImportNetwork(network));
    if (import.hasError) {
      pageProgressKey.errorText(import.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      pageProgressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
    }
  }

  bool get canPop => network == null;

  void onBackButton(bool _, Object? __) {
    if (!canPop) {
      network = null;
      metadata = null;
      updateState();
    }
  }
}

class _ImportSubstrateNetwork extends StatefulWidget {
  const _ImportSubstrateNetwork();
  @override
  State<_ImportSubstrateNetwork> createState() =>
      __ImportSubstrateNetworkState();
}

class __ImportSubstrateNetworkState extends State<_ImportSubstrateNetwork>
    with
        SafeState<_ImportSubstrateNetwork>,
        AddSubstrateChainState<_ImportSubstrateNetwork> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      canPop: canPop,
      onPopInvokedWithResult: onBackButton,
      child: UnfocusableChild(
        child: PageProgress(
          key: pageProgressKey,
          backToIdle: APPConst.oneSecoundDuration,
          child: (c) => CustomScrollView(
            slivers: [
              SliverConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  sliver: APPSliverAnimatedSwitcher(
                      enable: network != null,
                      widgets: {
                        false: (context) =>
                            SubstrateAddChainFieldsView(state: this),
                        true: (context) => SubstrateAddChainInfoView(
                            onAddChain: addOrUpdateChain,
                            network: network!,
                            metadata: metadata!)
                      }))
            ],
          ),
        ),
      ),
    );
  }
}

class SubstrateAddChainFieldsView extends StatelessWidget {
  const SubstrateAddChainFieldsView({required this.state, super.key});
  final AddSubstrateChainState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "import_new_network".tr,
              body: LargeTextView([
                "import_new_network_desc1".tr,
                "import_new_network_desc2".tr
              ])),
          Text("network_name".tr, style: context.textTheme.titleMedium),
          Text("network_name_desc".tr),
          WidgetConstant.height8,
          AppTextField(
            initialValue: state.networkName,
            onChanged: state.onChangeNetworkName,
            validator: state.validateNetworkName,
            label: "network_name".tr,
          ),
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
          Text("decimals".tr, style: context.textTheme.titleMedium),
          Text("solana_mint_decimal_desc".tr),
          ErrorTextContainer(
              error: "change_token_decimal_desc3".tr,
              enableTap: false,
              showErrorIcon: false),
          WidgetConstant.height8,
          NumberTextField(
              label: "decimals".tr,
              defaultValue: state.decimal,
              onChange: state.onChangeDecimals,
              validator: state.validateDecimals,
              max: APPSubstrateConst.maxDecimals,
              min: 0),
          WidgetConstant.height20,
          Text("network_explorer_address_link".tr,
              style: context.textTheme.titleMedium),
          LargeTextView(["network_evm_explorer_address_desc".tr], maxLine: 1),
          WidgetConstant.height8,
          AppTextField(
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
            initialValue: state.explorerAddressLink,
            onChanged: state.onChangeExplorerTransaction,
            validator: state.validateAddressLink,
            label: "network_explorer_transaction_link".tr,
            pasteIcon: true,
          ),
          WidgetConstant.height20,
          Text("providers".tr, style: context.textTheme.titleMedium),
          LargeTextView(
            ["network_title_http_wss_url".tr],
            maxLine: 2,
          ),
          WidgetConstant.height8,
          HTTPServiceProviderFields(
              key: state.rpcKey,
              protocols: [ServiceProtocol.http, ServiceProtocol.websocket],
              initialUrl: state.uri),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.checkNetwork,
                  child: Text("continue".tr))
            ],
          )
        ],
      ),
    );
  }
}

class SubstrateAddChainInfoView extends StatelessWidget {
  const SubstrateAddChainInfoView(
      {super.key,
      required this.network,
      this.metadata,
      required this.onAddChain,
      this.buttonText});
  final SubstrateNetworkParams network;
  final SubstrateChainMetadata? metadata;
  final DynamicVoid onAddChain;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    final keyAlgorithms = network.keyAlgorithms.map((e) => e.name).join(", ");
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metadata != null) ...[
            ErrorTextContainer(
                error: "import_network_experimental_feature_desc".tr),
            WidgetConstant.height20,
          ],
          Text("network_name".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Text(network.token.name,
                style: context.onPrimaryTextTheme.bodyMedium),
          ),
          WidgetConstant.height20,
          Text("symbol".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(network.token.symbol,
                  style: context.onPrimaryTextTheme.bodyMedium)),
          WidgetConstant.height20,
          Text("decimals".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(network.token.decimal.toString(),
                  style: context.onPrimaryTextTheme.bodyMedium)),
          WidgetConstant.height20,
          Text("spec_version".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(network.specVersion.toString(),
                  style: context.onPrimaryTextTheme.bodyMedium)),
          if (!network.substrateChainType.isEthereum) ...[
            WidgetConstant.height20,
            Text("key_algorithms".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            ContainerWithBorder(
                child: Text(keyAlgorithms,
                    style: context.onPrimaryTextTheme.bodyMedium)),
          ],
          WidgetConstant.height20,
          Text("ss58_prefix".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(network.ss58Format.toString(),
                  style: context.onPrimaryTextTheme.bodyMedium)),
          if (metadata != null) ...[
            if (!metadata!.supportNativeTransfer) ...[
              WidgetConstant.height20,
              ErrorTextContainer(
                  error: "substrate_disable_transfer_option_desc".tr),
            ],
            if (!metadata!.supportAccountTemplate) ...[
              WidgetConstant.height20,
              ErrorTextContainer(
                  error: "substrate_unsuported_account_template_desc".tr),
            ],
          ],
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: onAddChain,
                child: Text(buttonText ?? "import_network".tr))
          ]),
        ],
      ),
    );
  }
}

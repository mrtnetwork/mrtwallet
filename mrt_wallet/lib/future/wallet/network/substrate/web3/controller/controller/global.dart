import 'package:blockchain_utils/bip/bip/conf/core/coin_conf.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/auth.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/network/params/substrate.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/models/metadata.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateGlobalRequestController<RESPONSE,
        T extends Web3SubstrateRequestParam<RESPONSE>>
    extends Web3SubstrateImpl<RESPONSE, T> {
  @override
  bool get clientRequired =>
      request.params.method == Web3SubstrateRequestMethods.knownMetadata;
  Web3SubstrateGlobalRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);
  void onChangeForm() {
    notify();
  }

  SubstrateNetworkParams? _network;
  SubstrateChainMetadata? _metadata;
  SubstrateNetworkParams? get newNetwork => _network;
  SubstrateChainMetadata? get newMetadata => _metadata;

  Future<void> checkNetwork({
    required String networkName,
    required String symbol,
    required int decimal,
    required RPCURL uri,
    String? explorerAddressLink,
    String? explorerTransaction,
  }) async {
    progressKey.process(text: "checking_rpc_network_info".tr);
    final provider = SubstrateAPIProvider(
        uri: uri.url,
        identifier: APIUtils.getProviderIdentifier(),
        auth: uri.auth);
    final client = APIUtils.buildsubstrateClient(provider: provider);
    final init = await MethodUtils.call(() async => client.loadApi());
    if (init.hasError) {
      progressKey.error(text: init.error!.tr);
    } else if (init.result == null) {
      progressKey.error(text: "unsuported_network_metadata".tr);
    } else {
      final chainInfo = init.result!;
      _metadata = chainInfo;
      _network = SubstrateNetworkParams(
          token: Token(name: networkName, symbol: symbol, decimal: decimal),
          providers: [provider],
          chainType: ChainType.mainnet,
          ss58Format: chainInfo.ss58Prefix,
          substrateChainType: chainInfo.type,
          addressExplorer: explorerAddressLink,
          transactionExplorer: explorerTransaction,
          gnesisBlock: chainInfo.genesis,
          keyAlgorithms: chainInfo.supportedAlgorithms,
          specVersion: chainInfo.specVersion);
      progressKey.idle();
    }
  }

  Future<void> updateNetworkMetadata() async {
    progressKey.process(text: "add_or_updating_wallet_network".tr);
    final params = request.params.cast<Web3SubstrateAddNewChain>();
    final chain = walletProvider.wallet
        .getChains<SubstrateChain>()
        .firstWhereOrNull((e) => e.network.genesisBlock == params.genesisHash);
    if (chain == null) return;
    final r = await MethodUtils.call(() async {
      final client = chain.clientNullable;
      if (client == null) {
        throw WalletException("node_connection_error");
      }
      final init = await client.onInit();
      if (init != true) {
        throw WalletException("network_genesis_hash_validator");
      }
      if (chain.network.genesisBlock != params.genesisHash) {
        throw Web3SubstrateExceptionConstant.differentRuntimeMetadata;
      }
      SubstrateNetworkParams updateParams = chain.network.coinParam;
      if (updateParams.specVersion == client.metadata.specVersion) {
        return;
      }
      updateParams =
          updateParams.updateSpecVersion(client.metadata.specVersion);
      final updateNetwork = chain.network.copyWith(coinParam: updateParams);
      await walletProvider.wallet.updateImportNetwork(updateNetwork);
    });
    if (r.hasError) {
      if (r.errorISA<Web3RequestException>()) {
        progressKey.error(text: r.error!.tr, backToIdle: null);
        request.error(Web3RequestExceptionConst.fromException(r.exception!));
        return;
      }
      progressKey.error(text: r.error!.tr);
    } else {
      request.completeResponse(true);
      progressKey.response(text: 'request_completed_success'.tr);
    }
  }

  Future<void> importNewChain() async {
    final params = _network;
    if (params == null) return;
    progressKey.process(text: "add_or_updating_wallet_network".tr);
    final network = WalletSubstrateNetwork(-1, params);
    final r = await MethodUtils.call(() async {
      final provider = network.getProvider<SubstrateAPIProvider>();
      if (provider == null) {
        throw WalletException("no_acitve_provider");
      }
      final client =
          APIUtils.buildsubstrateClient(provider: provider, network: network);
      final init = await client.onInit();
      if (!init) {
        throw WalletException("network_genesis_hash_validator");
      }
      final params = request.params as Web3SubstrateAddNewChain;
      if (client.genesisBlock != params.genesisHash ||
          params.specVersion != client.metadata.specVersion) {
        throw Web3SubstrateExceptionConstant.differentRuntimeMetadata;
      }
      await walletProvider.wallet.updateImportNetwork(network);
    });
    if (r.hasError) {
      if (r.errorISA<Web3RequestException>()) {
        progressKey.error(text: r.error!.tr, backToIdle: null);
        request.error(Web3RequestExceptionConst.fromException(r.exception!));
        return;
      }
      progressKey.error(text: r.error!.tr);
    } else {
      request.completeResponse(true);
      progressKey.response(text: 'request_completed_success'.tr);
    }
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3SubstrateRequestMethods.requestAccounts:
        final web3Chain = result as Web3SubstrateChain;
        request.authenticated.updateChainAccount(web3Chain);
        break;
      case Web3SubstrateRequestMethods.signMessage:
        if (obj != true) {
          progressKey.idle();
          return;
        }
        final signingParams = request.params as Web3SubstrateSignMessage;
        final signMessage = await MethodUtils.call(() async {
          final signature = await walletProvider.wallet.signTransaction(
              request: WalletSigningRequest(
            addresses: [address],
            network: network,
            sign: (generateSignature) async {
              final signRequest = GlobalSignRequest.substrate(
                  digest: signingParams.chalengBytes(),
                  index: address.keyIndex.cast());
              final response = await generateSignature(signRequest);
              return Web3SubstrateSendTransactionResponse(
                      signature: response.signature)
                  .toJson();
            },
          ));
          return signature.result;
        });
        if (signMessage.hasError) {
          progressKey.error(text: signMessage.error!.tr);
          return;
        }
        result = signMessage.result;
        break;
      default:
        break;
    }
    request.completeResponse(result);
    progressKey.response(text: "request_completed_success".tr);
  }

  @override
  Future<void> initWeb3() async {
    await MethodUtils.after(() async {
      liveRequest.addListener(onChangeForm);
      form.onCompleteForm = onCompleteForm;
      progressKey.idle();
    });
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(onChangeForm);
    form.onCompleteForm = null;
  }
}

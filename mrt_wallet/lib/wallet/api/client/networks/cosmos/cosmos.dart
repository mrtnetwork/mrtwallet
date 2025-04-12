import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/api/services/networks/networks.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

mixin CosmosCustomRequest on HttpImpl {
  static final _lock = SynchronizedLock();

  static final Map<ChainType, List<CCRChainData>> _chains = {
    ChainType.mainnet: [],
    ChainType.testnet: [],
  };
  static List<PingPubChain>? _testnetChains;
  static List<PingPubChain>? _mainnetChains;

  static List<CosmosDirectoryChain>? _testnetCosmosDirectoryChains;
  static List<CosmosDirectoryChain>? _mainnetCosmosDirectoryChains;

  static CCRChainData? _getLocalChain(
      {required ChainType chainType, required String name}) {
    return _chains[chainType]
        ?.firstWhereOrNull((e) => e.chain.chainName == name);
  }

  Future<List<PingPubChain>> _getChains(String uri,
      {Duration timeout = const Duration(seconds: 60)}) async {
    final r = await httpGet<List<Map<String, dynamic>>>(uri,
        responseType: HTTPResponseType.listOfMap, timeout: timeout);
    return CCRUtilities.readChainDirectories(r.result);
  }

  Future<List<CosmosDirectoryChain>> _getCosmsmosChains(String uri,
      {Duration timeout = const Duration(seconds: 60)}) async {
    final r = await httpGet<Map<String, dynamic>>(uri,
        responseType: HTTPResponseType.map, timeout: timeout);
    final chains = (r.result["chains"] as List)
        .map((e) => CosmosDirectoryChain.fromJson(e))
        .toList();
    return chains;
  }

  Future<List<CosmosDirectoryChain>> _getCosmosDirectoryChains(
      {ChainType chain = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    switch (chain) {
      case ChainType.mainnet:
        return _mainnetCosmosDirectoryChains ??= await _getCosmsmosChains(
            CCRConst.cosmosDirectoryUri,
            timeout: timeout);
      case ChainType.testnet:
        return _testnetCosmosDirectoryChains ??= await _getCosmsmosChains(
            CCRConst.cosmosTestnetDirectoryUri,
            timeout: timeout);
    }
  }

  Future<CosmosDirectoryChain?> _getCosmosDirectoryChain(
      {required String? chainId,
      ChainType chain = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    try {
      final data =
          await _getCosmosDirectoryChains(chain: chain, timeout: timeout);
      return data.firstWhereNullable((e) => e.chainId == chainId);
    } catch (_) {
      return null;
    }
  }

  Future<List<PingPubChain>> getCosmosChains(
      {ChainType chain = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    final baseUrl = _getChainUrl(chain);
    return _lock.synchronized(() async {
      switch (chain) {
        case ChainType.mainnet:
          return _mainnetChains ??= await _getChains(baseUrl);
        case ChainType.testnet:
          return _testnetChains ??= await _getChains(baseUrl);
      }
    });
  }

  String _getChainUrl(ChainType chain) {
    if (chain.isMainnet) {
      return CCRConst.chainRegisteryUri;
    }
    return CCRConst.chainRegisteryUriTestnets;
  }

  Future<(CCRChainData, CosmosDirectoryChain?)> getChainData(String chainName,
      {ChainType chainType = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    return _lock.synchronized(() async {
      final localChain = _getLocalChain(chainType: chainType, name: chainName);
      if (localChain != null) {
        final cosmosDirectoryChain =
            await _getCosmosDirectoryChain(chainId: localChain.chain.chainId);
        return (localChain, cosmosDirectoryChain);
      }
      final baseUrl = _getChainUrl(chainType);
      Uri uri = CCRUtilities.getChainUri(
          baseUrl: baseUrl, chain: chainName, schema: CCRSchemaType.chain);
      MethodResult<Map<String, dynamic>> r =
          await httpGet<Map<String, dynamic>>(uri.toString(),
              responseType: HTTPResponseType.map, timeout: timeout);
      final chain = CCRChain.fromJson(r.result);
      uri = CCRUtilities.getChainUri(
          baseUrl: baseUrl, chain: chainName, schema: CCRSchemaType.assetlist);
      r = await httpGet<Map<String, dynamic>>(uri.toString(),
          responseType: HTTPResponseType.map, timeout: timeout);
      final asset = CCRAssetList.fromJson(r.result);
      final chainData = CCRChainData(chain: chain, assetList: asset);
      _chains[chainType]?.add(chainData);
      final cosmosDirectoryChain =
          await _getCosmosDirectoryChain(chainId: chainData.chain.chainId);
      return (chainData, cosmosDirectoryChain);
    });
  }

  Future<CosmosNetworkParams> buildNetwork(
      {required CosmosAPIProvider provider,
      required CosmosNetworkParams param}) async {
    final service = CosmosClient(
        provider: TendermintProvider(TendermintHTTPService(
            provider: provider, isolate: APPIsolate.separate)),
        network: WalletCosmosNetwork(-1, param));
    String hrp = param.hrp;
    final bech32 = await MethodUtils.call(() => service.networkBech32());
    if (bech32.hasError) {
      if (hrp.isEmpty) {
        throw WalletException("unable_to_retrieve_hrp");
      }
    } else {
      if (hrp.isNotEmpty && hrp != bech32.result) {
        throw WalletException("different_network_hrp");
      }
      hrp = bech32.result;
    }
    final nativeToken = await MethodUtils.call(() => service.provider.request(
        TendermintRequestAbciQuery(
            request: QueryDenomMetadataRequest(denom: param.denom))));
    if (!nativeToken.hasResult) {
      await service.totalSupply(param.denom);
    }
    await service.totalSupply(param.denom);
    for (final i in param.feeTokens) {
      if (i.denom == param.denom) continue;
      await service.totalSupply(i.denom);
    }
    final chainId = await service.chainId();
    CosmosNetworkTypes networkTypes = param.networkType;
    final isEthermint = await service.isEthermint();
    if (isEthermint) {
      networkTypes = CosmosNetworkTypes.ethermint;
    }
    param = param.copyWith(
        chainId: chainId,
        hrp: hrp,
        providers: [provider],
        networkType: networkTypes);
    return param;
  }

  Future<CCRAsset?> findAsset(
      {required String denom,
      required String? chainName,
      ChainType chainType = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    if (chainName == null) return null;
    final chain = await MethodUtils.call(
        () => getChainData(chainName, timeout: timeout, chainType: chainType));
    assert(!chain.hasError, "fetching asset failed. Error: ${chain.error}");
    if (chain.hasResult) {
      return chain.result.$1.assetList.assets
          .firstWhereOrNull((e) => e.base == denom);
    }
    return null;
  }
}

class CosmosClient extends NetworkClient<ICosmosAddress, CosmosAPIProvider>
    with HttpImpl, CosmosCustomRequest {
  CosmosClient({required this.provider, required this.network});
  final TendermintProvider provider;
  @override
  final WalletCosmosNetwork network;
  @override
  TendermintHTTPService get service => provider.rpc as TendermintHTTPService;

  Future<List<Coin>> getAccountCoins(ICosmosAddress address) async {
    final request =
        QuerySpendableBalancesRequest(address: address.networkAddress);
    final result =
        await provider.request(TendermintRequestAbciQuery(request: request));
    return result.balances;
  }

  Future<List<Coin>> updateAndGetAccountBalances(
      ICosmosAddress account, APPCHAINACCOUNT<ICosmosAddress> chain) async {
    final balances = await getAccountCoins(account);
    await updateBalance(account, chain, balances: balances);
    return balances;
  }

  Future<IbcChannelChannel?> getTransferChannel(String channelName) async {
    try {
      final channel = await provider.request(TendermintRequestAbciQuery(
          request: QueryChannelRequest(
              portId: CosmosConst.transferIbcPort, channelId: channelName)));

      return channel.channel;
    } on RPCError catch (e) {
      if (e.errorCode == CosmosConst.accountNotFoundErrorCode) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> updateAccountTokenBalances({
    required ICosmosAddress address,
    required APPCHAINACCOUNT<ICosmosAddress> chain,
    required List<CW20Token> tokens,
  }) async {
    final balances = await getAccountCoins(address);
    final nativeToken =
        balances.firstWhere((e) => e.denom == network.coinParam.denom);
    chain.updateAddressBalance(
        address: address, updateBalance: nativeToken.amount);
    for (final i in address.tokens) {
      final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
      i.updateBalance(balance?.amount ?? BigInt.zero);
    }
    for (final i in tokens) {
      final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
      i.updateBalance(balance?.amount ?? BigInt.zero);
    }
  }

  @override
  Future<void> updateBalance(
      ICosmosAddress address, APPCHAINACCOUNT<ICosmosAddress> chain,
      {List<Coin>? balances}) async {
    balances ??= await getAccountCoins(address);
    final nativeToken =
        balances.firstWhereOrNull((e) => e.denom == network.coinParam.denom);
    chain.updateAddressBalance(
        address: address, updateBalance: nativeToken?.amount ?? BigInt.zero);
    for (final i in address.tokens) {
      final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
      i.updateBalance(balance?.amount ?? BigInt.zero);
    }
  }

  Future<CW20Token> getTokenMetadata(String denom) async {
    final request = QueryDenomMetadataRequest(denom: denom);
    final result =
        await provider.request(TendermintRequestAbciQuery(request: request));
    final denomUnit = result.metadata.denomUnits
        .firstWhere((e) => e.denom == result.metadata.display);
    return CW20Token.create(
      balance: BigInt.zero,
      token: Token(
          name: CosmosConst.extractFactoryTokenName(result.metadata.name ??
              result.metadata.symbol ??
              denomUnit.denom),
          symbol: CosmosConst.extractFactoryTokenName(
              result.metadata.symbol ?? denomUnit.denom),
          decimal: denomUnit.exponent ?? 0),
      denom: denom,
    );
  }

  Future<List<CosmosChainAsset>> getAddressTokens(
      ICosmosAddress address) async {
    List<Coin> balances = await getAccountCoins(address);
    balances =
        balances.where((e) => e.denom != network.coinParam.denom).toList();
    final List<CosmosChainAsset> tokens = [];

    for (final i in balances) {
      final exists = address.tokens.any((e) => e.denom == i.denom);
      if (exists) continue;
      final token =
          await MethodUtils.call(() async => await getTokenMetadata(i.denom));
      if (token.hasResult) {
        token.result.updateBalance(i.amount);
        tokens.add(CosmosChainAsset.cw20Token(token.result));
      } else {
        final asset = await findAsset(
            denom: i.denom,
            chainName: network.coinParam.chainRegisteryName,
            chainType: network.coinParam.chainType);
        if (asset != null) {
          tokens.add(CosmosChainAsset.ccrAsset(
              asset: asset, coin: i, balance: i.amount));
        } else {
          tokens.add(CosmosChainAsset.unknown(coin: i, balance: i.amount));
        }
      }
    }
    return tokens;
  }

  Future<String> networkBech32() async {
    final request = Bech32PrefixRequest();
    final r =
        await provider.request(TendermintRequestAbciQuery(request: request));
    return r.bech32Prefix;
  }

  Future<BigInt> totalSupply(String denom) async {
    final r = await provider.request(TendermintRequestAbciQuery(
        request: QuerySupplyOfRequest(denom: denom)));
    return r.amount.amount;
  }

  Future<bool> isEthermint() async {
    try {
      await provider.request(TendermintRequestAbciQuery(
          request: EvmosEthermintEVMV1QueryParamsRequest()));
      return true;
    } on RPCError catch (e) {
      if (e.errorCode == CosmosConst.pathNotFoundErrorCode) return false;
      rethrow;
    }
  }

  Future<BaseAccount?> getBaseAccount(CosmosBaseAddress address) async {
    try {
      final request = QueryAccountRequest(address);
      final result =
          await provider.request(TendermintRequestAbciQuery(request: request));
      return result.account.baseAccount;
    } on RPCError catch (e) {
      if (e.errorCode == CosmosConst.accountNotFoundErrorCode) {
        return null;
      }
      rethrow;
    }
  }
  // Future<bool>

  Future<GetLatestBlockResponse> getLatestBlock() async {
    return await provider.request(
        TendermintRequestAbciQuery(request: const GetLatestBlockRequest()));
  }

  Future<CosmosWeb3SimulateInfos> simulateTransaction(List<int> txBytes,
      {List<CosmosMessage> txMessages = const []}) async {
    final r = await provider
        .request(TendermintRequestAbciQuery(request: SimulateRequest(txBytes)));
    return CosmosWeb3SimulateInfos(simulate: r, txMessages: txMessages);
  }

  Future<BigRational> getEthermintBaseFee() async {
    final chainStatus = await provider.request(TendermintRequestAbciQuery(
        request: EvmosEthermintEVMV1QueryBaseFeeRequest()));
    return BigRational(BigintUtils.parse(chainStatus.baseFee));
  }

  Future<String> broadcastTransaction(List<int> txRaw) async {
    final result = await provider.request(TendermintRequestBroadcastTxCommit(
        BytesUtils.toHexString(txRaw, prefix: "0x")));
    if (!result.isSuccess) {
      throw RPCError(
        message: result.error ?? "",
        errorCode: result.errorCode,
        details: result.error == null ? result.toJson() : null,
      );
    }
    return result.hash;
  }

  Future<CosmosTransactionRequirment> getTransactionRequirment(
      {required ICosmosAddress address, required CosmosChain account}) async {
    List<Coin> balances = [];
    final cosmosAccount = await getBaseAccount(address.networkAddress);
    BigInt? fixedFee;
    if (network.coinParam.networkType == CosmosNetworkTypes.thorAndForked) {
      final fee = await MethodUtils.call(() async {
        final networkConst = await getThorNodeConstants();
        return BigInt.from(networkConst.nativeTransactionFee);
      });
      assert(fee.hasResult,
          "failed to fetch ${network.networkName} native trasaction fee: ${fee.error}");
      if (fee.hasResult) {
        fixedFee = fee.result;
      } else {
        fixedFee = network.coinParam.getFeeToken().averageGasPrice.balance;
      }
    }
    BigRational? ethermintTxFee;
    if (network.coinParam.networkType.isEthermint) {
      final fee = await MethodUtils.call(() {
        return getEthermintBaseFee();
      });
      assert(fee.hasResult,
          "failed to fetch ${network.networkName} base gas fee: ${fee.error}");
      if (fee.hasResult) {
        ethermintTxFee = fee.result;
      } else {
        ethermintTxFee = BigRational.parseDecimal(
            network.coinParam.getFeeToken().averageGasPrice.price);
      }
    }
    if (cosmosAccount != null) {
      balances = await updateAndGetAccountBalances(address, account);
    }
    final List<CW20Token> feeTokens =
        List.generate(network.coinParam.feeTokens.length, (i) {
      final token = network.coinParam.feeTokens[i];
      return address.tokens.firstWhere(
        (e) => e.denom == token.denom,
        orElse: () => CW20Token.create(
            balance: balances
                    .firstWhereNullable((e) => e.denom == token.denom)
                    ?.amount ??
                BigInt.zero,
            token: token.token,
            denom: token.denom),
      );
    });
    return CosmosTransactionRequirment(
        account: cosmosAccount,
        feeTokens: feeTokens,
        fixedNativeGas: fixedFee,
        ethermintTxFee: ethermintTxFee);
  }

  Future<ThorNodeNetworkConstants> getThorNodeConstants() async {
    if (network.coinParam.networkConstantUri == null) {
      throw WalletException("invalid_url");
    }
    final constantsJson = await httpGet<Map<String, dynamic>>(
        network.coinParam.networkConstantUri!,
        responseType: HTTPResponseType.map);
    final constants = ThorNodeNetworkConstants.fromJson(
        constantsJson.result["int_64_values"]);
    return constants;
  }

  Future<String> chainId() async {
    final chainStatus = await provider.request(TendermintRequestStatus());
    return chainStatus["node_info"]["network"];
  }

  Future<bool> validateNetworkChainId() async {
    final chainId = await this.chainId();
    return chainId == network.coinParam.chainId;
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() {
      return validateNetworkChainId();
    });
    return result.hasResult && result.result;
  }

  @override
  NetworkType get networkType => NetworkType.cosmos;
}

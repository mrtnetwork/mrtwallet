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
  static List<RegisteryPingPubItem>? _testnetChains;
  static List<RegisteryPingPubItem>? _mainnetChains;
  Future<List<RegisteryPingPubItem>> _getChains(String uri,
      {Duration timeout = const Duration(seconds: 60)}) async {
    final r = await httpGet<List<Map<String, dynamic>>>(uri,
        responseType: HTTPResponseType.listOfMap, timeout: timeout);
    return CCRUtilities.readChainDirectories(r.result);
  }

  Future<List<RegisteryPingPubItem>> getCosmosChains(
      {ChainType chain = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    final baseUrl = _getChainUrl(chain);
    switch (chain) {
      case ChainType.mainnet:
        return _mainnetChains ??= await _getChains(baseUrl);
      case ChainType.testnet:
        return _testnetChains ??= await _getChains(baseUrl);
    }
  }

  String _getChainUrl(ChainType chain) {
    if (chain.isMainnet) {
      return CCRConst.chainRegisteryUri;
    }
    return CCRConst.chainRegisteryUriTestnets;
  }

  Future<CCRChainData> getChainData(RegisteryPingPubItem chainName,
      {ChainType chainType = ChainType.mainnet,
      Duration timeout = const Duration(seconds: 60)}) async {
    final baseUrl = _getChainUrl(chainType);
    Uri uri = CCRUtilities.getChainUri(
        baseUrl: baseUrl, chain: chainName.name, schema: CCRSchemaType.chain);
    MethodResult<Map<String, dynamic>> r = await httpGet<Map<String, dynamic>>(
        uri.toString(),
        responseType: HTTPResponseType.map,
        timeout: timeout);
    final chain = CCRChain.fromJson(r.result);
    uri = CCRUtilities.getChainUri(
        baseUrl: baseUrl,
        chain: chainName.name,
        schema: CCRSchemaType.assetlist);
    r = await httpGet<Map<String, dynamic>>(uri.toString(),
        responseType: HTTPResponseType.map, timeout: timeout);
    final asset = CCRAssetList.fromJson(r.result);
    return CCRChainData(chain: chain, assetList: asset);
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
    await MethodUtils.call(() => service.provider.requestDynamic(
        TendermintRequestAbciQuery(
            request: QueryDenomMetadataRequest(denom: param.denom))));

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
    return param.copyWith(
        chainId: chainId,
        hrp: hrp,
        providers: [provider],
        networkType: networkTypes);
  }
}

class CosmosClient extends NetworkClient<ICosmosAddress, CosmosAPIProvider>
    with HttpImpl {
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

  @override
  Future<void> updateBalance(
      ICosmosAddress address, APPCHAINACCOUNT<ICosmosAddress> chain,
      {List<Coin>? balances}) async {
    balances ??= await getAccountCoins(address);
    final nativeToken =
        balances.firstWhere((e) => e.denom == network.coinParam.denom);
    chain.updateAddressBalance(
        address: address, updateBalance: nativeToken.amount);
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
    // CosmosUtils.accountNotFoundErrorCode
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

  Future<List<CW20Token>> getAddressTokens(ICosmosAddress address) async {
    List<Coin> balances = await getAccountCoins(address);
    balances =
        balances.where((e) => e.denom != network.coinParam.denom).toList();
    final List<CW20Token> tokens = [];

    for (final i in balances) {
      final exists = address.tokens.any((e) => e.denom == i.denom);
      if (exists) continue;
      final token =
          await MethodUtils.call(() async => await getTokenMetadata(i.denom));
      assert(!token.hasError, "should not be failed.");
      if (token.hasResult) {
        token.result.updateBalance(i.amount);
        tokens.add(token.result);
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
      await provider.request(
          TendermintRequestAbciQuery(request: EVMV1QueryParamsRequest()));
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

  Future<SimulateResponse> simulateTransaction(List<int> txBytes) async {
    return await provider
        .request(TendermintRequestAbciQuery(request: SimulateRequest(txBytes)));
  }

  Future<BigRational> getEthermintBaseFee() async {
    final chainStatus = await provider.request(
        TendermintRequestAbciQuery(request: FeeMarketV1QueryBaseFeeRequest()));
    return BigRational(chainStatus.baseFee);
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

  Future<CosmosTransactionRequirment> getTransactionRequirment({
    required ICosmosAddress address,
    required CosmosChain account,
  }) async {
    final cosmosAccount = await getBaseAccount(address.networkAddress);
    if (cosmosAccount == null) {
      return CosmosTransactionRequirment.accountNotFound();
    }
    BigInt? fixedFee;
    if (network.coinParam.networkType == CosmosNetworkTypes.thorAndForked) {
      final networkConst = await getThorNodeConstants();
      fixedFee = BigInt.from(networkConst.nativeTransactionFee);
    }
    final block = await getLatestBlock();
    final balances = await updateAndGetAccountBalances(address, account);

    return CosmosTransactionRequirment(
        account: cosmosAccount,
        block: block,
        accountCoins: balances,
        fixedNativeGas: fixedFee);
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

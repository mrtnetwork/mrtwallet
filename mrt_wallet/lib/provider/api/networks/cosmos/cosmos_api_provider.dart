import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/cosmos/cosmos.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cosmos/cosmos.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class CosmosApiProvider implements NetworkApiProvider<ICosmosAddress> {
  CosmosApiProvider(
      {required this.provider,
      required this.network,
      required this.nodeProvider});
  final TendermintProvider provider;
  final ThorNodeProvider? nodeProvider;

  @override
  final APPCosmosNetwork network;
  @override
  ApiProviderTracker<CosmosAPIProviderService> get serviceProvider =>
      (provider.rpc as BaseProviderProtocol).provider
          as ApiProviderTracker<CosmosAPIProviderService>;

  @override
  Future<void> updateBalance(ICosmosAddress account) async {
    final request = QueryBalanceRequest(
        address: account.networkAddress,
        denom: network.coinParam.mainCoin.denom);
    final result =
        await provider.request(TendermintRequestAbciQuery(request: request));
    account.address.updateBalance(result.balance.amount);
  }

  Future<BaseAccount?> getBaseAccount(CosmosBaseAddress address) async {
    try {
      final request = QueryAccountRequest(address);
      final result =
          await provider.request(TendermintRequestAbciQuery(request: request));
      return result.account.baseAccount;
    } on RPCError catch (e) {
      if (e.errorCode == CosmosUtils.accountNotFoundErrorCode) {
        return null;
      }
      rethrow;
    }
  }

  Future<GetLatestBlockResponse> getLatestBlock() async {
    return await provider.request(
        TendermintRequestAbciQuery(request: const GetLatestBlockRequest()));
  }

  Future<SimulateResponse> simulateTransaction(List<int> txBytes) async {
    try {
      return await provider.request(
          TendermintRequestAbciQuery(request: SimulateRequest(txBytes)));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> broadcastTransaction(List<int> txRaw) async {
    final result = await provider.request(TendermintRequestBroadcastTxCommit(
        BytesUtils.toHexString(txRaw, prefix: "0x")));
    if (!result.isSuccess) {
      throw RPCError(
          message: result.checkTx.log ?? "",
          errorCode: result.checkTx.code ?? 0,
          data: result.toJson(),
          request: {});
    }
    return result.hash;
  }

  Future<ThorNodeNetworkConstants> getThorNodeConstants() async {
    return await nodeProvider!.request(ThorNodeRequestConstants());
  }
}

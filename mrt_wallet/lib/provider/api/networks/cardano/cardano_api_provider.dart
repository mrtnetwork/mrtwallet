import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cardano/cardano.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/cardano/account_utxos.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';

import 'custom_request/utxos.dart';

class CardanoApiProvider implements NetworkApiProvider<ICardanoAddress> {
  CardanoApiProvider({required this.provider, required this.network});
  final BlockforestProvider provider;
  @override
  final APPCardanoNetwork network;

  @override
  ApiProviderTracker<CardanoAPIProviderService> get serviceProvider =>
      (provider.rpc as BaseProviderProtocol).provider
          as ApiProviderTracker<CardanoAPIProviderService>;

  @override
  Future<void> updateBalance(ICardanoAddress account) async {
    final result = await provider
        .request(BlockfrostRequestAddressUTXOs(account.networkAddress));
    account.address.updateBalance(result.sumOflovelace);
  }

  Future<List<ADAAccountUTXOs>> getUtxos(ADAAddress address) async {
    return await provider.request(BlockfrostRequestGetAddressUTXOs(address));
  }

  Future<ADAEpochParametersResponse> latestEpochProtocolParameters() async {
    return await provider
        .request(BlockfrostRequestLatestEpochProtocolParameters());
  }

  Future<String> broadcastTransaction(List<int> txCborBytes) async {
    try {
      return await provider.request(BlockfrostRequestSubmitTransaction(
          transactionCborBytes: txCborBytes));
    } catch (e) {
      rethrow;
    }
  }
}

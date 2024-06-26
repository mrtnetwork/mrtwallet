import 'package:mrt_wallet/wallet/api/client/networks/cardano/methods/utxos.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/cardano/cardano.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/utxos.dart';
import 'package:on_chain/on_chain.dart';

class CardanoClient implements NetworkClient<ICardanoAddress> {
  CardanoClient({required this.provider, required this.network});
  final BlockforestProvider provider;
  @override
  final WalletCardanoNetwork network;

  @override
  APIServiceTracker<CardanoAPIProvider> get serviceProvider =>
      (provider.rpc as BaseServiceProtocol).provider
          as APIServiceTracker<CardanoAPIProvider>;

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
    return await provider.request(
        BlockfrostRequestSubmitTransaction(transactionCborBytes: txCborBytes));
  }
}

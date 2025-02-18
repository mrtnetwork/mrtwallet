import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/client/networks/cardano/methods/utxos.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cardano/cardano.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/utxos.dart';
import 'package:on_chain/ada/src/provider/exception/blockfrost_api_error.dart';
import 'package:on_chain/on_chain.dart';

class CardanoClient extends NetworkClient<ICardanoAddress, CardanoAPIProvider> {
  CardanoClient({required this.provider, required this.network});
  final BlockFrostProvider provider;
  @override
  final WalletCardanoNetwork network;
  @override
  BaseServiceProtocol<CardanoAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<CardanoAPIProvider>;

  @override
  Future<void> updateBalance(
      ICardanoAddress address, APPCHAINACCOUNT<ICardanoAddress> chain) async {
    try {
      final result = await provider
          .request(BlockfrostRequestAddressUTXOs(address.networkAddress));
      chain.updateAddressBalance(
          address: address, updateBalance: result.sumOflovelace);
    } on BlockfrostError catch (e) {
      if (e.statusCode == BlockfrostStatusCode.resourceDoesNotExist) {
        chain.updateAddressBalance(
            address: address, updateBalance: BigInt.zero);

        return;
      }
      rethrow;
    }
  }

  Future<List<ADAAccountUTXOs>> getUtxos(
      {required ICardanoAddress address, required ADAChain chain}) async {
    final utxos = await provider
        .request(BlockfrostRequestGetAddressUTXOs(address.networkAddress));
    chain.updateAddressBalance(
        address: address, updateBalance: utxos.sumOflovelace);
    return utxos;
  }

  Future<ADAEpochParametersResponse> latestEpochProtocolParameters() async {
    return await provider
        .request(BlockfrostRequestLatestEpochProtocolParameters());
  }

  Future<ADAGenesisParametersResponse> getNetworkGenesisParameters() async {
    return await provider.request(BlockfrostRequestBlockchainGenesis());
  }

  Future<String> broadcastTransaction(List<int> txCborBytes) async {
    return await provider.request(
        BlockfrostRequestSubmitTransaction(transactionCborBytes: txCborBytes));
  }

  @override
  Future<bool> onInit() async {
    final magic = await getNetworkGenesisParameters();
    return magic.networkMagic == network.coinParam.magic;
  }

  @override
  NetworkType get networkType => NetworkType.cardano;
}

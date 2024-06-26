import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/bitcoin/addresses/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class BitcoinExplorerApiProvider implements BitcoinClient<IBitcoinAddress> {
  BitcoinExplorerApiProvider({required this.provider, required this.network});
  @override
  final WalletBitcoinNetwork network;
  @override
  APIServiceTracker<BaseBitcoinAPIProvider> get serviceProvider =>
      (provider.service as HTTPService).provider
          as APIServiceTracker<BaseBitcoinAPIProvider>;
  final ApiProvider provider;

  @override
  Future<void> updateBalance(IBitcoinAddress account) async {
    final utxos = await provider
        .getAccountUtxo(UtxoAddressDetails.watchOnly(account.networkAddress));
    final balance = utxos.sumOfUtxosValue();
    account.address.updateBalance(balance);
  }

  @override
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]) async {
    assert(
        !includeTokens, "bitcoin explorer api does not support include tokens");
    final utxos = await provider.getAccountUtxo(address);
    return utxos;
  }

  @override
  Future<BitcoinFeeRate> getFeeRate() => provider.getNetworkFeeRate();

  @override
  Future<String> sendTransacation(String digest) async {
    return await provider.sendRawTransaction(digest);
  }
}

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class BitcoinApiProvider implements NetworkApiProvider {
  BitcoinApiProvider(
      {required this.provider,
      required this.network,
      required this.serviceProvider});
  final ApiProvider provider;

  @override
  Future<void> updateBalance(CryptoAddress account) async {
    account as IBitcoinAddress;
    final utxos = await provider
        .getAccountUtxo(UtxoAddressDetails.watchOnly(account.bitcoinAddress));
    final balance = utxos.sumOfUtxosValue();
    account.address.updateBalance(balance);
  }

  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address) async {
    final utxos = await provider.getAccountUtxo(address);
    return utxos;
  }

  @override
  final AppNetworkImpl network;

  @override
  final ApiProviderTracker serviceProvider;
}

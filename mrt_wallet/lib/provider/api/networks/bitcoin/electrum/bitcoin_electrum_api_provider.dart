import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'custom_request/script_hash_balance.dart';

class BitcoinElectrumApiProvider
    implements BasedBitcoinApiProvider<IBitcoinAddress> {
  BitcoinElectrumApiProvider({required this.provider});
  @override
  ApiProviderTracker<ElectrumApiProviderService> get serviceProvider =>
      (provider.rpc as BaseProviderProtocol).provider
          as ApiProviderTracker<ElectrumApiProviderService>;
  final ElectrumApiProvider provider;

  @override
  Future<void> updateBalance(IBitcoinAddress account) async {
    final balance = await provider.request(ElectrumGetScriptHashSumBalance(
        scriptHash: account.networkAddress.pubKeyHash()));
    account.address.updateBalance(balance);
  }

  @override
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]) async {
    try {
      final utxos = await provider.request(ElectrumScriptHashListUnspent(
          scriptHash: address.address.pubKeyHash(),
          includeTokens: includeTokens));
      return utxos
          .where((element) => (!includeTokens) ? element.token == null : true)
          .map((e) => UtxoWithAddress(
              utxo: e.toUtxo(address.address.type), ownerDetails: address))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BitcoinFeeRate> getFeeRate() async {
    final high = await provider.request(ElectrumEstimateFee(numberOfBlock: 2));
    final medium =
        await provider.request(ElectrumEstimateFee(numberOfBlock: 5));
    final low = await provider.request(ElectrumEstimateFee(numberOfBlock: 10));
    return BitcoinFeeRate(high: high, low: low, medium: medium);
  }

  @override
  Future<String> sendTransacation(String digest) async {
    return await provider
        .request(ElectrumBroadCastTransaction(transactionRaw: digest));
  }

  Future<String> serverBanner() async {
    return await provider.request(ElectrumServerBanner());
  }

  Future<dynamic> serverFeatures() async {
    return await provider.request(ElectrumServerFeatures());
  }

  Future<Map<String, dynamic>> serverHeaders() async {
    return await provider.request(ElectrumHeaderSubscribe());
  }

  Future<ElectrumServerInfos> serverInfo() async {
    final banner = await serverBanner();
    final features = await serverFeatures();
    final header = await serverHeaders();
    return ElectrumServerInfos(
        banner: banner, features: features, header: header);
  }
}

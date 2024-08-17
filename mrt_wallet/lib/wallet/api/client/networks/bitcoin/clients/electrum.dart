import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:mrt_wallet/wallet/api/client/networks/bitcoin/methods/script_hash_balance.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/addresses/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/networks/bitcoin/models/electrum_server_infos.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class BitcoinElectrumClient extends BitcoinClient<IBitcoinAddress> {
  BitcoinElectrumClient({required this.provider, required this.network});
  @override
  final WalletBitcoinNetwork network;

  @override
  BaseServiceProtocol<ElectrumAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<ElectrumAPIProvider>;

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

  @override
  Future<String> genesis() async {
    final result = await MethodUtils.call(() async {
      final features = await serverFeatures();
      return (features["genesis_hash"] as String);
    });
    if (result.hasResult) return result.result;
    final header = await provider
        .request(ElectrumBlockHeader(startHeight: 0, cpHeight: 0));
    return BytesUtils.toHexString(
        QuickCrypto.sha256DoubleHash(BytesUtils.fromHexString(header))
            .reversed
            .toList());
  }
}

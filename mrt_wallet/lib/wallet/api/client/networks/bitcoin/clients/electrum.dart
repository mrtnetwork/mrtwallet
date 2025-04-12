import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:mrt_wallet/wallet/api/client/networks/bitcoin/methods/script_hash_balance.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/bitcoin/models/models.dart';

class BitcoinElectrumClient extends BitcoinClient<IBitcoinAddress> {
  BitcoinElectrumClient({required this.provider, required this.network});
  @override
  final WalletBitcoinNetwork network;

  @override
  BaseServiceProtocol<ElectrumAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<ElectrumAPIProvider>;

  final ElectrumProvider provider;

  @override
  Future<void> updateBalance(
      IBitcoinAddress address, APPCHAINACCOUNT<IBitcoinAddress> chain) async {
    final balance = await provider.request(ElectrumGetScriptHashSumBalance(
        scriptHash: address.networkAddress.pubKeyHash()));
    chain.updateAddressBalance(address: address, updateBalance: balance);
  }

  @override
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]) async {
    try {
      final utxos = await provider.request(ElectrumRequestScriptHashListUnspent(
          scriptHash: address.address.pubKeyHash(),
          includeTokens: includeTokens));
      return utxos
          .where((element) => (!includeTokens) ? element.token == null : true)
          .map((e) {
        final utxo = UtxoWithAddress(
            utxo: e.toUtxo(address.address.type), ownerDetails: address);
        return utxo;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BitcoinFeeRate?> getFeeRate() async {
    final BigInt? high =
        await provider.request(ElectrumRequestEstimateFee(numberOfBlock: 2));
    if (high == null) {
      return null;
    }
    final BigInt? medium =
        await provider.request(ElectrumRequestEstimateFee(numberOfBlock: 5));
    final BigInt? low =
        await provider.request(ElectrumRequestEstimateFee(numberOfBlock: 10));
    return BitcoinFeeRate(high: high, low: low ?? high, medium: medium ?? high);
  }

  @override
  Future<String> sendTransacation(String digest) async {
    return await provider
        .request(ElectrumRequestBroadCastTransaction(transactionRaw: digest));
  }

  Future<String> serverBanner() async {
    return await provider.request(ElectrumRequestServerBanner());
  }

  Future<dynamic> serverFeatures() async {
    return await provider.request(ElectrumRequestServerFeatures());
  }

  Future<Map<String, dynamic>> serverHeaders() async {
    return await provider.request(ElectrumRequestHeaderSubscribe());
  }

  Future<ElectrumServerInfos> serverInfo() async {
    final banner = await serverBanner();
    final features = await serverFeatures();
    final header = await serverHeaders();
    final genesis = await genesisHash();
    return ElectrumServerInfos(
        banner: banner,
        features: features,
        header: header,
        genesisHash: genesis);
  }

  Future<String> genesisHash() async {
    final header = await provider
        .request(ElectrumRequestBlockHeader(startHeight: 0, cpHeight: 0));
    return BytesUtils.toHexString(
        QuickCrypto.sha256DoubleHash(BytesUtils.fromHexString(header))
            .reversed
            .toList());
  }

  @override
  Future<String> genesis() async {
    return genesisHash();
  }

  @override
  Future<BtcTransaction> getTx(String txId) async {
    return await provider.request(ElectrumRequestGetRawTransaction(txId));
  }
}

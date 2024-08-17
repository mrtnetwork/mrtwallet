import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/addresses/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

abstract class BitcoinClient<T extends IBitcoinAddress>
    extends NetworkClient<T, BaseBitcoinAPIProvider> {
  @override
  abstract final WalletBitcoinNetwork network;
  @override
  Future<void> updateBalance(T account);
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]);
  Future<String> sendTransacation(String digest);
  Future<BitcoinFeeRate> getFeeRate();
  Future<String> genesis();
  @override
  Future<bool> onInit() async {
    final genesisHash = await genesis();
    return genesisHash == network.coinParam.genesis;
  }
}

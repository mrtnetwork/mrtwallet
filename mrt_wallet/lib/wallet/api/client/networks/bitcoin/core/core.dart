import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/bitcoin/addresses/bitcoin.dart';

abstract class BitcoinClient<T extends IBitcoinAddress>
    implements NetworkClient<T, BaseBitcoinAPIProvider> {
  @override
  Future<void> updateBalance(T account);
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]);
  Future<String> sendTransacation(String digest);
  Future<BitcoinFeeRate> getFeeRate();
}

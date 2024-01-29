import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

abstract class BasedBitcoinApiProvider<T extends IBitcoinAddress>
    implements NetworkApiProvider<T> {
  @override
  Future<void> updateBalance(T account);
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]);
  Future<String> sendTransacation(String digest);
  Future<BitcoinFeeRate> getFeeRate();
}

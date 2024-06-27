import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'utxos.dart';

class CardanoUtxo {
  final ADAAccountUTXOs utxo;
  final IntegerBalance utxoBalance;
  const CardanoUtxo._({required this.utxo, required this.utxoBalance});
  factory CardanoUtxo(
      {required ADAAccountUTXOs utxo, required WalletCardanoNetwork network}) {
    return CardanoUtxo._(
        utxo: utxo,
        utxoBalance: IntegerBalance(
            utxo.sumOflovelace, network.coinParam.token.decimal!));
  }
}

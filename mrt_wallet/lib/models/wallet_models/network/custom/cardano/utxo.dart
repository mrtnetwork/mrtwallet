import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'utxos.dart';

class CardanoUtxo {
  final ADAAccountUTXOs utxo;
  final NoneDecimalBalance utxoBalance;
  const CardanoUtxo._({required this.utxo, required this.utxoBalance});
  factory CardanoUtxo(
      {required ADAAccountUTXOs utxo, required APPCardanoNetwork network}) {
    return CardanoUtxo._(
        utxo: utxo,
        utxoBalance: NoneDecimalBalance(
            utxo.sumOflovelace, network.coinParam.token.decimal!));
  }
}

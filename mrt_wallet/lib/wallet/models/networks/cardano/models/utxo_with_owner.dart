import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/utxo.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:on_chain/ada/src/address/address.dart';
import 'utxos.dart';

class CardanoUtxoWithOwner {
  final ADAAddress owner;
  final List<CardanoUtxo>? utxos;
  final IntegerBalance utxoAmounts;
  bool get hasUtxo => utxos != null;
  CardanoUtxoWithOwner._(
      {required this.owner,
      List<CardanoUtxo>? utxos,
      required this.utxoAmounts})
      : utxos = utxos == null ? null : List<CardanoUtxo>.unmodifiable(utxos);
  factory CardanoUtxoWithOwner(
      {required ADAAddress owner,
      List<ADAAccountUTXOs>? utxos,
      required WalletCardanoNetwork network}) {
    final amount = (utxos?.isEmpty ?? true)
        ? IntegerBalance.zero(network.coinParam.token.decimal!)
        : IntegerBalance(
            utxos!.sumOflovelace, network.coinParam.token.decimal!);
    return CardanoUtxoWithOwner._(
        owner: owner,
        utxoAmounts: amount,
        utxos:
            utxos?.map((e) => CardanoUtxo(utxo: e, network: network)).toList());
  }
}

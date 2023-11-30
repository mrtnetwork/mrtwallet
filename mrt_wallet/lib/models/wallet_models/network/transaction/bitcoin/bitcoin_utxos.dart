import 'package:bitcoin_base/bitcoin_base.dart';

import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BItcoinAccountUtxos {
  BItcoinAccountUtxos._(
      {required this.address,
      required this.utxoAddressDetails,
      this.utxosWithBalance,
      this.sumOfUtxos});
  factory BItcoinAccountUtxos(
      {required String address,
      required UtxoAddressDetails addressDetails,
      List<UtxoWithAddress>? utxos,
      required AppBitcoinNetwork network}) {
    if (utxos != null) {
      List<BitcoinUtxoWithBalance> utxosWithBalance = utxos
          .map((e) => BitcoinUtxoWithBalance(e.utxo, e.ownerDetails, network))
          .toList();
      final CurrencyBalance sumOfUtxos = CurrencyBalance(
          utxos.fold(BigInt.zero,
              (previousValue, element) => previousValue + element.utxo.value),
          network.coinParam.decimal);
      return BItcoinAccountUtxos._(
          address: address,
          sumOfUtxos: sumOfUtxos,
          // utxos: utxos,
          utxosWithBalance: utxosWithBalance,
          utxoAddressDetails: addressDetails);
    }
    return BItcoinAccountUtxos._(
        address: address, utxoAddressDetails: addressDetails);
  }
  final String address;
  final UtxoAddressDetails utxoAddressDetails;
  final List<BitcoinUtxoWithBalance>? utxosWithBalance;
  final CurrencyBalance? sumOfUtxos;

  bool get hasUtxo => utxosWithBalance != null;
}

class BitcoinUtxoWithBalance {
  BitcoinUtxoWithBalance(this.utxo, this.address, AppBitcoinNetwork network)
      : balance = CurrencyBalance(utxo.value, network.coinParam.decimal);

  final BitcoinUtxo utxo;
  late final CurrencyBalance balance;
  final UtxoAddressDetails address;
}

class BitcoinOutputWithBalance {
  BitcoinOutputWithBalance(
      {required this.address, required AppBitcoinNetwork network})
      : viewAddress = address.toAddress(network.coinParam.transacationNetwork),
        balance = CurrencyBalance.zero(network.coinParam.decimal);
  final BitcoinAddress address;
  final String viewAddress;
  final CurrencyBalance balance;
  bool get hasAmount => !balance.isZero;
}

import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';

abstract class CryptoAddressDetailsCore with CborSerializable {
  Live<CurrencyBalance> get balance;
  String get toAddress;
  String get viewBalance;
  DateTime get updated;
  void updateBalance(BigInt updateBalance);
}

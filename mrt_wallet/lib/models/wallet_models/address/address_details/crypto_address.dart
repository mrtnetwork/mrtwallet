import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/core/balance_core.dart';

abstract class NetworkAddressDetailsCore<T> with CborSerializable {
  Live<BalanceCore<T>> get balance;
  String get toAddress;
  String get viewBalance;
  DateTime get updated;
  void updateBalance([T updateBalance]);
}

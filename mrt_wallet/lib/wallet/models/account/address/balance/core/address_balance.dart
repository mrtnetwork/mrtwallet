import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';

abstract class AddressBalanceCore<T> with CborSerializable {
  Live<BalanceCore<T>> get balance;
  String get toAddress;
  String get viewBalance;
  DateTime get updated;
  void updateBalance([T updateBalance]);
}

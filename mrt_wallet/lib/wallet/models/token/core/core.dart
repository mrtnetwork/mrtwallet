import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

abstract class TokenCore<T> with CborSerializable {
  abstract final Token token;
  abstract final Live<BalanceCore<T>> balance;
  void updateBalance([T? updateBalance]);
  abstract final DateTime updated;
  String? get issuer;
  String? get type;
}

abstract class SolidityToken implements TokenCore<BigInt> {
  String toHexAddress();
}

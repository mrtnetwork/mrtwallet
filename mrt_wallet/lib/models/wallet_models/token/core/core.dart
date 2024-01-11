import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/core/balance_core.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

abstract class TokenCore<T> with CborSerializable {
  abstract final Token token;
  abstract final Live<BalanceCore> balance;
  void updateBalance([T? updateBalance]);
  abstract final DateTime updated;
  String? get issuer;
  String? get type;
}

abstract class SolidityToken implements TokenCore<BigInt> {
  String toHex();
}

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ton/ton_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/token/token.dart';
import 'package:ton_dart/ton_dart.dart';

class TonOutputWithBalance {
  TonOutputWithBalance({
    required this.address,
    required APPTonNetwork network,
  }) : balance = NoneDecimalBalance.zero(network.coinParam.decimal);

  final NoneDecimalBalance balance;
  final ReceiptAddress<TonAddress> address;
  bool get hasSetting => _bounce || _typeOfBoy.hasBody;
  TonOutputJettonWithBalance? _token;
  bool get hasToken => _token != null;
  NoneDecimalBalance get tokenBalance => _token!.balance;
  TonJettonToken? get jetton => _token?.token;
  BigInt get queryId => _token!.queryId;

  NoneDecimalBalance get forwardBalance => _token!.forwardBalance;

  bool _bounce = false;
  bool get bounce => _bounce;

  TonMessageBodyType _typeOfBoy = TonMessageBodyType.none;
  TonMessageBodyType get bodyType => _typeOfBoy;

  String? _body;
  String? get body => _body;

  bool get hasAmount => !balance.isZero;

  bool get isReady => hasAmount && (_token == null || hasTokenAmount);

  bool get hasTokenAmount => !_token!.balance.isZero;

  bool get hasForwardBalance => !_token!.forwardBalance.isZero;

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  void updateForwardBalance(BigInt val) {
    _token?.updateForwardAmount(val);
  }

  void updateJettonBalance(BigInt val) {
    _token?.updateBalance(val);
  }

  void toggleBounce(bool useBounce) {
    _bounce = useBounce;
  }

  void setToken(TonJettonToken? jetton) {
    _token = jetton == null ? null : TonOutputJettonWithBalance(jetton);
  }

  void updateQueryId(BigInt? val) {
    if (val == null) return;
    _token?.updateQueryId(val);
  }

  bool setBody(TonMessageBodyType type, String? messageBody) {
    if (type == TonMessageBodyType.none) {
      _body = null;
      _typeOfBoy = type;
      return true;
    }
    if (type.isValid(messageBody)) {
      _typeOfBoy = type;
      _body = messageBody;
      return true;
    }
    return false;
  }

  MessageRelaxed toMessage(APPTonNetwork network, TonAddress account) {
    final Cell? payload = _typeOfBoy.hasBody ? _typeOfBoy.toValue(body!) : null;
    if (hasToken) {
      return TonUtils.createJettonTransaferBody(
          walletAddress: jetton!.walletAddress,
          amount: balance.balance,
          jettonAmount: tokenBalance.balance,
          forwardTonAmount: forwardBalance.balance,
          responseAddress: account,
          destination: address.networkAddress,
          payload: payload,
          queryId: queryId);
    }
    return TransactioUtils.internal(
        destination: address.networkAddress,
        amount: balance.balance,
        bounce: bounce,
        body: payload);
  }
}

class TonOutputJettonWithBalance {
  final TonJettonToken token;
  final NoneDecimalBalance balance;
  final NoneDecimalBalance forwardBalance;
  BigInt _queryId = BigInt.zero;
  BigInt get queryId => _queryId;
  TonOutputJettonWithBalance._(this.token, this.balance, this.forwardBalance);
  factory TonOutputJettonWithBalance(TonJettonToken token) {
    return TonOutputJettonWithBalance._(
        token,
        NoneDecimalBalance.zero(token.token.decimal!),
        NoneDecimalBalance.zero(TonConst.deciaml));
  }

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  void updateForwardAmount(BigInt val) {
    forwardBalance.updateBalance(val);
  }

  void updateQueryId(BigInt val) {
    _queryId = val;
  }
}

import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class CosmosOutputWithBalance {
  CosmosOutputWithBalance(
      {required this.address, required WalletCosmosNetwork network})
      : _balance = IntegerBalance.zero(network.coinParam.decimal,
            allowNegative: false);

  IntegerBalance _balance;
  IntegerBalance get balance => _balance;
  final ReceiptAddress<CosmosBaseAddress> address;

  BigInt _nativeAmount = BigInt.zero;
  BigInt get nativeAmount => _nativeAmount;
  CW20Token? _token;
  CW20Token? get token => _token;

  bool get isTokenTransfer => _token != null;

  void setToken(CW20Token? token, WalletCosmosNetwork network) {
    _token = token;
    if (_token == null) {
      _balance = IntegerBalance(BigInt.zero, network.coinDecimal);
    } else {
      _balance = IntegerBalance(BigInt.zero, _token!.token.decimal!);
    }
    _checkValue();
  }

  void _checkValue() {
    if (_token != null) {
      _nativeAmount = BigInt.zero;
    } else {
      _nativeAmount = balance.balance;
    }
  }

  bool get hasAmount => !balance.isZero;

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
    _checkValue();
  }

  ServiceMessage toMessage(
      CosmosBaseAddress from, WalletCosmosNetwork network) {
    if (network.coinParam.networkType != CosmosNetworkTypes.thorAndForked) {
      return MsgSend(
          fromAddress: from,
          toAddress: address.networkAddress,
          amount: [
            Coin(
                amount: balance.balance,
                denom: _token?.denom ?? network.coinParam.denom)
          ]);
    }
    return ThorchainMsgSend(
        fromAddress: from,
        toAddress: address.networkAddress,
        amount: [
          Coin(
              amount: balance.balance,
              denom: _token?.denom ?? network.coinParam.denom)
        ]);
  }
}

class CosmosTransactionRequirment {
  final BigInt? fixedNativeGas;
  final BaseAccount? account;
  final GetLatestBlockResponse? block;
  final List<Coin> accountCoins;
  const CosmosTransactionRequirment._(
      {this.fixedNativeGas,
      this.account,
      this.block,
      this.accountCoins = const []});
  factory CosmosTransactionRequirment.accountNotFound() {
    return CosmosTransactionRequirment._();
  }
  factory CosmosTransactionRequirment({
    required BaseAccount account,
    required GetLatestBlockResponse block,
    required List<Coin> accountCoins,
    BigInt? fixedNativeGas,
  }) {
    return CosmosTransactionRequirment._(
        account: account,
        accountCoins: accountCoins,
        block: block,
        fixedNativeGas: fixedNativeGas);
  }
}

enum CosmosFeeTypes {
  basic("basic"),
  manually("manually");

  final String val;
  const CosmosFeeTypes(this.val);
  bool get isManually => this == CosmosFeeTypes.manually;
}

class CosmosTransactionFeeInfo {
  final Token token;
  final CW20Token? customFeeToken;
  final IntegerBalance feeAmount;
  final BigInt maxFee;
  final String feeDenom;
  final IntegerBalance networkFeeRate;
  final bool isNativeToken;
  bool get hasFee => feeAmount.largerThanZero;
  Fee toFee() {
    return Fee(
        amount: [Coin(denom: feeDenom, amount: feeAmount.balance)],
        gasLimit: _gasLimit);
  }

  BigInt? _gasLimit;
  BigInt? _simateGasLimit;
  BigInt _nativeFeeAmount = BigInt.zero;
  BigInt get nativeFee => _nativeFeeAmount;

  CosmosFeeTypes _feeType = CosmosFeeTypes.basic;
  CosmosFeeTypes get feeType => _feeType;

  BigInt? get gasLimit => _gasLimit;

  void setManually(CosmosFeeInfo fee) {
    _gasLimit = fee.gasLimit;
    feeAmount.updateBalance(fee.fee.amount);
    if (isNativeToken) {
      _nativeFeeAmount = fee.fee.amount;
    }
    _feeType = CosmosFeeTypes.manually;
  }

  void setBasic() {
    feeAmount.updateBalance(networkFeeRate.balance);
    _gasLimit = _simateGasLimit;
    if (isNativeToken) {
      _nativeFeeAmount = networkFeeRate.balance;
    }
    _feeType = CosmosFeeTypes.basic;
  }

  void setFee(CosmosFeeInfo fee) {
    networkFeeRate.updateBalance(fee.fee.amount);
    _simateGasLimit = fee.gasLimit;
    if (feeType.isManually) return;
    _gasLimit = fee.gasLimit;
    feeAmount.updateBalance(fee.fee.amount);
    if (isNativeToken) {
      _nativeFeeAmount = fee.fee.amount;
    }
  }

  CosmosTransactionFeeInfo._({
    required this.token,
    required this.customFeeToken,
    required this.feeAmount,
    required this.maxFee,
    required this.feeDenom,
    required this.networkFeeRate,
    required this.isNativeToken,
    BigInt? gasLimit,
  }) : _gasLimit = gasLimit;
  factory CosmosTransactionFeeInfo(
      {required Token token,
      required BigInt maxFee,
      required String denom,
      BigInt? gasLimit,
      BigInt? fee,
      BigInt? networkFeeRate}) {
    return CosmosTransactionFeeInfo._(
        token: token,
        customFeeToken: null,
        feeAmount: IntegerBalance(fee ?? BigInt.zero, token.decimal!),
        maxFee: maxFee,
        gasLimit: gasLimit,
        feeDenom: denom,
        networkFeeRate:
            IntegerBalance(networkFeeRate ?? BigInt.zero, token.decimal!),
        isNativeToken: true);
  }
  factory CosmosTransactionFeeInfo.customFee(
      {required CW20Token token,
      BigInt? gasLimit,
      BigInt? fee,
      BigInt? networkFeeRate}) {
    return CosmosTransactionFeeInfo._(
        token: token.token,
        customFeeToken: token,
        feeAmount: IntegerBalance(fee ?? BigInt.zero, token.token.decimal!),
        maxFee: token.balance.value.balance,
        gasLimit: gasLimit,
        feeDenom: token.denom,
        networkFeeRate:
            IntegerBalance(networkFeeRate ?? BigInt.zero, token.token.decimal!),
        isNativeToken: false);
  }
}

class CosmosFeeInfo {
  final BigInt? gasLimit;
  final Coin fee;
  const CosmosFeeInfo({required this.gasLimit, required this.fee});

  Fee toFee() {
    return Fee(amount: [fee], gasLimit: gasLimit);
  }
}

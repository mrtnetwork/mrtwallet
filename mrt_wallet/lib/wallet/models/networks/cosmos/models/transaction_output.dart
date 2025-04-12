import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';
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

  void setToken(CW20Token token, WalletCosmosNetwork network) {
    if (token.denom == network.coinParam.denom) {
      _token = null;
      _balance = IntegerBalance(BigInt.zero, network.coinDecimal);
    } else {
      _token = token;
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

class CosmosIbcOutputWithBalance {
  CosmosIbcOutputWithBalance._(
      {required this.chainData, required WalletCosmosNetwork network})
      : _balance = IntegerBalance.zero(network.coinParam.decimal,
            allowNegative: false),
        networkDenom = network.coinParam.denom;
  factory CosmosIbcOutputWithBalance(
      {required CosmosIbcChainData chainData,
      required WalletCosmosNetwork network}) {
    final instance =
        CosmosIbcOutputWithBalance._(chainData: chainData, network: network);
    instance._checkChannelId();
    return instance;
  }
  bool _isDefaultChannelId = true;
  bool get isDefaultChannelId => _isDefaultChannelId;
  final CosmosIbcChainData chainData;
  final String networkDenom;
  final _ibcChannelRegex = RegExp(CosmosConst.ibcChannelRegex);
  DateTime _timeout = DateTime.now().toLocal().add(const Duration(minutes: 30));
  DateTime get timeout => _timeout;
  IntegerBalance _balance;
  IntegerBalance get balance => _balance;
  ReceiptAddress<CosmosBaseAddress>? _address;
  ReceiptAddress<CosmosBaseAddress>? get address => _address;
  bool get hasAddress => _address != null;

  BigInt _nativeAmount = BigInt.zero;
  BigInt get nativeAmount => _nativeAmount;
  CW20Token? _token;
  CW20Token? get token => _token;

  String? _channelId;
  String? _memo;

  String? get channelId => _channelId;
  bool get hasChannelId => _channelId != null;
  String? get memo => _memo;

  bool get isTokenTransfer => _token != null;

  void setMemo(String? memo) {
    _memo = memo;
  }

  void setTimeout(DateTime timeout) {
    if (timeout.isBefore(DateTime.now())) return;
    _timeout = timeout;
  }

  void setChannelId(String? channelId) {
    if (channelId == null || !_ibcChannelRegex.hasMatch(channelId)) return;
    _channelId = channelId;
    _isDefaultChannelId = false;
  }

  void setAddress(ReceiptAddress<CosmosBaseAddress> address) {
    if (address.networkAddress.hrp != chainData.chain.network.coinParam.hrp) {
      return;
    }
    _address = address;
  }

  void _checkChannelId() {
    if (!_isDefaultChannelId) return;
    // final denom = token?.denom ?? networkDenom;
    // CCRIbcTransition? ibcs = chainData.ibcConnections
    //     .firstWhereOrNull((e) => e.counterparty.baseDenom == denom);
    // _channelId = ibcs?.counterparty.channelId;
  }

  void setToken(CW20Token token, WalletCosmosNetwork network) {
    if (token.denom == network.coinParam.denom) {
      _token = null;
      _balance = IntegerBalance(BigInt.zero, network.coinDecimal);
    } else {
      _token = token;
      _balance = IntegerBalance(BigInt.zero, _token!.token.decimal!);
    }
    _checkValue();
    _checkChannelId();
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
    BigInt timeout = BigInt.from(this.timeout.millisecondsSinceEpoch);
    timeout = timeout * BigInt.from(1000000);
    return MsgTransfer(
        token: Coin(
            amount: balance.balance,
            denom: _token?.denom ?? network.coinParam.denom),
        memo: memo,
        receiver: address!.networkAddress.address,
        sender: from.address,
        sourceChannel: _channelId!,
        sourcePort: CosmosConst.transferIbcPort,
        timeoutTimestamp: timeout);
  }
}

class CosmosTransactionRequirment {
  final BigInt? fixedNativeGas;
  final BaseAccount? account;
  final List<CW20Token> feeTokens;
  final BigRational? ethermintTxFee;
  late final bool hasMultipleFeeToken = feeTokens.length > 1;
  CosmosTransactionRequirment(
      {this.ethermintTxFee,
      this.fixedNativeGas,
      this.account,
      this.feeTokens = const []});
  CosmosTransactionRequirment copyWith(
      {BigInt? fixedNativeGas,
      BaseAccount? account,
      List<CW20Token>? feeTokens,
      BigRational? ethermintTxFee}) {
    return CosmosTransactionRequirment(
        account: account ?? this.account,
        ethermintTxFee: ethermintTxFee ?? this.ethermintTxFee,
        feeTokens: feeTokens ?? this.feeTokens,
        fixedNativeGas: fixedNativeGas ?? this.fixedNativeGas);
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

  factory CosmosTransactionFeeInfo.customFee(
      {required CW20Token token,
      required WalletCosmosNetwork network,
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
        isNativeToken: token.denom == network.coinParam.denom);
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

class CosmosWeb3TransactionFeeToken {
  final CW20Token token;
  final IntegerBalance feeAmount;
  CosmosWeb3TransactionFeeToken(
      {required this.token, required BigInt feeAmount})
      : feeAmount = IntegerBalance(feeAmount, token.token.decimal!);
  Coin toCosmosCoin() {
    return Coin(denom: token.denom, amount: feeAmount.balance);
  }
}

class CosmosWeb3TransactionFeeInfo {
  final List<CosmosWeb3TransactionFeeToken> fees;
  bool _isDefaultFee;
  bool get isDefaultFee => _isDefaultFee;
  BigInt _gasLimit = BigInt.zero;
  final CosmosBaseAddress? _payer;
  final CosmosBaseAddress? _granter;
  CosmosBaseAddress? get payer => _payer;
  CosmosBaseAddress? get granter => _granter;
  CosmosWeb3TransactionFeeInfo(
      {required this.fees,
      required BigInt gasLimit,
      CosmosBaseAddress? payer,
      CosmosBaseAddress? granter,
      bool isDefaultFee = false})
      : _gasLimit = gasLimit,
        _isDefaultFee = isDefaultFee,
        _payer = payer,
        _granter = granter;
  BigInt get gasLimit => _gasLimit;

  BigRational get gasLimitAsBigRational => BigRational(_gasLimit);

  /// https://lcd-axelar.keplr.app/ibc/core/channel/v1/channels/channel-10/ports/transfer

  void updateGasLimit(BigInt newGasLimit) {
    assert(!newGasLimit.isNegative);
    _gasLimit = newGasLimit;
    _isDefaultFee = false;
  }

  void updateFeeAmount(CosmosWeb3TransactionFeeToken token, BigInt amount) {
    token.feeAmount.updateBalance(amount);
  }

  Fee toTransactionFee() {
    return Fee(
        amount: fees.map((e) => e.toCosmosCoin()).toList(),
        gasLimit: _gasLimit,
        granter: _granter,
        payer: _payer);
  }
}

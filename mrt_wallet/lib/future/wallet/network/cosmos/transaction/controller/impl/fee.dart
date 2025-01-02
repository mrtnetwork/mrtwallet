import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'transaction.dart';

typedef OnSetupCosmosFee = Future<CosmosFeeInfo?> Function(
    CosmosTransactionFeeInfo fee);
mixin CosmosTransactionFeeImpl on CosmosTransactiomImpl {
  CosmosTransactionFeeInfo? _fee;
  @override
  CosmosTransactionFeeInfo get fee => _fee!;
  @override
  Token get feeToken => _fee!.token;
  bool _hasMultipleFeeToken = false;
  bool _isNativeTokenAsFee = false;
  bool get isNativeTokenAsFee => _isNativeTokenAsFee;
  bool get hasMultipleFeeToken => _hasMultipleFeeToken;
  List<CW20Token> _feeTokens = [];
  @override
  List<CW20Token> get feeTokens => _feeTokens;
  BigInt? _nativeTransactionFee;

  Future<void> initializeFee(
      {required List<Coin> feeTokens, BigInt? nativeTransactionFee}) async {
    _nativeTransactionFee = nativeTransactionFee;
    _isNativeTokenAsFee = network.coinParam.useNativeTokenAsFee;
    _hasMultipleFeeToken = network.coinParam.feeTokens.length > 1;
    if (_isNativeTokenAsFee) {
      _setFeeToken();
      return;
    }
    _feeTokens = List.generate(network.coinParam.feeTokens.length, (i) {
      final token = network.coinParam.feeTokens[i];
      return address.tokens.firstWhere(
        (e) => e.denom == token.denom,
        orElse: () => CW20Token.create(
            balance: feeTokens
                    .firstWhereNullable((e) => e.denom == token.denom)
                    ?.amount ??
                BigInt.zero,
            token: token.token,
            denom: token.denom),
      );
    });
    _setFeeToken(customFee: _feeTokens.first);
  }

  void _setFeeToken({CW20Token? customFee}) {
    if (customFee == null || customFee.denom == network.coinParam.denom) {
      _fee = CosmosTransactionFeeInfo(
        token: network.token,
        maxFee: address.address.currencyBalance,
        gasLimit: _fee?.gasLimit,
        denom: network.coinParam.denom,
      );
    } else {
      assert(!network.coinParam.useNativeTokenAsFee);
      _fee = CosmosTransactionFeeInfo.customFee(
          token: customFee, gasLimit: _fee?.gasLimit);
    }
    validator.validator.setFeeToken(_fee!);
  }

  void setFeeToken(CW20Token? customFee) {
    if (customFee == null) return;
    _setFeeToken(customFee: customFee);
    onCalculateAmount();
    simulateTr();
  }

  bool get hasFee => fee.hasFee;

  final GlobalKey<StreamWidgetState> feeProgressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "CosmosTransactionFeeImpl");

  String? _feeError;
  String? get feeError => _feeError;

  final Cancelable _cancelable = Cancelable();

  Future<CosmosFeeInfo> _simulateTr() async {
    final messages = validator.validator.messages(address.networkAddress);
    final txbody = TXBody(messages: messages, memo: memo);
    final authInfo = AuthInfo(signerInfos: [
      address.signerInfo.copyWith(sequence: ownerAccount.sequence)
    ], fee: simulateFee().toFee());
    final tx = Tx(
        body: txbody,
        authInfo: authInfo,
        signatures: [List<int>.filled(64, 0)]);
    final simulate = await apiProvider.simulateTransaction(tx.toBuffer());
    if (isThorChain) {
      return simulateFee(
          gasLimit: simulate.gasInfo.gasUsed,
          amount: messages.isEmpty
              ? _nativeTransactionFee!
              : BigInt.from(messages.length) * _nativeTransactionFee!);
    }
    BigRational gasPrice = CosmosConst.defaultGasPrice;
    if (network.coinParam.networkType.isEthermint) {
      gasPrice = await apiProvider.getEthermintBaseFee();
    } else {
      final avarageFee = network.coinParam.findFeeToken(fee.feeDenom)?.getFee();
      gasPrice = avarageFee ?? CosmosConst.defaultGasPrice;
    }
    return calculateFee(
        gasUsed: simulate.gasInfo.gasUsed,
        denom: network.coinParam.denom,
        gasPrice: gasPrice);
  }

  Future<void> simulateTr() async {
    _feeError = null;
    _cancelable.cancel();
    feeProgressKey.process();
    notify();
    try {
      final result = await MethodUtils.call(() async {
        return await _simulateTr();
      }, cancelable: _cancelable);
      if (result.hasError) {
        if (result.isCancel) return;
        _feeError = result.error;
        notify();
      } else {
        _fee!.setFee(result.result);
      }

      onCalculateAmount();
    } finally {
      feeProgressKey.idle();
    }
  }

  Future<void> setupFee(
      {required OnSetupCosmosFee onSetupFee,
      required FuncFutureNullableBoold onRemoveFee}) async {
    if (isThorChain) return;
    if (fee.feeType.isManually) {
      final r = await onRemoveFee();
      if (!(r ?? false)) return;
      fee.setBasic();
    } else {
      final fee = await onSetupFee(this.fee);
      if (fee == null) return;
      this.fee.setManually(fee);
    }
    _feeError = null;
    if (!fee.hasFee) {
      simulateTr();
      return;
    }
    onCalculateAmount();
  }

  CosmosFeeInfo simulateFee({BigInt? gasLimit, BigInt? amount}) =>
      CosmosFeeInfo(
          gasLimit: gasLimit,
          fee: Coin(
              denom: _fee!.feeDenom, amount: amount ?? BigInt.from(10000)));

  CosmosFeeInfo calculateFee(
      {required BigInt gasUsed, BigRational? gasPrice, required String denom}) {
    final gp = (BigRational(gasUsed) * CosmosConst.feeMultiplier);
    final fee = gp * (gasPrice ?? CosmosConst.defaultGasPrice);
    return CosmosFeeInfo(
        gasLimit: gp.toBigInt(),
        fee: Coin(denom: denom, amount: fee.toBigInt()));
  }
}

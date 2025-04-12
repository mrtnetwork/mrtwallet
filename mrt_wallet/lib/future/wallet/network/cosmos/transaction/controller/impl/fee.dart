import 'package:blockchain_utils/utils/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'transaction.dart';

typedef OnSetupCosmosFee = Future<CosmosFeeInfo?> Function(
    CosmosTransactionFeeInfo fee);
mixin CosmosTransactionFeeImpl on CosmosTransactiomImpl {
  CosmosTransactionRequirment? _txRequirement;
  CosmosTransactionFeeInfo? _fee;
  @override
  CosmosTransactionFeeInfo get fee => _fee!;
  @override
  Token get feeToken => _fee!.token;
  bool get hasMultipleFeeToken => _txRequirement!.hasMultipleFeeToken;
  @override
  List<CW20Token> get feeTokens => _txRequirement!.feeTokens;
  Future<void> initializeFee(CosmosTransactionRequirment txRequirment) async {
    _txRequirement = txRequirment;
    _setFeeToken(txRequirment.feeTokens.firstWhere(
        (e) => e.denom == network.coinParam.denom,
        orElse: () => txRequirment.feeTokens.first));
  }

  void _setFeeToken(CW20Token token) {
    _fee = CosmosTransactionFeeInfo.customFee(
        token: token, gasLimit: _fee?.gasLimit, network: network);
    validator.validator.setFeeToken(_fee!);
  }

  void setFeeToken(CW20Token? token) {
    if (token == null) return;
    _setFeeToken(token);
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
    ], fee: _buildFixedFee().toFee());
    final tx = Tx(
        body: txbody,
        authInfo: authInfo,
        signatures: [CryptoConst.fakeEd25519Signature]);
    final simulate = await apiProvider.simulateTransaction(tx.toBuffer());
    if (isThorChain) {
      BigInt fee = _txRequirement!.fixedNativeGas!;
      if (messages.length > 1) {
        fee = fee * BigInt.from(messages.length);
      }
      return _buildFixedFee(gasLimit: simulate.gasUsed, amount: fee);
    }
    BigRational gasPrice = CosmosConst.avarageGasPrice;
    if (network.coinParam.networkType.isEthermint) {
      gasPrice = _txRequirement!.ethermintTxFee!;
    } else {
      final avarageFee =
          network.coinParam.getFeeToken(denom: fee.feeDenom).getFee();
      gasPrice = BigRational.parseDecimal(avarageFee.price);
    }
    return _calculateFee(
        gasUsed: simulate.gasUsed,
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

  CosmosFeeInfo _buildFixedFee({BigInt? gasLimit, BigInt? amount}) =>
      CosmosFeeInfo(
          gasLimit: gasLimit,
          fee: Coin(
              denom: _fee!.feeDenom, amount: amount ?? BigInt.from(10000)));

  CosmosFeeInfo _calculateFee(
      {required BigInt gasUsed,
      required BigRational gasPrice,
      required String denom}) {
    final gp = (BigRational(gasUsed) * CosmosConst.feeMultiplier);

    final fee = (gp * gasPrice).ceil();
    return CosmosFeeInfo(
        gasLimit: gp.toBigInt(),
        fee: Coin(denom: denom, amount: fee.toBigInt()));
  }
}

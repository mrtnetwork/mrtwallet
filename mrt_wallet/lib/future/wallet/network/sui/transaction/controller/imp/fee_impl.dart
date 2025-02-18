import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/networks/sui/models/types.dart';
import 'package:on_chain/sui/sui.dart';
import 'transaction_impl.dart';

mixin SuiTransactionFeeImpl on SuiTransactionImpl {
  late SuiTransactionFee _fee =
      SuiTransactionFee(gasPrice: BigInt.zero, network: network);
  BigInt? _gasUnitPrice;

  Future<BigInt> getGasPrice() async {
    return _gasUnitPrice ??= await apiProvider.getGasPrice();
  }

  void _resetFee() {
    _fee = SuiTransactionFee(
        gasPrice: _gasUnitPrice ?? BigInt.zero, network: network);
  }

  SuiTransactionFee get fee => _fee;
  String? _feeError;
  String? get feeError => _feeError;
  final Cancelable _cancelable = Cancelable();
  final GlobalKey<StreamWidgetState> feeProgressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "AptosTransactionFeeImpl_fee");

  Future<SuiTransactionFee> _calculateFees() async {
    final gasPrice = await getGasPrice();
    SuiTransactionDataV1 transaction = await createEstimateTransaction(
        gasPrice: gasPrice, budget: SuiTransactionConst.maxGas);
    final simulate = await apiProvider.simulateGasUsed(transaction);
    return SuiTransactionFee(
        gasPrice: gasPrice, gasUsed: simulate, network: network);
  }

  Future<void> calculateFees() async {
    _resetFee();
    _feeError = null;
    feeProgressKey.process();
    _cancelable.cancel();
    checkTransaction();
    final result = await MethodUtils.call(() async {
      final result = await _calculateFees();
      return result;
    }, cancelable: _cancelable);
    feeProgressKey.idle();
    if (result.hasError) {
      if (result.isCancel) return;
      _feeError = result.error!;
    } else {
      _fee = result.result;
    }
    checkTransaction();
  }

  Future<void> initFee() async {
    await getGasPrice();
    _resetFee();
  }

  @override
  void close() {
    super.close();
    _cancelable.cancel();
  }
}

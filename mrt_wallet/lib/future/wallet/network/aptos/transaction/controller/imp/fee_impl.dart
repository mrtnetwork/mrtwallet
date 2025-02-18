import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/networks/aptos/models/types.dart';
import 'package:on_chain/aptos/src/transaction/constants/const.dart';
import 'transaction_impl.dart';

mixin AptosTransactionFeeImpl on AptosTransactionImpl {
  late AptosTransactionFee _fee =
      AptosTransactionFee(gasUnitPrice: BigInt.zero, network: network);
  BigInt? _gasUnitPrice;

  void _resetFee() {
    _fee = AptosTransactionFee(
        gasUnitPrice: _gasUnitPrice ?? BigInt.zero, network: network);
  }

  AptosTransactionFee get fee => _fee;
  String? _feeError;
  String? get feeError => _feeError;
  final Cancelable _cancelable = Cancelable();
  final GlobalKey<StreamWidgetState> feeProgressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "AptosTransactionFeeImpl_fee");

  Future<BigInt> getGasPrice() async {
    return _gasUnitPrice ??= await apiProvider.getGasUnitPrice();
  }

  Future<AptosTransactionFee> _calculateFees() async {
    final gasPrice = await getGasPrice();
    final transaction = await createTransaction(
        simulateTx: true,
        gasUnitPrice: gasPrice,
        maxGasAmount: AptosConstants.defaultMinGasAmount);
    final simulate = await apiProvider.simulateTransaction(
        rawTransaction: transaction.rawTransaction);
    if (!simulate.success) {
      throw WalletException(simulate.vmStatus);
    }
    return AptosTransactionFee(
        maxGasAmount: simulate.gasUsed,
        gasUnitPrice: simulate.gasUnitPrice,
        network: network);
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

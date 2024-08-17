import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/solana/solana.dart';
import 'transaction_impl.dart';

mixin SolanaTransactionFeeImpl on SolanaTransactionImpl {
  StreamSubscription<BigInt?>? _onFee;
  late final IntegerBalance _fee =
      IntegerBalance.zero(network.coinParam.decimal);
  IntegerBalance get fee => _fee;
  bool get hasFee => !_fee.isZero;
  SolAddress? _blockHash;
  final Cancelable _cancelable = Cancelable();
  final GlobalKey<StreamWidgetState> feeProgressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "SolanaTransactionFeeImpl_fee");

  Future<BigInt?> _calculateFees() async {
    try {
      _blockHash ??= await apiProvider.getBlockHash();
      final transaction = SolanaTransaction(
          payerKey: owner.networkAddress,
          instructions:
              await validator.validator.instructions(address.networkAddress),
          recentBlockhash: _blockHash!);
      return await apiProvider.getFee(transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> calculateFees() async {
    if (hasFee || _onFee != null) return;
    feeProgressKey.process();
    _onFee = MethodUtils.prediocCaller(() async {
      final call = await MethodUtils.call(
        () async {
          final result = await _calculateFees();
          if (result == null) {
            throw ArgumentError.notNull();
          }
          return result;
        },
      );
      return call;
    }, canclable: _cancelable, closeOnSuccess: true)
        .listen(
      (event) {
        _fee.updateBalance(event);
        onChange();
        feeProgressKey.idle();
        _cancelable.cancel();
      },
    );
    _onFee?.onDone(() {
      _onFee?.cancel();
      _onFee = null;
      feeProgressKey.idle();
      _cancelable.cancel();
    });
  }

  @override
  void close() {
    super.close();
    _onFee?.cancel();
    _onFee = null;
    _cancelable.cancel();
  }
}

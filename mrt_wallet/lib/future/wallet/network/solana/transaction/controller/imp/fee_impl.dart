import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/solana/solana.dart';
import 'transaction_impl.dart';

mixin SolanaTransactionFeeImpl on SolanaTransactionImpl {
  late final IntegerBalance _fee =
      IntegerBalance.zero(network.coinParam.decimal);
  IntegerBalance get fee => _fee;
  bool get hasFee => !_fee.isZero;
  String? _feeError;
  String? get feeError => _feeError;
  final Cancelable _cancelable = Cancelable();
  final GlobalKey<StreamWidgetState> feeProgressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "SolanaTransactionFeeImpl_fee");

  Future<BigInt?> _calculateFees() async {
    final balance = address.address.currencyBalance;
    BigInt transferLamports = BigInt.zero;
    if (validator.validator.mode != SolanaTransactionType.spl) {
      transferLamports = validator.validator.transferValue;
    }
    List<TransactionInstruction> instructions =
        await validator.validator.instructions(address.networkAddress);
    if (memo != null) {
      instructions = [...instructions, memo!];
    }
    final transaction = SolanaTransaction(
        payerKey: owner.networkAddress,
        instructions: instructions,
        recentBlockhash: SolAddress.defaultPubKey);
    final simulate = await apiProvider.simulate(
        transaction: transaction, account: address.networkAddress);
    if (simulate.accounts?.length != 1) {
      throw WalletException("transaction_simulation_failed");
    }
    if (simulate.err != null) {
      if (simulate.logs?.isNotEmpty ?? false) {
        throw WalletException(simulate.logs!.join(", "));
      }
      throw WalletException(simulate.err.toString());
    }
    final changeBalance = simulate.accounts![0]!.lamports;
    final totalAmount = balance - changeBalance;
    assert(totalAmount >= transferLamports);

    return totalAmount - transferLamports;
  }

  Future<void> calculateFees() async {
    _fee.updateBalance(BigInt.zero);
    _feeError = null;
    feeProgressKey.process();
    _cancelable.cancel();
    checkTransaction();
    final call = await MethodUtils.call(() async {
      final result = await _calculateFees();
      return result!;
    }, cancelable: _cancelable);
    feeProgressKey.idle();
    if (call.hasError) {
      if (call.isCancel) return;
      _feeError = call.error!;
    } else {
      _fee.updateBalance(call.result);
    }
    checkTransaction();
  }

  @override
  void close() {
    super.close();

    _cancelable.cancel();
  }
}

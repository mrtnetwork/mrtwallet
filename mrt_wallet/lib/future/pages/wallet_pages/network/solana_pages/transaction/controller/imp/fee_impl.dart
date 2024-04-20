import 'dart:async';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/solana/solana.dart';
import 'transaction_impl.dart';

mixin SolanaTransactionFeeImpl on SolanaTransactionImpl {
  late final NoneDecimalBalance _fee =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  NoneDecimalBalance get fee => _fee;
  bool get hasFee => !_fee.isZero;
  SolAddress? _blockHash;
  final Cancelable _cancelable = Cancelable();

  Future<BigInt?> _calculateFees() async {
    _blockHash ??= await apiProvider.getBlockHash();
    final transaction = SolanaTransaction(
        payerKey: owner.networkAddress,
        instructions:
            await validator.validator.instructions(address.networkAddress),
        recentBlockhash: _blockHash!);
    return await apiProvider.getFee(transaction);
  }

  StreamSubscription<BigInt?>? _onFee;
  Future<void> calculateFees() async {
    if (hasFee || _onFee != null) return;
    _onFee = MethodCaller.prediocCaller(() async {
      return await MethodCaller.call(
        () async {
          final result = await _calculateFees();
          if (result == null) {
            throw ArgumentError.notNull();
          }
          return result;
        },
      );
    }, canclable: _cancelable, closeOnSuccess: true)
        .listen(
      (event) {
        _fee.updateBalance(event);
        onChange();
      },
    );
    _onFee?.onDone(() {
      _onFee?.cancel();
      _onFee = null;
    });
  }

  @override
  void close() {
    super.close();
    _onFee?.cancel();
    _onFee = null;
  }
}

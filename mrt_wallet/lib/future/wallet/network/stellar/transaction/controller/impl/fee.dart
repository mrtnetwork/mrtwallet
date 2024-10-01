import 'dart:async';

import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/constant/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:stellar_dart/stellar_dart.dart';

import 'transaction_impl.dart';

mixin StellarFeeImpl on StellarTransactionImpl {
  Map<String, IntegerBalance> _fees = {};
  @override
  Map<String, IntegerBalance> get fees => _fees;
  StellarFeeMode _feeMode = StellarFeeMode.normal;
  StellarFeeMode get feeMode => _feeMode;
  bool get hasFee => fee != null;
  @override
  IntegerBalance? get fee => _fees[_feeMode.name];

  String? _feeError;
  String? get feeError => _feeError;

  BigInt get maximumFee {
    final accountBalance = address.address.currencyBalance;
    if (accountBalance > StellarConst.maxFee) {
      return StellarConst.maxFee;
    }
    return accountBalance;
  }

  StellarFeeStatsResponse? _lastestFeeStats;

  IntegerBalance _calculateFee(
      {required StellarFeeMode mode,
      required StellarFeeStatsResponse feeStats,
      required int operations}) {
    int minFee = int.parse(feeStats.maxFee.p10);
    switch (mode) {
      case StellarFeeMode.normal:
        minFee = int.parse(feeStats.maxFee.p50);
        break;
      case StellarFeeMode.high:
        minFee = int.parse(feeStats.maxFee.p90);
        break;
      default:
        break;
    }
    final fee = minFee * (operations == 0 ? 1 : operations);
    return IntegerBalance(BigInt.from(fee), network.coinDecimal);
  }

  void _buildFees(StellarFeeStatsResponse feeStats, int operations) {
    _lastestFeeStats = feeStats;
    final Map<String, IntegerBalance> fee = {};
    fee[StellarFeeMode.slow.name] = _calculateFee(
        feeStats: feeStats, mode: StellarFeeMode.slow, operations: operations);
    fee[StellarFeeMode.normal.name] = _calculateFee(
        feeStats: feeStats,
        mode: StellarFeeMode.normal,
        operations: operations);
    fee[StellarFeeMode.high.name] = _calculateFee(
        feeStats: feeStats, mode: StellarFeeMode.high, operations: operations);
    final customFee = _fees[StellarFeeMode.costom.name];
    if (customFee != null) {
      fee[StellarFeeMode.costom.name] = customFee;
    }
    _fees = fee.immutable;
  }

  final Cancelable _cancelable = Cancelable();

  // int get _operationsLength {
  //   return customOperations.length + validator.validator.operations;
  // }

  void updateFees() {
    final feeStats = _lastestFeeStats;
    if (feeStats == null) return;
    _buildFees(feeStats, customOperations.length);
    checkTransaction();
  }

  void _onFeeStats(StellarFeeStatsResponse feeStats) {
    _buildFees(feeStats, customOperations.length);
    _validateFee();
    checkTransaction();
  }

  StreamSubscription<StellarFeeStatsResponse>? _feeStream;

  Future<void> estimateFee() async {
    final result = MethodUtils.prediocCaller(() async {
      return await MethodUtils.call(() async {
        return await apiProvider.feeState();
      });
    },
        waitOnSuccess: const Duration(minutes: 10),
        closeOnSuccess: false,
        waitOnError: const Duration(seconds: 30),
        canclable: _cancelable);
    _feeStream = result.listen(_onFeeStats);
  }

  void _validateFee() {
    if (feeMode != StellarFeeMode.costom) {
      _feeError = null;
      return;
    }
    if (_fees.length < 3) return;
    if (fee!.balance < _fees[StellarFeeMode.slow.name]!.balance) {
      _feeError = "transaction_fee_warning".tr;
    } else if (fee!.balance > _fees[StellarFeeMode.high.name]!.balance) {
      _feeError = "transaction_fee_high_warning".tr;
    }
  }

  @override
  void setFee(String? feeType, {BigInt? customFee, DynamicVoid? onError}) {
    try {
      final mode = StellarFeeMode.fromName(feeType);
      if (mode == null && customFee != null) {
        if (customFee <= BigInt.zero || customFee > StellarConst.maxFee) return;
        final fee = _fees.clone();
        fee[StellarFeeMode.costom.name] =
            IntegerBalance(customFee, network.coinDecimal);
        _fees = fee.immutable;
        _feeMode = StellarFeeMode.costom;
      } else {
        if (mode == null) return;
        _feeMode = mode;
      }
    } finally {
      _validateFee();
      checkTransaction();
    }
  }

  @override
  void close() {
    super.close();
    _cancelable.cancel();
    _feeStream?.cancel();
    _feeStream = null;
  }
}

import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

import 'package:mrt_wallet/future/wallet/network/stellar/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'impl/fee.dart';
import 'impl/memo.dart';
import 'impl/sign.dart';

typedef ONTAPOPERATION = Future<StellarTransactionOperation?> Function(
    StellarTransactionOperation);

class StellarTransactionStateController extends StellarTransactionImpl
    with
        StellarFeeImpl,
        StellarTransactionMemoImpl,
        StellarTransactionSignerImpl {
  StellarTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.address,
      required super.apiProvider});
  @override
  late final StellarAccountResponse accountInfo;
  late IntegerBalance noneActiveAccountRequiredAmount;
  TransactionTimeBound _timebound = const TransactionTimeBound.auto();
  @override
  TransactionTimeBound get timebound => _timebound;

  void setTimeBound(TransactionTimeBound? timebound) {
    if (timebound == null) return;
    _timebound = timebound;
    checkTransaction();
  }

  bool _isReady = false;
  bool get isReady => _isReady;
  String? _error;
  String? get error => _error;

  late final IntegerBalance _remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  IntegerBalance get remindAmount => _remindAmount;

  List<StellarTransactionOperation> _customOperations = [];
  @override
  List<StellarTransactionOperation> get customOperations => _customOperations;

  void addOperation(StellarTransactionOperation? operation) {
    if (operation == null) return;
    final operations = _customOperations.clone();
    operations.add(operation);
    _customOperations = operations.immutable;
    updateFees();
    checkTransaction();
  }

  Future<void> removeOperation(
      {required StellarTransactionOperation operation,
      required ONTAPOPERATION callback}) async {
    final operations = _customOperations.clone();
    operations.removeWhere((e) => e == operation);
    _customOperations = operations..immutable;
    final updateOperation = await callback(operation);
    if (updateOperation == null) {
      updateFees();
      checkTransaction();
      return;
    }
    addOperation(updateOperation);
  }

  String? _checkErrors() {
    if (_timebound.isExpired) {
      return "timebound_expired";
    }
    if (customOperations.isEmpty) {
      return "transaction_empty_operation_validator_desc";
    }
    if (fee == null || fee!.isZero) {
      return "fee_zero_validator_desc".tr;
    }
    return null;
  }

  @override
  void checkTransaction() {
    _error = _checkErrors();
    BigInt customOperationAmounts = _customOperations
        .where((e) => e.asset?.asset.type.isNative ?? false)
        .fold(BigInt.zero, (p, c) => p + c.value);
    customOperationAmounts += (fee?.balance ?? BigInt.zero);
    final remindAmounts =
        address.address.currencyBalance - customOperationAmounts;
    _remindAmount.updateBalance(remindAmounts);
    _isReady = _error == null && !remindAmounts.isNegative;
    notify();
  }

  Future<void> _init() async {
    final result = await MethodUtils.call(() async {
      final baseReserve = await apiProvider.getBaseReserve();
      final account = await apiProvider.getAccountFromIStellarAddress(address);
      return (baseReserve, account);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
      return;
    }
    if (result.result.$2 == null) {
      progressKey.errorText("account_not_found".tr, backToIdle: false);
      return;
    }
    accountInfo = result.result.$2!;
    final baseReserve =
        result.result.$1 * StellarConst.newAccountReserveStroopMultiply;
    noneActiveAccountRequiredAmount =
        IntegerBalance(BigInt.from(baseReserve), network.coinDecimal);
    estimateFee();
    progressKey.success();
  }

  @override
  void ready() {
    super.ready();
    _init();
  }
}

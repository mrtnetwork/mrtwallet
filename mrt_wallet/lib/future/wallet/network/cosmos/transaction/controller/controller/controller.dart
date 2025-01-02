import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/impl/conditions.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/impl/fee.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/impl/signer.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/impl/transaction.dart';

class CosomosTransactionStateController extends CosmosTransactiomImpl
    with
        CosmosTransactionFeeImpl,
        CosmosTransactionConditions,
        CosmosSignerImpl,
        CosmosMemoImpl {
  CosomosTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.validator});

  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;

  String? _error;
  String? get error => _error;

  @override
  Future<void> onTapMemo(OnAddCosmosMemo onAddMemo) async {
    final String? currentMemo = memo;
    await super.onTapMemo(onAddMemo);
    if (memo != currentMemo) {
      simulateTr();
    }
  }

  void sendTransaction() {
    buildTransaction();
  }

  bool _isReady() {
    _error = validator.validator.validateError();
    return !remindAmount.isNegative && hasFee && _error == null;
  }

  @override
  void onCalculateAmount() {
    final totalAmounts = validator.validator.callValue;
    final BigInt remind =
        address.address.currencyBalance - totalAmounts - fee.nativeFee;
    remindAmount.updateBalance(remind);
    _trIsReady = _isReady();
    notify();
  }

  void _onChangeForm() {
    onCalculateAmount();
    if (!remindAmount.isNegative && _error == null) {
      simulateTr();
    }
  }

  @override
  void ready() {
    super.ready();
    validator.addListener(_onChangeForm);
  }

  @override
  void close() {
    super.close();
    validator.removeListener(_onChangeForm);
  }
}

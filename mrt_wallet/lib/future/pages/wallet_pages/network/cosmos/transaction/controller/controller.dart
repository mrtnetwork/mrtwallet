import 'package:mrt_wallet/future/pages/wallet_pages/network/cosmos/transaction/controller/impl/signer.dart';
import 'impl/conditions.dart';
import 'impl/fee.dart';
import 'impl/memo_impl.dart';
import 'impl/transaction.dart';

class CosomosTransactionStateController extends CosmosTransactiomImpl
    with
        CosmosTransactionFeeImpl,
        CosmosTransactionConditions,
        CosmosSignerImpl,
        CosmosMemoImpl {
  CosomosTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.address,
      required super.apiProvider,
      required super.validator});

  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;

  String? _error;
  String? get error => _error;

  String? _lastestUpdateHashCode;

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

  void _onReadyValidator(String hashCode) {
    if (_lastestUpdateHashCode == hashCode && hasFee) return;
    _lastestUpdateHashCode = hashCode;
    simulateTr();
  }

  bool _isReady() {
    _error = validator.validator.validateError();
    return !remindAmount.isNegative && hasFee && _error == null;
  }

  @override
  void onCalculateAmount() {
    final totalAmounts = validator.validator.callValue;
    final remind = address.address.balance.value.balance -
        totalAmounts -
        feeAmount.balance;
    remindAmount.updateBalance(remind);
    _trIsReady = _isReady();
    notify();
  }

  void _onChangeValidator() {
    onCalculateAmount();
  }

  void _init() {
    validator.validator.onReadyField = _onReadyValidator;
    validator.addListener(_onChangeValidator);
  }

  void _close() {
    validator.validator.onReadyField = null;
    validator.removeListener(_onChangeValidator);
  }

  @override
  void ready() {
    super.ready();
    _init();
  }

  @override
  void close() {
    super.close();
    _close();
  }

  @override
  String get repositoryId => "cosmos";
}

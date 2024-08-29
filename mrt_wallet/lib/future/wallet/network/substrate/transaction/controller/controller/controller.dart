import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/signer_impl.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/transaction_builder.dart';
import 'package:blockchain_utils/utils/compare/compare.dart';

class SubstrateTransactionStateController extends SubstrateTransactiomImpl
    with
        SubstrateSignerImpl,
        SubstrateTransactionBuilderImpl,
        SubstrateFeeImpl,
        SubstrateMemoImpl {
  SubstrateTransactionStateController(
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

  @override
  Future<void> onTapMemo(OnAddSubstrateMemo onAddMemo) async {
    final mem = List<String>.from(memos);
    await super.onTapMemo(onAddMemo);
    _checkMemos(mem);
  }

  @override
  void removeMemo(int index) {
    final mem = List<String>.from(memos);
    super.removeMemo(index);
    _checkMemos(mem);
  }

  void _checkMemos(List<String> previusMemos) {
    if (CompareUtils.iterableIsEqual(previusMemos, memos)) return;
    notify();
    if (_trIsReady) {
      estimateFee();
    }
  }

  void sendTransaction() {
    signAndSendTransaction();
  }

  void _onReadyForm() {
    estimateFee();
  }

  bool _isReady() {
    _error = validator.validator.validateError();
    return !remindAmount.isNegative && _error == null;
  }

  @override
  void onCalculateAmount() {
    final totalAmounts = validator.validator.callValue;
    final remind = address.address.currencyBalance - totalAmounts;
    remindAmount.updateBalance(remind);

    _trIsReady = _isReady();
    notify();
  }

  void _onChangeForm() {
    onCalculateAmount();
    notify();
  }

  void _init() {
    validator.validator.onReadyField = _onReadyForm;
    validator.addListener(_onChangeForm);
  }

  void _close() {
    validator.validator.onReadyField = null;
    validator.removeListener(_onChangeForm);
  }

  @override
  Future<void> signAndSendTransaction() async {
    if (!_trIsReady) return;
    super.signAndSendTransaction();
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
}

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/transaction/controller/imp/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/transaction/controller/imp/signer_impl.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/transaction/controller/imp/transaction_impl.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/aptos/src/transaction/constants/const.dart';
import 'package:on_chain/aptos/src/transaction/types/types.dart';

class AptosTransactionStateController extends AptosTransactionImpl
    with AptosTransactionFeeImpl, AptosSignerImpl {
  AptosTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.validator});
  IntegerBalance? _remindTokenAmount;
  late final IntegerBalance _remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  late (BalanceCore, Token) remindAmount;
  String? _error;
  String? get error => _error;
  bool _trReady = false;
  bool get transactionIsReady => _trReady;

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    _remindAmount.updateBalance(
        account.address.address.currencyBalance - fee.requiredFee);
    switch (validator.validator.transactionType) {
      case AptosTransactionType.transfer:
        final transactionValue =
            validator.validator.transferValue + fee.requiredFee;
        _remindAmount.updateBalance(
            account.address.address.currencyBalance - transactionValue);
        remindAmount = (_remindAmount, network.coinParam.token);
        break;
      case AptosTransactionType.tokenTransfer:
        final tokenTransferFiled =
            validator.validator.cast<AptosTransferForm>();
        final remindTokenAmounts =
            tokenTransferFiled.token!.balance.value.balance -
                (tokenTransferFiled.transferValue);
        _remindTokenAmount!.updateBalance(remindTokenAmounts);
        if (_remindAmount.isNegative) {
          remindAmount = (_remindAmount, network.coinParam.token);
        } else {
          remindAmount = (_remindTokenAmount!, tokenTransferFiled.token!.token);
        }
        break;
    }
    return _error == null &&
        !_remindAmount.isNegative &&
        !(_remindTokenAmount?.isNegative ?? false);
  }

  @override
  void checkTransaction() {
    _trReady = _checkTransaction();
    notify();
  }

  void sendTransaction(FuncFutureNullableBoold onSubmit) async {
    checkTransaction();
    if (!_trReady) {
      return;
    }
    if (!fee.isSimulate) {
      final submit = await onSubmit();
      if (submit != true) return;
    }
    await buildAndSignTransaction(
        maxGasAmount: fee.isSimulate
            ? fee.maxGasAmount
            : AptosConstants.defaultMinGasAmount,
        gasUnitPrice: fee.gasUnitPrice);
  }

  Future<void> _init() async {
    await walletProvider.wallet
        .updateAccountBalance(account, addresses: [address]);
    form.initForm(account: account, address: address);
    final r = await MethodUtils.call(() => initFee());
    if (r.hasError) {
      progressKey.errorText(r.error!.tr, backToIdle: false);
      return;
    }
    if (validator.validator.transactionType.isTokenTransfer) {
      final tokenTransferFiled = validator.validator.cast<AptosTransferForm>();
      _remindTokenAmount =
          IntegerBalance.zero(tokenTransferFiled.token!.token.decimal!);
    }
    _trReady = _checkTransaction();
    progressKey.backToIdle();
  }

  void onChange() {
    checkTransaction();
    if (_trReady || (error == null && feeError != null)) {
      calculateFees();
    }
  }

  @override
  void ready() {
    validator.addListener(onChange);
    validator.validator.initForm(account: account, address: address);
    super.ready();
  }

  @override
  void init() {
    super.init();
    _init();
  }

  @override
  AptosTransactionPayload createTransactionPayload() {
    return validator.validator.createTransaction(address);
  }

  @override
  void close() {
    validator.removeListener(onChange);
    validator.validator.close();
    super.close();
  }
}

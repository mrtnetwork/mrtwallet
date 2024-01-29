import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/sign_transaction_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/transaction_validator/validators.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleTransactionStateController extends RippleTransactionImpl
    with RippleMemoImpl, RippleFeeImpl, RippleSignTransactionImpl {
  RippleTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.network,
      required super.apiProvider,
      required super.address,
      required this.validator});

  final GlobalKey<StreamWidgetState> buttonKey = GlobalKey<StreamWidgetState>();

  @override
  Future<void> onSetupMemo(XRPLMemo? memo, OnSetupMemo onSetupMemo) async {
    await super.onSetupMemo(memo, onSetupMemo);
    notify();
  }

  final LiveTransactionValidator<RippleTransactionValidator> validator;
  late final RipplePaymentValidator? _isPayment = _getPaymentValidator;
  RipplePaymentValidator? get _getPaymentValidator {
    if (validator.validator.transactionType == XRPLTransactionType.payment) {
      return validator.validator as RipplePaymentValidator;
    }
    return null;
  }

  late final DecimalBalance _remindTokenAmount = DecimalBalance.zero();
  late final NoneDecimalBalance _remindAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late (BalanceCore, Token) remindAmount;

  @override
  void setFee(String? feeType, {BigInt? customFee}) {
    super.setFee(feeType, customFee: customFee);
    _checkTransaction();
    notify();
  }

  void _init() async {
    progressKey.progressText("retrieving_network_condition".tr);
    final result = await MethodCaller.call(() async {
      await fetchFee();
      return await canSignTransaction();
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else if (result.result == null) {
      progressKey.errorText("account_not_found".tr, backToIdle: false);
    } else if (!result.result!) {
      if (address.multiSigAccount) {
        progressKey.errorText("ripple_account_signature_updated_desc".tr,
            backToIdle: false);
      } else {
        progressKey.errorText("disable_master_key_addr".tr, backToIdle: false);
      }
    } else {
      _checkTransaction();
      progressKey.success();
    }
  }

  BigInt get _validatorXRPValue {
    if (_isPayment?.issueToken != null) return BigInt.zero;
    return _isPayment?.amount.value?.balance ?? BigInt.zero;
  }

  void _checkTransaction() {
    _updateCustomFee();
    final remindAmounts = address.address.balance.value.balance -
        (fee.balance + _validatorXRPValue);
    _remindAmount.updateBalance(remindAmounts);
    if (_isPayment?.issueToken == null) {
      remindAmount = (_remindAmount, network.coinParam.token);
    } else {
      final remindTokenAmounts = _isPayment!.issueToken!.balance.value.balance -
          (_isPayment!.amount.value?.balance ?? BigRational.zero);
      _remindTokenAmount.updateBalance(remindTokenAmounts);
      if (_remindAmount.isNegative) {
        remindAmount = (_remindAmount, network.coinParam.token);
      } else {
        remindAmount = (_remindTokenAmount, _isPayment!.token);
      }
    }
  }

  String? _fieldError;
  String? get fieldsError => _fieldError;

  @override
  String get repositoryId => "ripple/transaction";

  void sendTr() async {
    _fieldError = null;
    notify();
    buttonKey.process();

    final result = await MethodCaller.call(() async {
      _checkTransaction();

      if (remindAmount.$1.isNegative) throw WalletExceptionConst.emptyThrow;
      _fieldError = validator.validator.validateError(account: address);
      if (_fieldError != null) throw WalletException(_fieldError!);
      final transaction = validator.validator.toTransaction(
          address.address.toAddress,
          memos: memos,
          fee: fee.balance);
      await super.signAndSendTransaction(RippleSigningRequest(
          addresses: [address], network: network, transaction: transaction));
    });
    if (result.hasError) {
      buttonKey.error();
    } else {
      buttonKey.success();
    }
  }

  void _updateCustomFee() {
    if (transactionType != XRPLTransactionType.escrowFinish) return;
    final v = validator.validator as RippleEscrowFinishValidator;
    updateFee(v.fulfillment.value);
  }

  void _onChangeValidator() {
    _checkTransaction();
    notify();
  }

  @override
  void ready() {
    super.ready();
    validator.addListener(_onChangeValidator);
    _init();
  }

  @override
  void close() {
    validator.dispose();
    super.close();
  }

  @override
  XRPLTransactionType get transactionType =>
      validator.validator.transactionType;
}

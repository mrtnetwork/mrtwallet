import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/sign_transaction_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

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

  final LiveTransactionForm<RippleTransactionForm> validator;
  late final RipplePaymentForm? _isPayment = _getPaymentForm;
  RipplePaymentForm? get _getPaymentForm {
    if (validator.validator.transactionType == XRPLTransactionType.payment) {
      return validator.validator as RipplePaymentForm;
    }
    return null;
  }

  late final DecimalBalance _remindTokenAmount = DecimalBalance.zero();
  late final IntegerBalance _remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  late (BalanceCore, Token) remindAmount;

  @override
  void setFee(String? feeType, {BigInt? customFee}) {
    super.setFee(feeType, customFee: customFee);
    _checkTransaction();
    notify();
  }

  void _init() async {
    progressKey.progressText("retrieving_network_condition".tr);
    final result = await MethodUtils.call(() async {
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
    final remindAmounts =
        address.address.currencyBalance - (fee.balance + _validatorXRPValue);
    _remindAmount.updateBalance(remindAmounts);
    if (_isPayment?.issueToken == null) {
      remindAmount = (_remindAmount, network.coinParam.token);
    } else {
      final remindTokenAmounts = _isPayment!.issueToken!.balance.value.balance -
          (_isPayment.amount.value?.balance ?? BigRational.zero);
      _remindTokenAmount.updateBalance(remindTokenAmounts);
      if (_remindAmount.isNegative) {
        remindAmount = (_remindAmount, network.coinParam.token);
      } else {
        remindAmount = (_remindTokenAmount, _isPayment.token);
      }
    }
  }

  String? _fieldError;
  String? get fieldsError => _fieldError;

  void sendTr() async {
    _fieldError = null;
    notify();
    buttonKey.process();

    final result = await MethodUtils.call(() async {
      _checkTransaction();

      if (remindAmount.$1.isNegative) throw WalletExceptionConst.emptyThrow;
      _fieldError = validator.validator.validateError(account: address);
      if (_fieldError != null) throw WalletException(_fieldError!);
      final transaction = validator.validator.toTransaction(
          address.networkAddress,
          memos: memos,
          fee: fee.balance);
      bool needMultiSig = false;
      if (address.multiSigAccount) {
        final IXRPMultisigAddress addr = address as IXRPMultisigAddress;
        needMultiSig = !addr.multiSignatureAccount.isRegular;
      }
      await super.signAndSendTransaction(
          WalletSigningRequest<XRPTransaction>(
            addresses: [address],
            network: network,
            sign: (generateSignature) async {
              if (!needMultiSig) {
                final keyIndex = address.keyIndex as Bip32AddressIndex;
                final algorithm = XRPKeyAlgorithm.values.firstWhere((element) =>
                    element.curveType == keyIndex.currencyCoin.conf.type);
                final pubkey = XRPPublicKey.fromBytes(address.publicKey,
                        algorithm: algorithm)
                    .toHex();

                transaction.setSignature(XRPLSignature.signer(pubkey));
                final signRequest = GlobalSignRequest.ripple(
                    digest: BytesUtils.fromHexString(transaction.toBlob()),
                    index: keyIndex);
                final sss = await generateSignature(signRequest);

                transaction.setSignature(XRPLSignature.sign(
                    pubkey, BytesUtils.toHexString(sss.signature)));
              } else {
                final multiSigAddress = address as IXRPMultisigAddress;
                final List<XRPLSigners> signerSignatures = [];
                int threshHold = 0;
                for (final i in multiSigAddress.multiSignatureAccount.signers) {
                  final address =
                      RippleUtils.strPublicKeyToRippleAddress(i.publicKey)
                          .address;
                  final blob = transaction.toMultisigBlob(address);
                  try {
                    final signRequest = GlobalSignRequest.ripple(
                        digest: BytesUtils.fromHexString(blob),
                        index: i.keyIndex);
                    final sss = await generateSignature(signRequest);
                    signerSignatures.add(XRPLSigners(
                        account: address,
                        signingPubKey:
                            XRPPublicKey.fromHex(sss.signerPubKey.comprossed)
                                .toHex(),
                        txnSignature: BytesUtils.toHexString(sss.signature)));
                    threshHold += i.weight;
                    if (threshHold >=
                        multiSigAddress.multiSignatureAccount.threshold) {
                      break;
                    }
                  } catch (e) {
                    continue;
                  }
                }
                if (threshHold <
                    multiSigAddress.multiSignatureAccount.threshold) {
                  throw WalletExceptionConst.privateKeyIsNotAvailable;
                }

                transaction.setMultiSigSignature(signerSignatures);
              }
              return transaction;
            },
          ),
          transaction);
    });
    if (result.hasError) {
      buttonKey.error();
    } else {
      buttonKey.success();
    }
  }

  void _updateCustomFee() {
    if (transactionType != XRPLTransactionType.escrowFinish) return;
    final v = validator.validator as RippleEscrowFinishForm;
    updateFee(v.fulfillment.value);
  }

  void _onChangeForm() {
    _checkTransaction();
    notify();
  }

  @override
  void ready() {
    super.ready();
    validator.addListener(_onChangeForm);
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

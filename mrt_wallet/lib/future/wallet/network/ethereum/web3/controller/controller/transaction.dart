import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/signer_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/controller/impl/web3.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/init_fee.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/web3_transaction_infos.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/on_chain.dart';

typedef ONInsufficientBalance = Future<bool?> Function();

class Web3EthereumTransactionRequestController
    extends Web3EthereumImpl<String, Web3EthreumSendTransaction>
    with ETHTransactionFeeImpl, ETHSignerImpl {
  Web3EthereumTransactionRequestController(
      {required super.walletProvider, required super.request});

  Web3EthereumTransactionRequestInfos? _transactionInfos;
  Web3EthereumTransactionRequestInfos get transactionInfos =>
      _transactionInfos!;
  @override
  EthereumInitFee? get initFee => transactionInfos.initFee;

  IntegerBalance? _remindTokenAmount;
  late final IntegerBalance _remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  late (IntegerBalance, Token) remindAmount;

  bool _trReady = false;
  bool get trIsReady => _trReady;
  bool _insufficientBalance = false;

  bool get insufficientBalance => _insufficientBalance;

  bool _checkTransaction() {
    final transactionValue = transactionInfos.value.balance +
        (currentEIP1559Fee?.fee.balance ?? BigInt.zero);
    final erc20Transfer =
        transactionInfos.dataInfo?.safeCast<SolidityERC20TransferMethodInfo>();
    _remindAmount
        .updateBalance(address.address.currencyBalance - transactionValue);
    if (erc20Transfer == null) {
      remindAmount = (_remindAmount, network.coinParam.token);
    } else {
      final remindTokenAmounts = erc20Transfer.token.balance.value.balance -
          erc20Transfer.value.balance;
      _remindTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remindAmount.isNegative) {
        remindAmount = (_remindAmount, network.coinParam.token);
      } else {
        remindAmount = (_remindTokenAmount!, erc20Transfer.token.token);
      }
    }
    _insufficientBalance = remindAmount.$1.isNegative;

    return gasInited && (feeSpeed == EIP1559FeeSpeed.customFee || !updatingGas);
  }

  @override
  void onFeeChanged() {
    _trReady = _checkTransaction();
    notify();
  }

  void _init() {
    final erc20Transfer =
        transactionInfos.dataInfo?.safeCast<SolidityERC20TransferMethodInfo>();
    if (erc20Transfer != null) {
      _remindTokenAmount = IntegerBalance(
          erc20Transfer.value.balance, erc20Transfer.token.token.decimal!);
    }
    _trReady = _checkTransaction();
  }

  Map<String, dynamic> _toEstimateData() {
    final transaction = ETHTransaction(
        type: transactionInfos.type,
        from: address.networkAddress,
        to: request.params.to,
        nonce: 0,
        gasLimit: BigInt.one,
        data: request.params.data,
        value: BigInt.zero,
        accessList: request.params.accessList
            ?.map((e) => AccessListEntry(
                address: e.address.address,
                storageKeys: e.storageKeys
                    .map((e) => BytesUtils.toHexString(e))
                    .toList()))
            .toList(),
        chainId: network.coinParam.chainId);
    return transaction.toEstimate();
  }

  @override
  Future<void> estimateGasLimit({Map<String, dynamic>? estimateDetails}) async {
    await super.estimateGasLimit(estimateDetails: _toEstimateData());
  }

  void sendTransaction(ONInsufficientBalance onInsufficientBalance) async {
    try {
      if (_insufficientBalance) {
        final accept = await onInsufficientBalance();
        if (accept != true) return;
      }
      final fee = currentEIP1559Fee?.clone();
      if (fee == null || !trIsReady) return;
      final ETHTransaction transaction = ETHTransaction(
          type: transactionInfos.type,
          from: address.networkAddress,
          chainId: network.coinParam.chainId,
          data: request.params.data,
          nonce: 0,
          accessList: request.params.accessList
              ?.map((e) => AccessListEntry(
                  address: e.address.address,
                  storageKeys: e.storageKeys
                      .map((e) => BytesUtils.toHexString(e))
                      .toList()))
              .toList(),
          gasPrice: fee.gasPrice,
          maxFeePerGas: fee.maxFeePerGas,
          maxPriorityFeePerGas: fee.maxPriorityFeePerGas,
          gasLimit: BigInt.from(fee.gasLimit),
          value: request.params.value,
          to: request.params.to);
      progressKey.process(
          text: "create_send_transaction"
              .tr
              .replaceOne(network.coinParam.token.name));

      final signedTransaction = await MethodUtils.call(() async {
        return await signTransaction(transaction);
      });
      if (signedTransaction.hasError) {
        progressKey.error(
            error: signedTransaction.exception, showBackButton: true);
        return;
      }

      final result = await MethodUtils.call(() async {
        return await apiProvider.sendRawTransaction(signedTransaction.result);
      });
      stopGasEstimate();
      if (result.hasError) {
        progressKey.errorResponse(error: result.exception);
        final error =
            Web3RequestExceptionConst.fromException(result.exception!);
        request.error(error);
      } else {
        progressKey.responseTx(hash: result.result, network: network);
        request.completeResponse(result.result);
      }
    } finally {
      notify();
    }
  }

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final result = await MethodUtils.call(() async =>
        await apiProvider.getWeb3TransactionInfos(
            from: address, transaction: request.params, chain: account));

    if (result.hasError) {
      progressKey.errorResponse(error: result.exception);
    } else {
      _transactionInfos = result.result;
      try {
        await apiProvider.estimateGasLimit(_toEstimateData());
      } catch (e) {
        progressKey.errorResponse(error: e);
        final error = Web3RequestExceptionConst.fromException(e);
        request.error(error);
        return;
      }
      startGasListening();
      _init();
      progressKey.idle();
      estimateGasLimit();
    }
  }
}

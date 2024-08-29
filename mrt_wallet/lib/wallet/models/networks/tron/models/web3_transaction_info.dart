import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/networks/ethereum/models/web3_transaction_infos.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:on_chain/tron/tron.dart';

abstract class Web3TronTransactionInfo {
  const Web3TronTransactionInfo();

  abstract final TransactionContractType? type;
  abstract final IntegerBalance? totalTrxAmount;
  abstract final ReceiptAddress<TronAddress>? destination;
  Web3TronTransferAssetInfo? get transferAsset => null;

  SolidityERC20TransferMethodInfo? get trc20Transfer => null;

  bool get isTransferContract =>
      type == TransactionContractType.transferContract;
  bool get isSmartContract =>
      type == TransactionContractType.triggerSmartContract;
  bool get isCreateContract =>
      type == TransactionContractType.createSmartContract;
}

class Web3TronTransferInfo extends Web3TronTransactionInfo {
  @override
  TransactionContractType get type => TransactionContractType.transferContract;
  final ReceiptAddress<TronAddress> receiptAddress;
  final IntegerBalance amount;
  Web3TronTransferInfo._({required this.receiptAddress, required this.amount});
  factory Web3TronTransferInfo(
      {required ReceiptAddress<TronAddress> receiptAddress,
      required BigInt amount}) {
    return Web3TronTransferInfo._(
      receiptAddress: receiptAddress,
      amount: IntegerBalance(amount, TronUtils.decimal),
    );
  }

  @override
  IntegerBalance get totalTrxAmount => amount;

  @override
  ReceiptAddress<TronAddress>? get destination => receiptAddress;
}

class Web3TronTransferAssetInfo extends Web3TronTransactionInfo {
  final TronTRC10Token token;
  final ReceiptAddress<TronAddress> receiptAddress;
  final IntegerBalance amount;
  const Web3TronTransferAssetInfo._(
      {required this.amount,
      required this.receiptAddress,
      required this.token});
  factory Web3TronTransferAssetInfo(
      {required TronTRC10Token token,
      required ReceiptAddress<TronAddress> receiptAddress,
      required BigInt amount}) {
    return Web3TronTransferAssetInfo._(
        token: token,
        receiptAddress: receiptAddress,
        amount: IntegerBalance(amount, token.token.decimal!));
  }

  @override
  TransactionContractType get type =>
      TransactionContractType.transferAssetContract;

  @override
  final IntegerBalance? totalTrxAmount = null;

  @override
  ReceiptAddress<TronAddress>? get destination => receiptAddress;
  @override
  Web3TronTransferAssetInfo? get transferAsset => this;
}

class Web3TronTriggerSmartContract extends Web3TronTransactionInfo {
  final Web3TronTransferInfo? value;
  final Web3TronTransferAssetInfo? callValue;
  final ReceiptAddress<TronAddress> contractAddress;
  final EthereumTransactionDataInfo dataInfo;

  const Web3TronTriggerSmartContract._(
      {required this.contractAddress,
      required this.value,
      required this.callValue,
      required this.dataInfo});
  factory Web3TronTriggerSmartContract(
      {required Web3TronTransferInfo? value,
      required Web3TronTransferAssetInfo? callValue,
      required ReceiptAddress<TronAddress> contractAddress,
      required EthereumTransactionDataInfo dataInfo}) {
    return Web3TronTriggerSmartContract._(
        value: value,
        contractAddress: contractAddress,
        callValue: callValue,
        dataInfo: dataInfo);
  }

  @override
  TransactionContractType get type =>
      TransactionContractType.triggerSmartContract;

  @override
  IntegerBalance? get totalTrxAmount => value?.totalTrxAmount;

  @override
  ReceiptAddress<TronAddress>? get destination => contractAddress;
  @override
  Web3TronTransferAssetInfo? get transferAsset => callValue;
  @override
  SolidityERC20TransferMethodInfo<TronAddress>? get trc20Transfer =>
      dataInfo.type == SolidityMethodInfoTypes.erc20Transfer
          ? dataInfo as SolidityERC20TransferMethodInfo<TronAddress>
          : null;
}

class Web3TronFreezeBalanceInfo extends Web3TronTransactionInfo {
  final ResourceCode resource;
  final IntegerBalance amount;
  const Web3TronFreezeBalanceInfo._(
      {required this.amount, required this.resource});
  factory Web3TronFreezeBalanceInfo(
      {required ResourceCode resource, required BigInt amount}) {
    return Web3TronFreezeBalanceInfo._(
        resource: resource, amount: IntegerBalance(amount, TronUtils.decimal));
  }

  @override
  TransactionContractType get type =>
      TransactionContractType.freezeBalanceV2Contract;
  @override
  IntegerBalance get totalTrxAmount => amount;
  @override
  final ReceiptAddress<TronAddress>? destination = null;
}

class Web3TronCreateContractInfo extends Web3TronTransactionInfo {
  final Web3TronTransferInfo? value;
  final Web3TronTransferAssetInfo? callValue;
  final TronAddress contractAddress;
  const Web3TronCreateContractInfo(
      {required this.value,
      required this.callValue,
      required this.contractAddress});
  @override
  TransactionContractType get type =>
      TransactionContractType.createSmartContract;
  @override
  IntegerBalance? get totalTrxAmount => value?.amount;
  @override
  final ReceiptAddress<TronAddress>? destination = null;
  @override
  Web3TronTransferAssetInfo? get transferAsset => callValue;
}

class Web3TronUnknowContractInfo extends Web3TronTransactionInfo {
  final Map<String, dynamic> contractFields;
  const Web3TronUnknowContractInfo(
      {required this.contractFields, required this.totalTrxAmount});
  @override
  TransactionContractType? get type => null;
  @override
  final IntegerBalance? totalTrxAmount;
  @override
  final ReceiptAddress<TronAddress>? destination = null;
}

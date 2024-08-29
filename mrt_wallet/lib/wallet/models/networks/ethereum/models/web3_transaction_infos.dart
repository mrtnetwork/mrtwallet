import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/wallet/constant/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/others.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/etherum.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/address/core.dart';

import 'init_fee.dart';

class Web3EthereumTransactionRequestInfos {
  bool get isContract => dataInfo != null;
  final String? data;
  final EthereumTransactionDataInfo? dataInfo;
  final ReceiptAddress<ETHAddress>? destination;

  final IntegerBalance value;
  final EthereumInitFee? initFee;

  const Web3EthereumTransactionRequestInfos._(
      {this.destination,
      this.data,
      this.dataInfo,
      required this.value,
      this.initFee});
  factory Web3EthereumTransactionRequestInfos({
    required bool isContract,
    required Web3EthreumSendTransaction transaction,
    required ReceiptAddress<ETHAddress>? destination,
    required EthereumTransactionDataInfo? contractInfo,
  }) {
    EthereumInitFee? initFee;
    if (transaction.hasFee) {
      initFee = EthereumInitFee(
          gasLimit: transaction.gas,
          gasPrice: transaction.gasPrice,
          maxFeePerGas: transaction.maxFeePerGas,
          maxPriorityFeePerGas: transaction.maxPriorityFeePerGas);
    }
    return Web3EthereumTransactionRequestInfos._(
        value: IntegerBalance(transaction.value, ETHConst.decimals),
        data: BytesUtils.toHexString(transaction.data, prefix: "0x"),
        initFee: initFee,
        destination: destination,
        dataInfo: contractInfo);
  }
}

enum SolidityMethodInfoTypes {
  unknown("unknown"),
  unknownData("unknown"),
  creationContract("creation_contract"),
  nameAndInputs(""),
  erc20("erc20"),
  erc20Transfer("token_transfer");

  final String localizationName;
  const SolidityMethodInfoTypes(this.localizationName);
}

abstract class EthereumTransactionDataInfo {
  final String? selector;
  EthereumTransactionDataInfo({List<int>? selector})
      : selector = BytesUtils.tryToHexString(selector, prefix: "0x");
  SolidityMethodInfoTypes get type;

  String get localizationName => "smart_contract";

  T? safeCast<T extends EthereumTransactionDataInfo>() {
    if (this is T) return this as T;
    return null;
  }

  T cast<T extends EthereumTransactionDataInfo>() {
    return this as T;
  }
}

class UnknownTransactionData extends EthereumTransactionDataInfo {
  final String dataHex;
  final String? content;
  UnknownTransactionData(this.dataHex, this.content);
  factory UnknownTransactionData.fromBytes(List<int> data) {
    final dataHex = BytesUtils.toHexString(data, prefix: "0x");
    final content = StringUtils.tryDecode(data);
    return UnknownTransactionData(dataHex, content);
  }

  @override
  SolidityMethodInfoTypes get type => SolidityMethodInfoTypes.unknownData;
  @override
  String get localizationName => type.localizationName;
}

class SolidityCreationContract extends EthereumTransactionDataInfo {
  @override
  SolidityMethodInfoTypes get type => SolidityMethodInfoTypes.creationContract;
  @override
  String get localizationName => type.localizationName;
}

class SolidityUnknownMethodInfo extends EthereumTransactionDataInfo {
  SolidityUnknownMethodInfo({required this.dataHex, required super.selector});
  final String dataHex;

  @override
  SolidityMethodInfoTypes get type => SolidityMethodInfoTypes.unknown;
}

class SolidityNameAndInputValues extends EthereumTransactionDataInfo {
  SolidityNameAndInputValues(
      {required super.selector, required this.inputs, required this.name});
  final List<dynamic> inputs;
  final String? name;
  @override
  SolidityMethodInfoTypes get type => SolidityMethodInfoTypes.nameAndInputs;

  @override
  String get localizationName => name ?? super.localizationName;
}

class SolidityERC20MethodInfo extends EthereumTransactionDataInfo {
  SolidityERC20MethodInfo({
    required super.selector,
    required this.token,
    required this.dataHex,
  });
  final SolidityToken token;
  final String dataHex;
  @override
  SolidityMethodInfoTypes get type => SolidityMethodInfoTypes.erc20;
}

class SolidityERC20TransferMethodInfo<T extends SolidityAddress>
    extends SolidityERC20MethodInfo {
  SolidityERC20TransferMethodInfo({
    required super.selector,
    required super.token,
    required this.to,
    required this.value,
    required super.dataHex,
  });
  final ReceiptAddress<T> to;
  final IntegerBalance value;
  @override
  SolidityMethodInfoTypes get type => SolidityMethodInfoTypes.erc20Transfer;

  @override
  String get localizationName => type.localizationName;
}

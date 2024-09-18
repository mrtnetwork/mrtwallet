import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/crypto/utils/utils.dart';
import 'package:on_chain/on_chain.dart';

class EthereumTransferForm extends EthereumTransactionForm {
  EthereumTransferForm({required this.token, this.erc20Token});
  @override
  BigInt get callValue => mode != ETHTransactionMode.erc20Transfer
      ? (amount.value?.balance ?? BigInt.zero)
      : BigInt.zero;
  @override
  BigInt get tokenValue => mode == ETHTransactionMode.erc20Transfer
      ? (amount.value?.balance ?? BigInt.zero)
      : BigInt.zero;
  final Token token;
  final ETHERC20Token? erc20Token;
  final TransactionFormField<ReceiptAddress<ETHAddress>> destination =
      TransactionFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "amount",
    optional: false,
    onChangeForm: (v) {
      try {
        if (v!.isZero || v.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields => [destination, amount];

  @override
  String get name => erc20Token != null ? "transfer_erc20" : "transfer";

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
      _checkEstimate();
    }
  }

  void _checkEstimate() {
    if (validateError() == null && erc20Token != null) {
      onStimateChanged?.call();
    }
  }

  @override
  String? validateError({IEthAddress? account}) {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> toEstimate(
      {required IEthAddress address,
      required WalletEthereumNetwork network,
      String? memo}) {
    final estimate = ETHTransaction(
            from: address.networkAddress,
            to: erc20Token?.contractAddress ??
                destination.value?.networkAddress ??
                address.networkAddress,
            nonce: 0,
            gasLimit: BigInt.one,
            data: _getData(memo),
            value: BigInt.zero,
            chainId: network.coinParam.chainId)
        .toEstimate();
    return estimate;
  }

  List<int> _getData([String? memo]) {
    List<int> transactionData = [];
    if (erc20Token != null && destination.hasValue && amount.hasValue) {
      transactionData = SolidityContractUtils.erc20Transfer
          .encode([destination.value!.networkAddress, amount.value!.balance]);
    }
    if (memo != null) {
      transactionData = List<int>.from(
          [...transactionData, ...StringUtils.tryToBytes(memo) ?? <int>[]]);
    }
    return transactionData;
  }

  @override
  ETHTransaction toTransaction(
      {required IEthAddress address,
      required WalletEthereumNetwork network,
      required EthereumFee fee,
      String? memo}) {
    ETHTransaction tr = ETHTransaction(
      type: fee.isEIP1559
          ? ETHTransactionType.eip1559
          : ETHTransactionType.legacy,
      from: address.networkAddress,
      chainId: network.coinParam.chainId,
      data: _getData(memo),
      nonce: 0,
      gasPrice: fee.gasPrice,
      maxFeePerGas: fee.maxFeePerGas,
      maxPriorityFeePerGas: fee.maxPriorityFeePerGas,
      gasLimit: BigInt.from(fee.gasLimit),
      value: erc20Token != null ? BigInt.zero : amount.value!.balance,
      to: erc20Token?.contractAddress ?? destination.value!.networkAddress,
    );
    return tr;
  }

  @override
  ETHTransactionMode get mode => erc20Token != null
      ? ETHTransactionMode.erc20Transfer
      : ETHTransactionMode.transfer;
}

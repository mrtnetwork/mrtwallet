import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/ethereum/erc20_token.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:on_chain/on_chain.dart';

class EthereumTransferValidator extends EthereumTransactionValidator {
  EthereumTransferValidator({required this.token, this.erc20Token});
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
  final ValidatorField<ReceiptAddress<ETHAddress>> destination = ValidatorField(
      id: "receiver",
      name: "destination",
      optional: false,
      onChangeValidator: (p0) {
        return p0;
      },
      subject: "");
  final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
    name: "amount",
    subject: "",
    optional: false,
    id: "",
    onChangeValidator: (v) {
      try {
        if (v!.isZero || v.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [destination, amount];

  @override
  String get fieldsName => throw UnimplementedError();

  @override
  String get helperUri => throw UnimplementedError();

  @override
  bool get isValid => validateError() == null;

  @override
  String get name => erc20Token != null ? "transfer_erc20" : "transfer";

  @override
  void removeIndex<T>(ValidatorField<List<T>> field, int index) {}

  @override
  void setListValue<T>(ValidatorField<List<T>> field, T? value) {}

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
      _checkEstimate();
    }
  }

  void _checkEstimate() {
    if (isValid && erc20Token != null) {
      onStimateChanged?.call();
    }
  }

  @override
  String get subject => throw UnimplementedError();

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
      required APPEVMNetwork network,
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
      transactionData = ETHAbiConstant.erc20Transfer
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
      required APPEVMNetwork network,
      EthereumFee? fee,
      String? memo}) {
    ETHTransaction tr = ETHTransaction(
      from: address.networkAddress,
      chainId: network.coinParam.chainId,
      data: _getData(memo),
      nonce: 0,
      gasLimit: fee == null ? BigInt.zero : BigInt.from(fee.gasLimit),
      value: erc20Token != null ? BigInt.zero : amount.value!.balance,
      to: erc20Token?.contractAddress ?? destination.value!.networkAddress,
    );
    if (fee != null) {
      tr = tr.copyWith(
          type: fee.isEIP1559
              ? ETHTransactionType.eip1559
              : ETHTransactionType.legacy,
          gasPrice: fee.gasPrice,
          maxFeePerGas: fee.maxFeePerGas,
          maxPriorityFeePerGas: fee.maxPriorityFeePerGas);
    }
    return tr;
  }

  @override
  ETHTransactionMode get mode => erc20Token != null
      ? ETHTransactionMode.erc20Transfer
      : ETHTransactionMode.transfer;
}

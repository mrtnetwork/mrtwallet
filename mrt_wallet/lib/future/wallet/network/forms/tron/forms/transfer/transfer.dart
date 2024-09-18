import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronTransferForm extends TronTransactionForm {
  TronTransferForm(
      {required this.token,
      TronTRC20Token? trc20Token,
      TronTRC10Token? trc10Token})
      : _trc10Token = trc10Token,
        _trc20Token = trc20Token;
  @override
  BigInt get callValue =>
      isTrxTransfer ? (amount.value?.balance ?? BigInt.zero) : BigInt.zero;

  @override
  BigInt get tokenValue =>
      !isTrxTransfer ? (amount.value?.balance ?? BigInt.zero) : BigInt.zero;
  final Token token;
  final TronTRC20Token? _trc20Token;
  final TronTRC10Token? _trc10Token;

  TokenCore<BigInt>? get transferToken => _trc20Token ?? _trc10Token;

  final TransactionFormField<ReceiptAddress<TronAddress>> destination =
      TransactionFormField(
    name: "destination",
    optional: false,
    onChangeForm: (p0) {
      return p0;
    },
  );
  late final TransactionFormField<IntegerBalance> amount = TransactionFormField(
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
  late final String name = _trc10Token != null
      ? "transfer_trc10"
      : _trc20Token != null
          ? "transfer_trc20"
          : "transfer";

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
      _checkEstimate();
    }
  }

  void _checkEstimate() {
    if (validateError() == null) {
      onStimateChanged?.call();
    }
  }

  @override
  String? validateError({ITronAddress? account}) {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  late final bool isTrc20Transfer = _trc20Token != null;
  late final bool isTrxTransfer = _trc10Token == null && _trc20Token == null;
  @override
  late final TransactionContractType type = _trc20Token != null
      ? TransactionContractType.triggerSmartContract
      : _trc10Token != null
          ? TransactionContractType.transferAssetContract
          : TransactionContractType.transferContract;

  @override
  TronAddress? get destinationAccount {
    if (isTrc20Transfer) return null;
    return destination.value?.networkAddress;
  }

  @override
  TronBaseContract toContract({required ITronAddress owner}) {
    final validate = validateError(account: owner);
    if (validate != null) {
      throw WalletException(validate);
    }
    if (type == TransactionContractType.triggerSmartContract) {
      return TriggerSmartContract(
        ownerAddress: owner.networkAddress,
        contractAddress: _trc20Token!.contractAddress,
        data: SolidityContractUtils.erc20Transfer
            .encode([destination.value!.networkAddress, amount.value!.balance]),
      );
    } else if (type == TransactionContractType.transferAssetContract) {
      return TransferAssetContract(
          assetName: StringUtils.encode(_trc10Token!.tokenID),
          ownerAddress: owner.networkAddress,
          toAddress: destination.value!.networkAddress,
          amount: amount.value!.balance);
    }
    return TransferContract(
        ownerAddress: owner.networkAddress,
        toAddress: destination.value!.networkAddress,
        amount: amount.value!.balance);
  }

  @override
  TronAddress? get smartContractAddress => _trc20Token?.contractAddress;
  @override
  Future<void> init(
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account}) async {}
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/core/tron_field_validator.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/tron/trc10_token.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/tron/trc20_token.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

class TronTransferValidator extends TronTransactionValidator {
  TronTransferValidator(
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

  final ValidatorField<ReceiptAddress<TronAddress>> destination =
      ValidatorField(
    name: "destination",
    optional: false,
    onChangeValidator: (p0) {
      return p0;
    },
  );
  late final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
    name: "amount",
    optional: false,
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
  late final String name = _trc10Token != null
      ? "transfer_trc10"
      : _trc20Token != null
          ? "transfer_trc20"
          : "transfer";

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {
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
        data: ETHAbiConstant.erc20Transfer
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
      {required TVMApiProvider provider,
      required ITronAddress address,
      required NetworkAccountCore account}) async {}
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/tron/delegated_resouce_balance.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/core/tron_field_validator.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:on_chain/on_chain.dart';

class TronDelegatedResourceV2Validator extends TronTransactionValidator {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
    name: "delegatable_amount",
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
  final ValidatorField<ReceiptAddress<TronAddress>> destination =
      ValidatorField(
          name: "receiver_address",
          optional: false,
          onChangeValidator: (p0) {
            return p0;
          });
  late final ValidatorField<ResourceCode> resource = ValidatorField(
    name: "resource",
    optional: false,
    onChangeValidator: (v) {
      try {
        if (v == ResourceCode.tronPower) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final ValidatorField<bool> lock = ValidatorField(
    name: "lock",
    optional: true,
    onChangeValidator: (v) {
      return v;
    },
  );
  final ValidatorField<BigRational> lockPeriod = ValidatorField(
    name: "lock_period",
    onChangeValidator: (v) {
      try {
        if (v!.isNegative || v.isZero || v.isDecimal) return null;
        if (v > TronUtils.maxDelegatedLockPeriod) {
          return null;
        }
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  late final MaxDelegatedResourceAmount bandWidthResource;
  late final MaxDelegatedResourceAmount energy;

  MaxDelegatedResourceAmount get maxResourceBalance =>
      resource.value == ResourceCode.bandWidth ? bandWidthResource : energy;

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [amount, destination, resource];

  @override
  late final String name = "delegated_resource";

  void setLockPerid(bool? value) {
    if (lock.setValue(value ?? false)) {
      lockPeriod.setValue(TronUtils.defaultDelegateLockPeriod);
      onChanged?.call();
      _checkEstimate();
    }
  }

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

  @override
  late final TransactionContractType type =
      TransactionContractType.delegateResourceContract;

  @override
  TronAddress? get destinationAccount {
    return null;
  }

  @override
  TronBaseContract toContract({required ITronAddress owner}) {
    final validate = validateError(account: owner);
    if (validate != null) {
      throw WalletException(validate);
    }
    BigInt? lockTime;
    if (lock.value == true) {
      if (lockPeriod.value != null &&
          lockPeriod.value != TronUtils.defaultDelegateLockPeriod) {
        lockTime = lockPeriod.value?.toBigInt();
      }
    }
    return DelegateResourceContract(
        ownerAddress: owner.networkAddress,
        receiverAddress: destination.value!.networkAddress,
        balance: amount.value!.balance,
        resource: resource.value,
        lock: lock.value == true ? true : null,
        lockPeriod: lockTime);
  }

  @override
  TronAddress? get smartContractAddress => null;

  @override
  Future<void> init(
      {required TVMApiProvider provider,
      required ITronAddress address,
      required NetworkAccountCore account}) async {
    final delegated = await provider.getMaxDelegatedEnergyAndBandwidth(address);
    energy = delegated.$1;
    bandWidthResource = delegated.$2;
  }
}

import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronDelegatedResourceV2Form extends TronTransactionForm {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "delegatable_amount",
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
  final TransactionFormField<ReceiptAddress<TronAddress>> destination =
      TransactionFormField(
          name: "receiver_address",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  late final TransactionFormField<ResourceCode> resource = TransactionFormField(
    name: "resource",
    optional: false,
    onChangeForm: (v) {
      try {
        if (v == ResourceCode.tronPower) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );
  final TransactionFormField<bool> lock = TransactionFormField(
    name: "lock",
    optional: true,
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<BigRational> lockPeriod = TransactionFormField(
    name: "lock_period",
    onChangeForm: (v) {
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
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields => [amount, destination, resource];

  @override
  late final String name = "delegated_resource";

  void setLockPerid(bool? value) {
    if (lock.setValue(value ?? false)) {
      lockPeriod.setValue(TronUtils.defaultDelegateLockPeriod);
      onChanged?.call();
      _checkEstimate();
    }
  }

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
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account}) async {
    final delegated = await provider.getMaxDelegatedEnergyAndBandwidth(address);
    energy = delegated.$1;
    bandWidthResource = delegated.$2;
  }
}

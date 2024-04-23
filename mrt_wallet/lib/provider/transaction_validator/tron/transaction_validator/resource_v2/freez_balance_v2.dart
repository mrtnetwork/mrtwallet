import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/core/tron_field_validator.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:on_chain/on_chain.dart';

class TronFreezBalanceV2Validator extends TronTransactionValidator {
  @override
  BigInt get callValue => (amount.value?.balance ?? BigInt.zero);

  @override
  final BigInt tokenValue = BigInt.zero;

  late final ValidatorField<NoneDecimalBalance> amount = ValidatorField(
    name: "frozen_balance",
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

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [amount, resource];

  @override
  late final String name = "tron_stack_v2";

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
      TransactionContractType.freezeBalanceV2Contract;

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

    return FreezeBalanceV2Contract(
        ownerAddress: owner.networkAddress,
        frozenBalance: amount.value!.balance,
        resource: resource.value);
  }

  @override
  TronAddress? get smartContractAddress => null;

  @override
  Future<void> init(
      {required TVMApiProvider provider,
      required ITronAddress address,
      required NetworkAccountCore account}) async {}
}

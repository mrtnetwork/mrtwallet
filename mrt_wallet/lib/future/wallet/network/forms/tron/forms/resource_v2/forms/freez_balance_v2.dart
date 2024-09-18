import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronFreezBalanceV2Form extends TronTransactionForm {
  @override
  BigInt get callValue => (amount.value?.balance ?? BigInt.zero);

  @override
  final BigInt tokenValue = BigInt.zero;

  late final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "frozen_balance",
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

  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields => [amount, resource];

  @override
  late final String name = "tron_stack_v2";

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
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account}) async {}
}

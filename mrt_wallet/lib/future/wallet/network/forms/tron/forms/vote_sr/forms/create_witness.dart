import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronCreateWitnessForm extends TronTransactionForm {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  late final TransactionFormField<String> url = TransactionFormField(
    name: "url",
    optional: false,
    onChangeForm: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields => [url];

  @override
  late final String name = "create_witness";

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
      TransactionContractType.witnessCreateContract;

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

    return WitnessCreateContract(
        ownerAddress: owner.networkAddress,
        url: StringUtils.tryToBytes(url.value));
  }

  @override
  TronAddress? get smartContractAddress => null;

  @override
  Future<void> init(
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account}) async {}
}

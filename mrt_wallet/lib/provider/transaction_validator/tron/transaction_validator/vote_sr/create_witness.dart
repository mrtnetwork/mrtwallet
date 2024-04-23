import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/core/tron_field_validator.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:on_chain/on_chain.dart';

class TronCreateWitnessValidator extends TronTransactionValidator {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  late final ValidatorField<String> url = ValidatorField(
    name: "url",
    optional: false,
    onChangeValidator: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [url];

  @override
  late final String name = "create_witness";

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
      {required TVMApiProvider provider,
      required ITronAddress address,
      required NetworkAccountCore account}) async {}
}

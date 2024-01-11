import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/tron/account_delegated_resource_info.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/core/tron_field_validator.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:on_chain/on_chain.dart';

class TronUnDelegatedResourceV2Validator extends TronTransactionValidator {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  final ValidatorField<NoneDecimalBalance> balance = ValidatorField(
    name: "balance",
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
  final ValidatorField<ReceiptAddress<TronAddress>> destination =
      ValidatorField(
          id: "",
          name: "resource_receiver_address",
          optional: false,
          onChangeValidator: (p0) {
            return p0;
          },
          subject: "");

  void onChangeResource(ReceiptAddress<TronAddress>? resource) {
    if (resource == null) return;
    destination.setValue(resource);
    _fetchAccountDelegateInfo(destination.value!.networkAddress);
  }

  late final List<ReceiptAddress<TronAddress>> resourceAddresses;
  DelegatedAccountResourceInfo? _delegatedAccountResourceInfo;
  TVMApiProvider? _provider;
  DelegatedAccountResourceInfo? get resourceInf0 =>
      _delegatedAccountResourceInfo;
  bool _isLoading = false;
  bool get isLoadingResource => _isLoading;
  final Canclable _requestCancelable = Canclable();
  String? _inLoadingError;
  String? get inLoadingError => _inLoadingError;
  final Map<String, DelegatedAccountResourceInfo> _fetchedResource = {};

  Future<void> _fetchAccountDelegateInfo(TronAddress to) async {
    _requestCancelable.cancel();
    _inLoadingError = null;
    _delegatedAccountResourceInfo = null;
    _isLoading = true;
    _selectedResource = null;

    onChanged?.call(true);
    final result = await MethodCaller.call(() async {
      if (_fetchedResource.containsKey(to.toAddress())) {
        return _fetchedResource[to.toAddress()]!;
      }
      return await _provider!
          .getDelegatedResourceInfo(_address!.networkAddress, to);
    }, canclable: _requestCancelable);
    if (result.isCancel) return;
    if (result.hasError) {
      _inLoadingError = result.error!;
    } else {
      _fetchedResource[to.toAddress()] = result.result;
      _delegatedAccountResourceInfo = _fetchedResource[to.toAddress()];
    }
    _isLoading = false;
    onChanged?.call(false);
  }

  DelegateResourceDetailsCore? _selectedResource;
  DelegateResourceDetailsCore? get selectedResource => _selectedResource;
  void onSetResource(
      DelegateResourceDetailsCore? resource, DynamicVoid duringPeriodLock) {
    if (resource == null) return;
    if (!resource.canUnDelegated) {
      duringPeriodLock();
      return;
    }
    _selectedResource = resource;
    destination.setValue(resourceAddresses.firstWhere((element) =>
        element.networkAddress.toAddress() ==
        _selectedResource!.to.toAddress()));
    balance.setValue(selectedResource!.balance);
    onChanged?.call();
  }

  @override
  OnChangeValidator? onChanged;

  @override
  List<ValidatorField> get fields => [balance, destination];

  @override
  String get fieldsName => throw UnimplementedError();

  @override
  String get helperUri => throw UnimplementedError();

  @override
  bool get isValid => validateError() == null;

  @override
  late final String name = "undelegated_resource";

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
    if (isValid) {
      onStimateChanged?.call();
    }
  }

  @override
  String get subject => throw UnimplementedError();

  @override
  String? validateError({ITronAddress? account}) {
    if (_selectedResource == null) {
      return "undelegated_resource_validator_desc1".tr;
    }
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  @override
  late final TransactionContractType type =
      TransactionContractType.unDelegateResourceContract;

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
    return UnDelegateResourceContract(
        ownerAddress: owner.networkAddress,
        receiverAddress: destination.value!.networkAddress,
        balance: balance.value!.balance,
        resource: _selectedResource!.resource);
  }

  @override
  TronAddress? get smartContractAddress => null;
  ITronAddress? _address;
  @override
  Future<void> init(
      {required TVMApiProvider provider,
      required ITronAddress address,
      required NetworkAccountCore account}) async {
    _provider ??= provider;
    _address ??= address;
    final delegated = await _provider!.getDelegatedResourceAddresses(address);
    resourceAddresses = delegated
        .map((e) =>
            account.getReceiptAddress(e) as ReceiptAddress<TronAddress>? ??
            ReceiptAddress<TronAddress>(
                view: e, type: null, networkAddress: TronAddress(e)))
        .toList();
  }
}

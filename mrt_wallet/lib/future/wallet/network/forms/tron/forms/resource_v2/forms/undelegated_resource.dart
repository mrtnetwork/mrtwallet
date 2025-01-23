import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronUnDelegatedResourceV2Form extends TronTransactionForm {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  List<ReceiptAddress<TronAddress>> _resourceAddresses = [];
  List<ReceiptAddress<TronAddress>> get resourceAddresses => _resourceAddresses;
  DelegatedAccountResourceInfo? _delegatedAccountResourceInfo;
  TronClient? _provider;
  DelegatedAccountResourceInfo? get resourceInf0 =>
      _delegatedAccountResourceInfo;
  bool _isLoading = false;
  bool get isLoadingResource => _isLoading;
  final Cancelable _requestCancelable = Cancelable();
  String? _inLoadingError;
  String? get inLoadingError => _inLoadingError;
  final Map<TronAddress, DelegatedAccountResourceInfo> _fetchedResource = {};

  DelegateResourceDetailsCore? _selectedResource;
  DelegateResourceDetailsCore? get selectedResource => _selectedResource;

  @override
  TronAddress? get smartContractAddress => null;
  ITronAddress? _address;

  List<TransactionFormField> get fields => [balance, destination];

  @override
  late final String name = "undelegated_resource";

  final TransactionFormField<IntegerBalance> balance = TransactionFormField(
    name: "balance",
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
          name: "resource_receiver_address",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  void onChangeResource(ReceiptAddress<TronAddress>? resource) {
    if (resource == null) return;
    destination.setValue(resource);
    _fetchAccountDelegateInfo(destination.value!.networkAddress);
  }

  Future<void> _fetchAccountDelegateInfo(TronAddress to) async {
    _requestCancelable.cancel();
    _inLoadingError = null;
    _delegatedAccountResourceInfo = null;
    _isLoading = true;
    _selectedResource = null;

    onChanged?.call();
    final result = await MethodUtils.call(() async {
      if (_fetchedResource.containsKey(to)) {
        return _fetchedResource[to]!;
      }
      return await _provider!
          .getDelegatedResourceInfo(_address!.networkAddress, to);
    }, cancelable: _requestCancelable);
    if (result.isCancel) return;
    if (result.hasError) {
      _inLoadingError = result.error!;
    } else {
      _fetchedResource[to] = result.result;
      _delegatedAccountResourceInfo = _fetchedResource[to];
    }
    _isLoading = false;
    onChanged?.call();
  }

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
  Future<void> init(
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account}) async {
    _provider = provider;
    _address = address;
    final delegated = await _provider!.getDelegatedResourceAddresses(address);
    _resourceAddresses = delegated
        .map((e) =>
            account.getReceiptAddress(e) ??
            ReceiptAddress<TronAddress>(
                view: e, type: null, networkAddress: TronAddress(e)))
        .toList();
  }

  @override
  void close() {
    _requestCancelable.cancel();
    _resourceAddresses = [];
    _provider = null;
    _address = null;
    _fetchedResource.clear();
    _selectedResource = null;
    _inLoadingError = null;
    _isLoading = false;
    _delegatedAccountResourceInfo = null;
    balance.clear();
    destination.clear();
    super.close();
  }
}

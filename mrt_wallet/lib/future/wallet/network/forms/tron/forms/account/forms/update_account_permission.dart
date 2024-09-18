import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronAccountUpdatePermissionForm extends TronTransactionForm {
  TronAccountUpdatePermissionForm({required this.permissions});

  static const List<int> disabledOperation = [51, 52, 53];
  @override
  final BigInt callValue = BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  final List<AccountPermission> permissions;

  // ignore: unused_field
  late final List<AccountPermission> _orginalPermissions =
      List.unmodifiable(permissions.map((e) => e.clone()).toList());

  List<TransactionContractType>? _operations;
  List<TransactionContractType>? get operations => _operations;
  bool get allOperationSelected =>
      (_operations?.length ?? 0) ==
      TransactionContractType.values.length - disabledOperation.length;

  void clearOrSelectAll() {
    if (_operations == null) return;
    if (allOperationSelected) {
      _operations!.clear();
    } else {
      _operations = TransactionContractType.values
          .where((element) => !disabledOperation.contains(element.value))
          .map((e) => e)
          .toList();
    }
    _onChangeForm();
  }

  AccountPermission? _selectedPermission;
  int? permissionId;
  AccountPermission? get selectedPermission => _selectedPermission;

  String? _permissionError;

  String? get permissionError => _permissionError;
  void _onChangeForm() {
    onChanged?.call(_selectedPermission == null);
    if (_selectedPermission == null) {
      onStimateChanged?.call();
    }
  }

  void updatePermissionName(String? name) {
    _selectedPermission = _selectedPermission?.copyWith(permissionName: name);
    _onChangeForm();
  }

  AccountPermission _newActivePermission() {
    final List<int> ids = permissions
        .where((element) => element.operations != null)
        .map((e) => e.id)
        .toList()
        .cast();
    int nextId = StrUtils.findFirstMissingNumber(ids, start: 2);
    return AccountPermission(
        keys: [],
        threshold: BigInt.one,
        id: nextId,
        type: PermissionType.active,
        operations: TronUtils.defaultActivePermissionOperation,
        permissionName: "Active permission $nextId");
  }

  void setPermission(int? id, DynamicVoid onRequiredSavePermission) {
    if (id == null) return;
    if (_selectedPermission != null) {
      onRequiredSavePermission();
      _onChangeForm();
      return;
    }
    _permissionError = null;

    if (id == -1) {
      final newPermision = _newActivePermission();
      permissions.add(newPermision);
      id = newPermision.id;
    }
    permissionId = id;
    _selectedPermission = permissions.firstWhere(
        (element) => element.id == (permissionId == 0 ? null : permissionId));
    if (_selectedPermission!.operations == null) {
      _operations = null;
    } else {
      _operations = TronHelper.decodePermissionOperation(
          _selectedPermission!.operations!);
    }
    onChanged?.call(true);
  }

  void addOrRemoveOperation(
      TransactionContractType operation, DynamicVoid onDisabled) {
    if (disabledOperation.contains(operation.value)) {
      onDisabled();
      return;
    }
    _permissionError = null;
    if (!operations!.remove(operation)) {
      operations!.add(operation);
    }
    _onChangeForm();
  }

  void onUpdateTheresHold(int v) {
    final threshHold = BigInt.from(v);
    if (_selectedPermission?.threshold == threshHold) {
      return;
    }
    _permissionError = null;
    _selectedPermission = _selectedPermission?.copyWith(threshold: threshHold);
  }

  void addNewSigner(
      ReceiptAddress<TronAddress>? addr, DynamicVoid onExistAccount) {
    if (addr == null) return;
    _permissionError = null;
    final exist = MethodUtils.nullOnException(() => selectedPermission!.keys
        .firstWhere((element) =>
            element.address.toAddress() == addr.networkAddress.toAddress()));
    if (exist != null) {
      onExistAccount();
      return;
    }
    _selectedPermission = _selectedPermission?.copyWith(keys: [
      ..._selectedPermission!.keys,
      PermissionKeys(address: addr.networkAddress, weight: BigInt.one)
    ]);
    _onChangeForm();
  }

  void removeSigner(PermissionKeys? key) {
    if (key == null) return;
    _permissionError = null;
    final keys = selectedPermission!.keys
      ..removeWhere(
          (element) => element.address.toAddress() == key.address.toAddress());
    _selectedPermission = selectedPermission?.copyWith(keys: keys);
    _onChangeForm();
  }

  void updateKeyThereshHold(PermissionKeys? key, int v) {
    if (key == null) return;
    final weight = BigInt.from(v);
    _permissionError = null;
    if (key.weight == weight) return;
    final keyIndex = selectedPermission!.keys.indexWhere(
        (element) => element.address.toAddress() == key.address.toAddress());
    selectedPermission!.keys[keyIndex] =
        PermissionKeys(address: key.address, weight: weight);

    _onChangeForm();
  }

  String? _validatePermission() {
    if (_selectedPermission == null) return null;
    if (_selectedPermission!.keys.length > TronUtils.maxPermissionKeyLength) {
      return "tron_signer_validator_desc";
    }
    if (_selectedPermission!.isWitnessPermission &&
        _selectedPermission!.keys.length >
            TronUtils.maxWitnessPermissionKeyLength) {
      return "tron_signer_validator_witness_desc";
    }
    final sum = _selectedPermission!.keys.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.weight);
    if (sum < _selectedPermission!.threshold) {
      return "tron_permission_threshhold_validator";
    }
    return null;
  }

  void savePermission() {
    try {
      if (_selectedPermission == null) return;
      _permissionError = _validatePermission();
      if (_permissionError != null) return;
      final permissionIndex = permissions
          .indexWhere((element) => element.id == _selectedPermission!.id);
      final String? operations = BytesUtils.tryToHexString(_operations == null
          ? null
          : TronHelper.encodePermissionOperations(_operations!));
      permissions[permissionIndex] =
          _selectedPermission!.copyWith(operations: operations);
      _selectedPermission = null;
      permissionId = null;
      _operations = null;
    } finally {
      _onChangeForm();
    }
  }

  void removePermission() {
    if (!(_selectedPermission?.isActivePermission ?? false)) return;
    permissions.removeWhere((element) => element.id == _selectedPermission?.id);
    _selectedPermission = null;
    permissionId = null;
    _onChangeForm();
  }

  @override
  OnChangeForm? onChanged;

  List<TransactionFormField> get fields => [];

  @override
  late final String name = "update_account_permission";

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
    if (_selectedPermission != null) {
      return "permission_is_being_edited".tr;
    }
    final activates =
        permissions.where((element) => element.type == PermissionType.active);
    if (activates.isEmpty || activates.length > 8) {
      return "tron_mutlisig_active_length_validator".tr;
    }
    return null;
  }

  @override
  final TransactionContractType type =
      TransactionContractType.accountPermissionUpdateContract;

  @override
  final TronAddress? destinationAccount = null;

  @override
  TronBaseContract toContract({required ITronAddress owner}) {
    final validate = validateError(account: owner);
    if (validate != null) {
      throw WalletException(validate);
    }
    final witnessPermission = MethodUtils.nullOnException(() => permissions
        .firstWhere((element) => element.type == PermissionType.witness));
    final ownerPermission = permissions
        .firstWhere((element) => element.type == PermissionType.owner);
    final activates = permissions
        .where((element) => element.type == PermissionType.active)
        .map((e) => e.toPermission())
        .toList();
    return AccountPermissionUpdateContract(
        ownerAddress: owner.networkAddress,
        owner: ownerPermission.toPermission(),
        actives: activates,
        witness: witnessPermission?.toPermission());
  }

  @override
  final TronAddress? smartContractAddress = null;

  @override
  Future<void> init(
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account}) async {}
}

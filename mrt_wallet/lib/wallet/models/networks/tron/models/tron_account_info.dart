import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/tron/tron.dart';

class _TronAccountCborConst {
  static const List<int> tronAccountResource = [200, 195, 100, 1];
  static const List<int> frozenAssetsNetUsage = [200, 195, 100, 2];
  static const List<int> assetVersion2 = [200, 195, 100, 3];
  static const List<int> assetUnfreezV2 = [200, 195, 100, 4];
  static const List<int> assetFrozenV2 = [200, 195, 100, 5];
  static const List<int> frozenSupply = [200, 195, 100, 6];
  static const List<int> permissionKeys = [200, 195, 100, 7];
  static const List<int> accountPermission = [200, 195, 100, 8];
}

class TronAccountInfo with CborSerializable {
  final String? accountName;
  final String address;
  final BigInt balance;
  final BigInt createTime;
  final BigInt? latestOperationTime;
  final List<FrozenSupply> frozenSupply;
  final String? assetIssuedName;
  final int? freeNetUsage;
  final BigInt? latestConsumeFreeTime;
  final int netWindowSize;
  final bool netWindowOptimized;
  final TronAccountResource accountResource;
  final AccountPermission ownerPermission;

  List<AccountPermission> get permissions => [
        ownerPermission,
        ...activePermissions,
        if (witnessPermission != null) witnessPermission!
      ];

  factory TronAccountInfo.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tronAccountInfo);

    final witness = cbor.elementAt(14);
    return TronAccountInfo._(
        accountName: cbor.elementAt(0),
        address: cbor.elementAt(1),
        balance: cbor.elementAt(2),
        createTime: cbor.elementAt(3),
        latestOperationTime: cbor.elementAt(4),
        frozenSupply: (cbor.elementAt(5) as List)
            .map((e) => FrozenSupply.fromCborBytesOrObject(obj: e))
            .toList(),
        assetIssuedName: cbor.elementAt(6),
        freeNetUsage: cbor.elementAt(7),
        latestConsumeFreeTime: cbor.elementAt(8),
        netWindowSize: cbor.elementAt(9),
        netWindowOptimized: cbor.elementAt(10),
        accountResource:
            TronAccountResource.fromCborBytesOrObject(obj: cbor.getCborTag(11)),
        ownerPermission:
            AccountPermission.fromCborBytesOrObject(obj: cbor.getCborTag(12)),
        activePermissions: (cbor.elementAt(13) as List)
            .map((e) => AccountPermission.fromCborBytesOrObject(obj: e))
            .toList(),
        witnessPermission: witness == null
            ? null
            : AccountPermission.fromCborBytesOrObject(obj: cbor.getCborTag(14)),
        frozenV2: (cbor.elementAt(15) as List)
            .map((e) => FrozenV2.fromCborBytesOrObject(obj: e))
            .toList(),
        unfrozenV2: (cbor.elementAt(16) as List)
            .map((e) => UnfrozenV2.fromCborBytesOrObject(obj: e))
            .toList(),
        assetV2: (cbor.elementAt(17) as List)
            .map((e) => AssetV2.fromCborBytesOrObject(obj: e))
            .toList(),
        assetIssuedID: cbor.elementAt(18),
        freeAssetNetUsageV2: (cbor.elementAt(19) as List)
            .map((e) => FreeAssetNetUsageV2.fromCborBytesOrObject(obj: e))
            .toList(),
        assetOptimized: cbor.elementAt(20));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          accountName,
          address,
          balance,
          createTime,
          latestOperationTime,
          CborListValue.fixedLength(
              frozenSupply.map((e) => e.toCbor()).toList()),
          assetIssuedName,
          freeNetUsage,
          latestConsumeFreeTime,
          netWindowSize,
          netWindowOptimized,
          accountResource.toCbor(),
          ownerPermission.toCbor(),
          CborListValue.fixedLength(
              activePermissions.map((e) => e.toCbor()).toList()),
          witnessPermission?.toCbor(),
          CborListValue.fixedLength(frozenV2.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(unfrozenV2.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(assetV2.map((e) => e.toCbor()).toList()),
          assetIssuedID,
          CborListValue.fixedLength(
              freeAssetNetUsageV2.map((e) => e.toCbor()).toList()),
          assetOptimized
        ]),
        CborTagsConst.tronAccountInfo);
  }

  final List<AccountPermission> activePermissions;
  final AccountPermission? witnessPermission;
  final List<FrozenV2> frozenV2;
  final List<UnfrozenV2> unfrozenV2;
  final List<AssetV2> assetV2;
  final String? assetIssuedID;
  final List<FreeAssetNetUsageV2> freeAssetNetUsageV2;
  final bool assetOptimized;

  const TronAccountInfo._({
    this.accountName,
    required this.address,
    required this.balance,
    required this.createTime,
    required this.latestOperationTime,
    required this.frozenSupply,
    required this.assetIssuedName,
    required this.freeNetUsage,
    required this.latestConsumeFreeTime,
    required this.netWindowSize,
    required this.netWindowOptimized,
    required this.accountResource,
    required this.ownerPermission,
    required this.activePermissions,
    required this.witnessPermission,
    required this.frozenV2,
    required this.unfrozenV2,
    required this.assetV2,
    required this.assetIssuedID,
    required this.freeAssetNetUsageV2,
    required this.assetOptimized,
  });

  factory TronAccountInfo.fromJson(Map<String, dynamic> json) {
    return TronAccountInfo._(
      accountName: json['account_name'],
      address: json['address'],
      balance: BigintUtils.parse(json['balance'] ?? BigInt.zero),
      createTime: BigintUtils.parse(json['create_time']),
      latestOperationTime: BigintUtils.tryParse(json['latest_opration_time']),
      frozenSupply: (json['frozen_supply'] as List?)
              ?.map((supply) => FrozenSupply.fromJson(supply))
              .toList() ??
          <FrozenSupply>[],
      assetIssuedName: json['asset_issued_name'],
      freeNetUsage: json['free_net_usage'],
      latestConsumeFreeTime:
          BigintUtils.tryParse(json['latest_consume_free_time']),
      netWindowSize: json['net_window_size'],
      netWindowOptimized: json['net_window_optimized'],
      accountResource: TronAccountResource.fromJson(json['account_resource']),
      ownerPermission: AccountPermission.fromJson(json['owner_permission']),
      activePermissions: (json['active_permission'] as List<dynamic>)
          .map((permission) => AccountPermission.fromJson(permission))
          .toList(),
      witnessPermission: json["witness_permission"] == null
          ? null
          : AccountPermission.fromJson(json['witness_permission']),
      frozenV2: (json['frozenV2'] as List<dynamic>)
          .map((frozen) => FrozenV2.fromJson(frozen))
          .toList(),
      unfrozenV2: (json['unfrozenV2'] as List?)
              ?.map((unfrozen) => UnfrozenV2.fromJson(unfrozen))
              .toList() ??
          <UnfrozenV2>[],
      assetV2: (json['assetV2'] as List?)
              ?.map((asset) => AssetV2.fromJson(asset))
              .toList() ??
          <AssetV2>[],
      assetIssuedID: json['asset_issued_ID'],
      freeAssetNetUsageV2: (json['free_asset_net_usageV2'] as List?)
              ?.map((usage) => FreeAssetNetUsageV2.fromJson(usage))
              .toList() ??
          <FreeAssetNetUsageV2>[],
      assetOptimized: json['asset_optimized'],
    );
  }

  @override
  String toString() {
    return '''
      TronAccount {
        accountName: $accountName,
        address: $address,
        balance: $balance,
        createTime: $createTime,
        latestOperationTime: $latestOperationTime,
        frozenSupply: $frozenSupply,
        assetIssuedName: $assetIssuedName,
        freeNetUsage: $freeNetUsage,
        latestConsumeFreeTime: $latestConsumeFreeTime,
        netWindowSize: $netWindowSize,
        netWindowOptimized: $netWindowOptimized,
        accountResource: $accountResource,
        ownerPermission: $ownerPermission,
        activePermissions: $activePermissions,
        frozenV2: $frozenV2,
        unfrozenV2: $unfrozenV2,
        assetV2: $assetV2,
        assetIssuedID: $assetIssuedID,
        freeAssetNetUsageV2: $freeAssetNetUsageV2,
        assetOptimized: $assetOptimized
      }
    ''';
  }
}

class AccountPermission with CborSerializable {
  final PermissionType type;
  final int? id;
  final String? permissionName;
  final BigInt threshold;
  final String? operations;
  final List<PermissionKeys> keys;
  bool get isActivePermission => type == PermissionType.active;
  bool get isWitnessPermission => type == PermissionType.witness;
  bool get isOwner => type == PermissionType.owner;
  Permission toPermission() {
    return Permission(
        id: id,
        keys: keys
            .map((e) => TronKey(address: e.address, weight: e.weight))
            .toList(),
        operations: BytesUtils.tryFromHexString(operations),
        type: type,
        permissionName: permissionName,
        threshold: threshold);
  }

  AccountPermission clone() {
    return AccountPermission(
        type: type,
        permissionName: permissionName,
        threshold: threshold,
        id: id,
        operations: operations,
        keys: keys.map((e) => e.clone()).toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          type.name,
          id,
          permissionName,
          threshold,
          operations,
          CborListValue.fixedLength(keys.map((e) => e.toCbor()).toList())
        ]),
        _TronAccountCborConst.accountPermission);
  }

  factory AccountPermission.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.accountPermission);
    final keys = (cbor.elementAt(5) as List)
        .map((e) => PermissionKeys.fromCborBytesOrObject(obj: e))
        .toList();
    return AccountPermission(
        type: PermissionType.fromName(cbor.elementAt(0),
            defaultPermission: PermissionType.owner),
        id: cbor.elementAt(1),
        permissionName: cbor.elementAt(2),
        threshold: cbor.elementAt(3),
        operations: cbor.elementAt(4),
        keys: keys);
  }

  AccountPermission({
    required this.type,
    this.id,
    required this.permissionName,
    required this.threshold,
    this.operations,
    required this.keys,
  });

  factory AccountPermission.fromJson(Map<String, dynamic> json) {
    return AccountPermission(
      type: PermissionType.fromName(json["type"],
          defaultPermission: PermissionType.owner),
      id: json['id'],
      permissionName: json['permission_name'],
      threshold: BigintUtils.parse(json['threshold']),
      operations: json['operations'],
      keys: (json['keys'] as List?)
              ?.map((e) => PermissionKeys.fromJson(e))
              .toList() ??
          <PermissionKeys>[],
    );
  }

  @override
  String toString() {
    return '''
      ActivePermission {
        type: $type,
        id: $id,
        permissionName: $permissionName,
        threshold: $threshold,
        operations: $operations,
        keys: $keys
      }
    ''';
  }

  // CopyWith method for immutable updates
  AccountPermission copyWith({
    PermissionType? type,
    int? id,
    String? permissionName,
    BigInt? threshold,
    String? operations,
    List<PermissionKeys>? keys,
  }) {
    return AccountPermission(
      type: type ?? this.type,
      id: id ?? this.id,
      permissionName: permissionName ?? this.permissionName,
      threshold: threshold ?? this.threshold,
      operations: operations ?? this.operations,
      keys: keys ?? this.keys,
    );
  }
}

class PermissionKeys with CborSerializable, Equatable {
  PermissionKeys({required this.address, required this.weight});
  factory PermissionKeys.fromJson(Map<String, dynamic> json) {
    return PermissionKeys(
        address: TronAddress(json["address"]),
        weight: BigintUtils.parse(json["weight"]));
  }
  final TronAddress address;
  final BigInt weight;
  PermissionKeys clone() {
    return PermissionKeys(address: address, weight: weight);
  }

  @override
  String toString() {
    return 'PermissionKeys(address: $address, weight: $weight)';
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address.toAddress(), weight]),
        _TronAccountCborConst.permissionKeys);
  }

  factory PermissionKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.permissionKeys);
    return PermissionKeys(
        address: TronAddress(cbor.elementAt(0)), weight: cbor.elementAt(1));
  }

  @override
  List get variabels => [address.toAddress(), weight];
}

class FrozenSupply with CborSerializable {
  final BigInt frozenBalance;
  final BigInt expireTime;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([frozenBalance, expireTime]),
        _TronAccountCborConst.frozenSupply);
  }

  factory FrozenSupply.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.frozenSupply);
    return FrozenSupply._(
        frozenBalance: cbor.elementAt(0), expireTime: cbor.elementAt(1));
  }

  FrozenSupply._({
    required this.frozenBalance,
    required this.expireTime,
  });

  factory FrozenSupply.fromJson(Map<String, dynamic> json) {
    return FrozenSupply._(
      frozenBalance: BigInt.from(json['frozen_balance']),
      expireTime: BigInt.from(json['expire_time']),
    );
  }

  @override
  String toString() {
    return '''
      FrozenSupply {
        frozenBalance: $frozenBalance,
        expireTime: $expireTime
      }
    ''';
  }
}

class FrozenV2 with CborSerializable {
  final BigInt amount;
  final ResourceCode type;
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([amount, type.name]),
        _TronAccountCborConst.assetFrozenV2);
  }

  factory FrozenV2.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.assetFrozenV2);
    return FrozenV2._(
        type: ResourceCode.fromName(cbor.elementAt(1))!,
        amount: cbor.elementAt(0));
  }

  FrozenV2._({
    required this.amount,
    required this.type,
  });

  factory FrozenV2.fromJson(Map<String, dynamic> json) {
    return FrozenV2._(
      amount: BigintUtils.tryParse(json["amount"]) ?? BigInt.zero,
      type:
          ResourceCode.fromName(json['type'], orElse: ResourceCode.bandWidth)!,
    );
  }

  @override
  String toString() {
    return '''
      FrozenV2 {
        amount: $amount,
        type: $type
      }
    ''';
  }
}

class UnfrozenV2 with CborSerializable {
  final String? type;
  final BigInt unfreezeAmount;
  final BigInt unfreezeExpireTime;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          type,
          unfreezeAmount,
          unfreezeExpireTime,
        ]),
        _TronAccountCborConst.assetUnfreezV2);
  }

  factory UnfrozenV2.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.assetUnfreezV2);
    return UnfrozenV2._(
        type: cbor.elementAt(0),
        unfreezeAmount: cbor.elementAt(1),
        unfreezeExpireTime: cbor.elementAt(2));
  }

  UnfrozenV2._({
    required this.type,
    required this.unfreezeAmount,
    required this.unfreezeExpireTime,
  });

  factory UnfrozenV2.fromJson(Map<String, dynamic> json) {
    return UnfrozenV2._(
      type: json['type'],
      unfreezeAmount: BigintUtils.parse(json['unfreeze_amount']),
      unfreezeExpireTime: BigintUtils.parse(json['unfreeze_expire_time']),
    );
  }

  @override
  String toString() {
    return '''
      UnfrozenV2 {
        type: $type,
        unfreezeAmount: $unfreezeAmount,
        unfreezeExpireTime: $unfreezeExpireTime
      }
    ''';
  }
}

class AssetV2 with CborSerializable {
  final String key;
  final BigInt value;

  AssetV2._({
    required this.key,
    required this.value,
  });
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          key,
          value,
        ]),
        _TronAccountCborConst.assetVersion2);
  }

  factory AssetV2.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.assetVersion2);
    return AssetV2._(key: cbor.elementAt(0), value: cbor.elementAt(1));
  }

  factory AssetV2.fromJson(Map<String, dynamic> json) {
    return AssetV2._(
      key: json['key'],
      value: BigintUtils.parse(json["value"]),
    );
  }

  @override
  String toString() {
    return '''
      AssetV2 {
        key: $key,
        value: $value
      }
    ''';
  }
}

class FreeAssetNetUsageV2 with CborSerializable {
  final String key;
  final BigInt value;

  FreeAssetNetUsageV2._({
    required this.key,
    required this.value,
  });
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          key,
          value,
        ]),
        _TronAccountCborConst.frozenAssetsNetUsage);
  }

  factory FreeAssetNetUsageV2.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.frozenAssetsNetUsage);
    return FreeAssetNetUsageV2._(
        key: cbor.elementAt(0), value: cbor.elementAt(1));
  }

  factory FreeAssetNetUsageV2.fromJson(Map<String, dynamic> json) {
    return FreeAssetNetUsageV2._(
      key: json['key'],
      value: BigintUtils.parse(json['value']),
    );
  }

  @override
  String toString() {
    return '''
      FreeAssetNetUsageV2 {
        key: $key,
        value: $value
      }
    ''';
  }
}

class TronAccountResource with CborSerializable {
  final int energyWindowSize;
  final BigInt? delegatedFrozenV2BalanceForEnergy;
  final bool energyWindowOptimized;

  TronAccountResource._({
    required this.energyWindowSize,
    required this.delegatedFrozenV2BalanceForEnergy,
    required this.energyWindowOptimized,
  });

  factory TronAccountResource.fromJson(Map<String, dynamic> json) {
    return TronAccountResource._(
      energyWindowSize: json['energy_window_size'],
      delegatedFrozenV2BalanceForEnergy:
          BigintUtils.tryParse(json['delegated_frozenV2_balance_for_energy']),
      energyWindowOptimized: json['energy_window_optimized'],
    );
  }

  @override
  String toString() {
    return '''
      TronAccountResource {
        energyWindowSize: $energyWindowSize,
        delegatedFrozenV2BalanceForEnergy: $delegatedFrozenV2BalanceForEnergy,
        energyWindowOptimized: $energyWindowOptimized
      }
    ''';
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          energyWindowSize,
          delegatedFrozenV2BalanceForEnergy,
          energyWindowOptimized
        ]),
        _TronAccountCborConst.tronAccountResource);
  }

  factory TronAccountResource.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, _TronAccountCborConst.tronAccountResource);
    return TronAccountResource._(
        energyWindowSize: cbor.elementAt(0),
        delegatedFrozenV2BalanceForEnergy: cbor.elementAt(1),
        energyWindowOptimized: cbor.elementAt(2));
  }
}

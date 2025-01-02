import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:on_chain/on_chain.dart';
import 'utxos.dart';
import 'utxo_asset.dart';

/// Represents a collection of multiple assets associated with policy IDs.
class UtxoMultiAsset implements Comparable<UtxoMultiAsset> {
  static final UtxoMultiAsset empty = UtxoMultiAsset({});

  /// Map of policy IDs to assets.
  final Map<PolicyID, UtxoAssets> assets;
  UtxoMultiAsset._(Map<PolicyID, UtxoAssets> assets)
      : assets = Map<PolicyID, UtxoAssets>.unmodifiable(assets);

  late final int totalAssets = assets.values.fold(
      0, (previousValue, element) => previousValue + element.assets.length);

  /// Constructs an instance of UtxoMultiAsset.
  factory UtxoMultiAsset(Map<PolicyID, UtxoAssets> assets) {
    final keys = assets.keys.toList()..sort();
    return UtxoMultiAsset._({for (final i in keys) i: assets[i]!});
  }

  UtxoMultiAsset copyWith({Map<PolicyID, UtxoAssets>? assets}) {
    return UtxoMultiAsset(assets ?? this.assets);
  }

  UtxoMultiAsset operator +(UtxoMultiAsset other) {
    final currentAssets = Map<PolicyID, UtxoAssets>.from(assets);
    for (final i in other.assets.entries) {
      if (currentAssets.containsKey(i.key)) {
        currentAssets[i.key] = currentAssets[i.key]! + i.value;
      } else {
        currentAssets[i.key] = i.value;
      }
    }
    return UtxoMultiAsset(currentAssets);
  }

  factory UtxoMultiAsset.fromUtxo(ADAAccountUTXOs utxo) {
    final Map<PolicyID, UtxoAssets> assets = {};
    for (final i in utxo.amount) {
      if (i.islovelace) continue;
      final assetInfo = i.policyAndAssetName!;
      final asset = UtxoAssets({
        assetInfo.item2:
            IntegerBalance(BigInt.parse(i.quantity), i.decimals ?? 0)
      });
      if (assets.containsKey(assetInfo.item1)) {
        assets[assetInfo.item1] = assets[assetInfo.item1]! + asset;
      } else {
        assets[assetInfo.item1] = asset;
      }
    }
    return UtxoMultiAsset(assets);
  }

  UtxoMultiAsset operator -(UtxoMultiAsset other) {
    final currentAssets = Map<PolicyID, UtxoAssets>.from(assets);
    for (final i in other.assets.entries) {
      if (!currentAssets.containsKey(i.key)) {
        continue;
      }
      final val = currentAssets[i.key]! - i.value;
      if (val.assets.isEmpty) {
        currentAssets.remove(i.key);
      } else {
        currentAssets[i.key] = val;
      }
    }
    return UtxoMultiAsset(currentAssets);
  }

  BigInt _amount(UtxoMultiAsset ma, PolicyID pid, AssetName aname) {
    final BigInt? amount = ma.assets[pid]?.assets[aname]?.balance;
    return amount ?? BigInt.zero;
  }

  bool _compare(UtxoMultiAsset lhs, UtxoMultiAsset rhs) {
    for (final entry in lhs.assets.entries) {
      final PolicyID pid = entry.key;
      final UtxoAssets assets = entry.value;
      for (final assetEntry in assets.assets.entries) {
        final AssetName aname = assetEntry.key;
        final BigInt amount = assetEntry.value.balance;
        final BigInt rhsAmount = _amount(rhs, pid, aname);
        if (amount - rhsAmount > BigInt.zero) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  int compareTo(UtxoMultiAsset other) {
    if (_compare(this, other) && _compare(other, this)) {
      return 0;
    } else if (_compare(this, other)) {
      return -1;
    } else if (_compare(other, this)) {
      return 1;
    } else {
      return 0;
    }
  }

  bool get hasAsset => assets.isNotEmpty;

  MultiAsset toMultiAsset() {
    return MultiAsset(
        {for (final i in assets.entries) i.key: i.value.toAssets()});
  }

  @override
  bool operator ==(other) {
    if (other is! UtxoMultiAsset) return false;
    if (other.assets.length != assets.length) return false;
    for (final i in other.assets.entries) {
      if (other.assets[i.key] != assets[i.key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => assets.entries.fold(
      mask32,
      (previousValue, element) =>
          previousValue ^ (element.key.hashCode ^ element.value.hashCode));

  @override
  String toString() {
    return "UtxoMultiAsset{$assets}";
  }
}

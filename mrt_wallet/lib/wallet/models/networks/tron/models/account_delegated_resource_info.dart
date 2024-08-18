import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:on_chain/tron/tron.dart';

class DelegatedAccountResourceInfo {
  const DelegatedAccountResourceInfo._(this.energy, this.bandwidth);
  final DelegatedEnergyDetails? energy;
  final DelegatedBandwidthDetails? bandwidth;
  factory DelegatedAccountResourceInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty ||
        ((json["delegatedResource"] as List?)?.isEmpty ?? true)) {
      return const DelegatedAccountResourceInfo._(null, null);
    }
    DelegatedEnergyDetails? energy;
    DelegatedBandwidthDetails? bandwidth;

    final resource = Map<String, dynamic>.from(json["delegatedResource"][0]);
    if (resource.containsKey("frozen_balance_for_energy")) {
      energy = DelegatedEnergyDetails.fromJson(resource);
    }
    if (resource.containsKey("frozen_balance_for_bandwidth")) {
      bandwidth = DelegatedBandwidthDetails.fromJson(resource);
    }
    return DelegatedAccountResourceInfo._(energy, bandwidth);
  }

  bool get canUndelegated =>
      (energy?.canUnDelegated ?? false) || (bandwidth?.canUnDelegated ?? false);
}

abstract class DelegateResourceDetailsCore {
  abstract final ResourceCode resource;
  abstract final TronAddress to;
  bool get canUnDelegated;
  abstract final IntegerBalance balance;
}

class DelegatedEnergyDetails implements DelegateResourceDetailsCore {
  const DelegatedEnergyDetails._(this.to, this.balance, this.expire);
  @override
  final TronAddress to;
  @override
  final IntegerBalance balance;
  final DateTime? expire;
  @override
  bool get canUnDelegated => expire == null || expire!.isBefore(DateTime.now());
  factory DelegatedEnergyDetails.fromJson(Map<String, dynamic> json) {
    DateTime? expire;
    if (json.containsKey("expire_time_for_energy")) {
      expire = DateTime.fromMillisecondsSinceEpoch(
              IntUtils.parse(json["expire_time_for_energy"]))
          .toLocal();
    }
    return DelegatedEnergyDetails._(
        TronAddress(json["to"]),
        IntegerBalance(BigintUtils.parse(json["frozen_balance_for_energy"]),
            TronUtils.decimal),
        expire);
  }

  @override
  ResourceCode get resource => ResourceCode.energy;
}

class DelegatedBandwidthDetails implements DelegateResourceDetailsCore {
  const DelegatedBandwidthDetails._(this.to, this.balance, this.expire);
  @override
  final TronAddress to;
  @override
  final IntegerBalance balance;
  final DateTime? expire;
  @override
  bool get canUnDelegated => expire == null || expire!.isBefore(DateTime.now());
  factory DelegatedBandwidthDetails.fromJson(Map<String, dynamic> json) {
    DateTime? expire;
    if (json.containsKey("expire_time_for_bandwidth")) {
      expire = DateTime.fromMillisecondsSinceEpoch(
              IntUtils.parse(json["expire_time_for_bandwidth"]))
          .toLocal();
    }
    return DelegatedBandwidthDetails._(
        TronAddress(json["to"]),
        IntegerBalance(BigintUtils.parse(json["frozen_balance_for_bandwidth"]),
            TronUtils.decimal),
        expire);
  }
  @override
  ResourceCode get resource => ResourceCode.bandWidth;
}

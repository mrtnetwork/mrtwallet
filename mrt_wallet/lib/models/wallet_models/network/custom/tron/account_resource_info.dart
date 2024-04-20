import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class TronAccountResourceInfo with CborSerializable {
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          freeNetUsed,
          freeNetLimit,
          netLimit,
          netUsed,
          energyLimit,
          energyUsed,
          tronPowerLimit,
          tronPowerUsed,
        ]),
        WalletModelCborTagsConst.tronAccountResource);
  }

  factory TronAccountResourceInfo.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tronAccountResource);
    return TronAccountResourceInfo(
      freeNetUsed: cbor.elementAt(0),
      freeNetLimit: cbor.elementAt(1),
      netLimit: cbor.elementAt(2),
      netUsed: cbor.elementAt(3),
      energyLimit: cbor.elementAt(4),
      energyUsed: cbor.elementAt(5),
      tronPowerLimit: cbor.elementAt(6),
      tronPowerUsed: cbor.elementAt(7),
    );
  }

  final BigInt freeNetUsed;
  final BigInt freeNetLimit;
  final BigInt netLimit;
  final BigInt netUsed;
  final BigInt energyLimit;
  final BigInt energyUsed;

  final int tronPowerUsed;
  final int tronPowerLimit;
  late final BigInt totalBandWith;
  late final BigInt howManyEnergy;
  late final BigInt totalBandWithUsed;
  int get howManyVote => tronPowerLimit - tronPowerUsed;
  BigInt get howManyBandwIth => totalBandWith - totalBandWithUsed;

  TronAccountResourceInfo({
    required this.freeNetUsed,
    required this.freeNetLimit,
    required this.netLimit,
    required this.netUsed,
    required this.energyLimit,
    required this.energyUsed,
    required this.tronPowerLimit,
    required this.tronPowerUsed,
  }) {
    totalBandWith = freeNetLimit + netLimit;
    totalBandWithUsed = netUsed + freeNetUsed;
    howManyEnergy = energyLimit - energyUsed;
    if (howManyEnergy < BigInt.zero) {
      howManyEnergy = BigInt.zero;
    }
  }

  factory TronAccountResourceInfo.empty() => TronAccountResourceInfo(
      freeNetUsed: BigInt.zero,
      freeNetLimit: BigInt.zero,
      netLimit: BigInt.zero,
      netUsed: BigInt.zero,
      energyLimit: BigInt.zero,
      energyUsed: BigInt.zero,
      tronPowerLimit: 0,
      tronPowerUsed: 0);

  factory TronAccountResourceInfo.fromJson(Map<String, dynamic> json) {
    return TronAccountResourceInfo(
      freeNetLimit: BigintUtils.tryParse(json["freeNetLimit"]) ?? BigInt.zero,
      freeNetUsed: BigintUtils.tryParse(json["freeNetUsed"]) ?? BigInt.zero,
      netLimit: BigintUtils.tryParse(json["NetLimit"]) ?? BigInt.zero,
      netUsed: BigintUtils.tryParse(json["NetUsed"]) ?? BigInt.zero,
      energyUsed: BigintUtils.tryParse(json["EnergyUsed"]) ?? BigInt.zero,
      energyLimit: BigintUtils.tryParse(json["EnergyLimit"]) ?? BigInt.zero,
      tronPowerUsed: json["tronPowerUsed"] ?? 0,
      tronPowerLimit: json["tronPowerLimit"] ?? 0,
    );
  }

  @override
  String toString() {
    return '''
      TronAccountResource {
        freeNetUsed: $freeNetUsed,
        freeNetLimit: $freeNetLimit,
        netLimit: $netLimit,
        netUsed: $netUsed,
        energyLimit: $energyLimit,
        energyUsed: $energyUsed,
        totalBandWith: $totalBandWith,
        totalBandWithUsed: $totalBandWithUsed,
        tronPowerUsed: $tronPowerUsed,
        tronPowerLimit: $tronPowerLimit,
        howManyVote: $howManyVote,
        howManyBandwIth: $howManyBandwIth,
        howManyEnergy: $howManyEnergy,
      }
    ''';
  }

  Map<String, dynamic> toJson() {
    return {
      "freeNetLimit": freeNetLimit,
      "freeNetUsed": freeNetUsed,
      "NetLimit": netLimit,
      "NetUsed": netUsed,
      "EnergyUsed": energyUsed,
      "EnergyLimit": energyLimit,
    };
  }
}

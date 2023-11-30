import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

enum WalletLockTime {
  never(0, "never"),
  oneMinute(60, "one_minute"),
  twoMinute(120, "two_minute"),
  fiveMinute(300, "five_minute");

  final int value;
  final String viewName;
  const WalletLockTime(this.value, this.viewName);
  static WalletLockTime fromValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }
}

class WalletSetting with CborSerializable {
  const WalletSetting({required this.lockTime});
  final WalletLockTime lockTime;
  factory WalletSetting.defaultSetting() {
    return const WalletSetting(lockTime: WalletLockTime.oneMinute);
  }

  WalletSetting copyWith({WalletLockTime? lockTime}) {
    return WalletSetting(lockTime: lockTime ?? this.lockTime);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([lockTime.value]),
        WalletModelCborTagsConst.setting);
  }

  factory WalletSetting.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.setting);
    final WalletLockTime lockTime =
        WalletLockTime.fromValue(cbor.value[0].value);

    return WalletSetting(lockTime: lockTime);
  }
}

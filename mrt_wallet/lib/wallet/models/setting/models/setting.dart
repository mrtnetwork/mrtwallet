import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/setting/models/lock_option.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

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
    return CborTagValue(
        CborListValue.fixedLength([lockTime.value]), CborTagsConst.setting);
  }

  factory WalletSetting.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.setting);
    final WalletLockTime lockTime =
        WalletLockTime.fromValue(cbor.value[0].value);

    return WalletSetting(lockTime: lockTime);
  }
}

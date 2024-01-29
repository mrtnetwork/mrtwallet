import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class AppSetting with CborSerializable {
  const AppSetting._({
    required this.appColor,
    required this.appBrightness,
    required this.currency,
  });
  final String? appColor;
  final String? appBrightness;
  final Currency currency;

  AppSetting copyWith(
      {String? appColor, String? appBrightness, Currency? currency}) {
    return AppSetting._(
        appColor: appColor ?? this.appColor,
        appBrightness: appBrightness ?? this.appBrightness,
        currency: currency ?? this.currency);
  }

  factory AppSetting.fromHex(String? cborHex) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          BytesUtils.fromHexString(cborHex!),
          null,
          WalletModelCborTagsConst.appSetting);
      final String? colorHex = cbor.getIndex(0);
      final String? brightnessName = cbor.getIndex(1);
      final Currency currency = Currency.fromName(cbor.getIndex(2));

      return AppSetting._(
          appColor: colorHex,
          appBrightness: brightnessName,
          currency: currency);
    } catch (e) {
      return const AppSetting._(
          appColor: null, appBrightness: null, currency: Currency.usd);
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([appColor, appBrightness, currency.name]),
        WalletModelCborTagsConst.appSetting);
  }
}

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';

class APPSetting with CborSerializable {
  const APPSetting._({
    required this.appColor,
    required this.appBrightness,
    required this.currency,
  });
  final String? appColor;
  final String? appBrightness;
  final Currency currency;

  APPSetting copyWith(
      {String? appColor, String? appBrightness, Currency? currency}) {
    return APPSetting._(
        appColor: appColor ?? this.appColor,
        appBrightness: appBrightness ?? this.appBrightness,
        currency: currency ?? this.currency);
  }

  factory APPSetting.fromHex(String? cborHex) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          BytesUtils.fromHexString(cborHex!),
          null,
          APPSerializationConst.appSettingTag);
      final String? colorHex = cbor.elementAt(0);
      final String? brightnessName = cbor.elementAt(1);
      final Currency currency =
          Currency.fromName(cbor.elementAt(2)) ?? Currency.USD;

      return APPSetting._(
          appColor: colorHex,
          appBrightness: brightnessName,
          currency: currency);
    } catch (e) {
      return const APPSetting._(
          appColor: null, appBrightness: null, currency: Currency.USD);
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([appColor, appBrightness, currency.name]),
        APPSerializationConst.appSettingTag);
  }
}

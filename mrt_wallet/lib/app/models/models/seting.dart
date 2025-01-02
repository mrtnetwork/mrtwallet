import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/constant/global/serialization.dart';
import 'package:mrt_wallet/app/models/models/currencies.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';

class APPSetting with CborSerializable {
  const APPSetting._(
      {required this.appColor,
      required this.appBrightness,
      required this.currency,
      required this.config});
  final String? appColor;
  final String? appBrightness;
  final Currency currency;
  final MRTAPPConfig config;

  bool get supportBarcodeScanner => config.hasBarcodeScanner;

  APPSetting copyWith(
      {String? appColor, String? appBrightness, Currency? currency}) {
    return APPSetting._(
        appColor: appColor ?? this.appColor,
        appBrightness: appBrightness ?? this.appBrightness,
        currency: currency ?? this.currency,
        config: config);
  }

  factory APPSetting.fromHex(String? cborHex, MRTAPPConfig config) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          BytesUtils.fromHexString(cborHex!),
          null,
          APPSerializationConst.appSettingTag);
      final String? colorHex = cbor.elementAs(0);
      final String? brightnessName = cbor.elementAs(1);
      final Currency currency =
          Currency.fromName(cbor.elementAs(2)) ?? Currency.USD;

      return APPSetting._(
          appColor: colorHex,
          appBrightness: brightnessName,
          currency: currency,
          config: config);
    } catch (_) {
      return APPSetting._(
          appColor: null,
          appBrightness: null,
          currency: Currency.USD,
          config: config);
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([appColor, appBrightness, currency.name]),
        APPSerializationConst.appSettingTag);
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/custom_colors.dart';
import 'package:mrt_wallet/app/extention/color.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';

class AppMaterialController {
  static const List<int> materialSettingCborTag = [100];
  static Color _appColor = Colors.blueGrey;
  static Color get appColor => _appColor;
  static Brightness _appBrightness = Brightness.dark;
  static ThemeData _buildTheme() {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _appColor,
      brightness: _appBrightness,
    );
    ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: const TextTheme(),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        helperMaxLines: 3,
        errorMaxLines: 3,
        helperStyle: TextStyle(color: CustomColors.green),
      ),
      segmentedButtonTheme: const SegmentedButtonThemeData(
          selectedIcon: Icon(Icons.check_circle)),
    );
    return theme;
  }

  static ThemeData _appTheme = _buildTheme();
  static ThemeData get appTheme => _appTheme;
  static Locale locale = const Locale("en");
  static void toggleBrightness() {
    _appBrightness =
        _appBrightness == Brightness.light ? Brightness.dark : Brightness.light;
    _appTheme = _buildTheme();
  }

  static void changeColor(Color color) {
    _appColor = color;
    _appTheme = _buildTheme();
  }

  static CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([_appBrightness.name, _appColor.toHex()]),
        materialSettingCborTag);
  }

  static void restoreMaterial(String? cborHex) {
    try {
      if (cborHex == null) return;
      final CborObject cborObject = CborObject.fromCborHex(cborHex);
      final CborListValue cbor = CborSerializable.decodeCborTags(
          null, cborObject, materialSettingCborTag);
      final String brightnessName = cbor.value[0].value;
      final String colorHex = cbor.value[1].value;
      final color = HexColor.fromHex(colorHex);
      final Brightness brightness = Brightness.values
          .firstWhere((element) => element.name == brightnessName);
      _appColor = color;
      _appBrightness = brightness;
      // ignore: empty_catches
    } catch (e) {}
  }
}

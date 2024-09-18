import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/constant/constant.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/color.dart';
import 'package:mrt_wallet/app/models/models/seting.dart';

class ThemeController {
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
        helperStyle: TextStyle(color: ColorConst.green),
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

  static String get appColorHex => _appColor.toHex();

  static String get appBrightness => _appBrightness.name;

  static void fromAppSetting(APPSetting setting) {
    try {
      if (setting.appBrightness == null || setting.appColor == null) return;
      final color = HexColor.fromHex(setting.appColor!);
      final Brightness brightness = Brightness.values
          .firstWhere((element) => element.name == setting.appBrightness);
      _appColor = color;
      _appBrightness = brightness;
      // ignore: empty_catches
    } catch (e) {}
  }
}

import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/future/theme/theme.dart';
import 'package:mrt_wallet/app/localization/localization.dart';

extension Translate on String {
  static get localization => Localization.languages;
  static Locale get language => ThemeController.locale;
  String get tr => localization[language.languageCode]?[this] ?? this;

  String replaceOne(String replace) {
    return replaceAll("___1__", replace);
  }

  String replaceTwo(String replace) {
    return replaceAll("___2__", replace);
  }

  String replaceThere(String replace) {
    return replaceAll("___3__", replace);
  }

  String get camelCase {
    return StrUtils.toCamelCase(this);
  }

  String get orEmpty => trim().isEmpty ? "value_is_empty".tr : this;
  String or(String or) => trim().isEmpty ? or : this;
  String? get nullOnEmpty => trim().isEmpty ? null : this;
  String get to3Digits => StrUtils.to3Digits(this, separator: ",");
}

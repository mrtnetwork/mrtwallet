import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/utility/string_utility.dart';
import 'package:mrt_wallet/models/app/material.dart';
import 'package:mrt_wallet/app/localization/localization.dart';

extension Translate on String {
  static get localization => Localization.languages;
  static Locale get language => AppMaterialController.locale;
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
    return AppStringUtility.toCamelCase(this);
  }

  String get orEmpty => trim().isEmpty ? "value_is_empty".tr : this;
  String? get nullOnEmpty => trim().isEmpty ? null : this;
  String get to3Digits => AppStringUtility.to3Digits(this, separator: ",");
}

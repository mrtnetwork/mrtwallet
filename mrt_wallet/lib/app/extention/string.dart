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

  String get camelCase {
    return AppStringUtility.toCamelCase(this);
  }
}

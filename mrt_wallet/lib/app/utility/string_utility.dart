import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'dart:math' as math;

class AppStringUtility {
  static bool isStrongPassword(String? password) {
    if (password == null) return false;
    // Use a regular expression to check for the password requirements
    const pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  static const String _rtlChars = r'\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC';

  /// Practical patterns to identify strong LTR and RTL characters,
  /// respectively.  These patterns are not completely correct according to the
  /// Unicode standard. They are simplified for performance and small code size.
  static const String _ltrChars =
      r'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02B8\u0300-\u0590'
      r'\u0800-\u1FFF\u2C00-\uFB1C\uFDFE-\uFE6F\uFEFD-\uFFFF';

  /// Determines if the first character in [text] with strong directionality is
  /// RTL. If [isHtml] is true, the text is HTML or HTML-escaped.
  static bool startsWithRtl(String text, [bool isHtml = false]) {
    return RegExp('^[^$_ltrChars]*[$_rtlChars]').hasMatch(text);
  }

  static String toCamelCase(String input) {
    if (input.isEmpty) {
      return input;
    }

    List<String> words = input.split(' ');

    // Capitalize the first letter of each words
    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return '';
      }
    }).toList();

    // Join the words to form CamelCase
    String camelCaseString = capitalizedWords.join('');

    return camelCaseString;
  }

  static String? validateLengthOrNull(String? val, int length) {
    if (val == null || val.length > length) return null;
    return val;
  }

  static String to3Digits(String number, {String separator = ","}) {
    String integerPart = '';
    String fractionalPart = '';

    if (number.contains('.')) {
      List<String> parts = number.split('.');
      integerPart = parts[0];
      fractionalPart = parts[1];
    } else {
      integerPart = number;
    }

    List<String> groups = [];
    int i = integerPart.length;
    while (i > 0) {
      String group = integerPart.substring(math.max(0, i - 3), i);
      groups.insert(0, group);

      i -= 3;
    }

    final String result = groups.join(separator) +
        (fractionalPart.isEmpty ? '' : '.$fractionalPart');

    return result;
  }

  static String? validateUri(String? url,
      {List<String> schame = const ['http', 'https']}) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.isEmpty) return null;
    if (!schame.contains(uri.scheme.toLowerCase())) return null;
    if (!uri.host.contains(".")) return null;
    return uri.normalizePath().toString();
  }

  static int findFirstMissingNumber(List<int> numbers, {int start = 0}) {
    final List<int> sortedNumbers = List.from(numbers)..sort();
    int missingNumber = start;

    for (int number in sortedNumbers) {
      if (number == missingNumber) {
        missingNumber++;
      } else if (number > missingNumber) {
        break;
      }
    }
    return missingNumber;
  }

  static String addNumberToMakeUnique(List<String> list, String target) {
    int count = 1;
    String result = target;

    while (list.contains(result)) {
      count++;
      result = '$target ($count)';
    }

    return result;
  }
}

void ensureKeyVisible(
    {required GlobalKey key,
    int afterMilliseconds = 400,
    int jumpDuration = 320,
    double alignment = 0.5,
    DynamicVoid? onScroll}) async {
  await Future.delayed(Duration(milliseconds: afterMilliseconds));
  try {
    if (key.currentContext != null) {
      await Scrollable.ensureVisible(key.currentContext!,
          alignment: alignment,
          duration: Duration(milliseconds: jumpDuration),
          curve: Curves.decelerate);
      onScroll?.call();
    }
    // ignore: empty_catches
  } catch (e) {}
}

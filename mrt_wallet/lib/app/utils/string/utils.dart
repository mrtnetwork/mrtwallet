import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'dart:math' as math;

class StrUtils {
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
    bool negative = false;

    if (number.contains('.')) {
      List<String> parts = number.split('.');
      integerPart = parts[0];
      fractionalPart = parts[1];
    } else {
      integerPart = number;
    }

    if (integerPart.startsWith("-")) {
      negative = true;
      integerPart = integerPart.substring(1);
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
    if (negative) return "-$result";
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

  static String? validateIpfsCIDV1(String? cid,
      {List<String> schame = const ['http', 'https']}) {
    if (cid == null) return null;
    RegExp regex = RegExp(
        r'^(Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,})$');
    if (regex.hasMatch(cid)) {
      return cid;
    }
    return null;
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

  static String removeSchame(String uri) {
    final schames = ["https://", "http://", "ws://", "wss://"];
    final lower = uri.toLowerCase();
    final schame = MethodUtils.nullOnException(
        () => schames.firstWhere((element) => lower.startsWith(element)));
    if (schame == null) return uri;
    return uri.substring(schame.length - 1);
  }

  static String toIpfsV1Uri(String cid) {
    return "https://ipfs.io/ipfs/$cid";
  }

  static String substring(String value, {int length = 5, String replace = ''}) {
    if (value.length > length) {
      return value.replaceRange(length - 1, value.length, replace);
    }
    return value;
  }

  static bool isValidIPv4WithPort(String ipv4) {
    // Regular expression to match IPv4 address with optional port
    final RegExp ipv4WithPortRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}:\d+$');

    // Check if the input matches the pattern
    return ipv4WithPortRegex.hasMatch(ipv4);
  }

  static String? isValidTcpAddress(String? url) {
    if (url == null) return null;
    if (isValidIPv4WithPort(url)) {
      return url;
    }
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9.-]+:\d+(/[^?#]*)?$');
    if (regExp.hasMatch(url)) {
      return url;
    }
    return null;
  }

  static bool isHex(String? v) {
    if (v == null) return false;
    if (v.isEmpty) return false;
    return StringUtils.isHexBytes(v);
  }

  static String removeLastSlash(String v) {
    if (v.endsWith("/")) return v.substring(v.length - 1);
    return v;
  }
}

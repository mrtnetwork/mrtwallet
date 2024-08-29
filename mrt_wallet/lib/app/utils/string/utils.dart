import 'package:blockchain_utils/utils/utils.dart';
// import 'package:mrt_wallet/app/core.dart';
import 'dart:math' as math;

import 'package:mrt_wallet/app/utils/method/utiils.dart';

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
    input = input.replaceAll('-', ' ').replaceAll('_', ' ');

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

  static String toRawString(String string) {
    return string
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t')
        .replaceAll('\$', r'\$')
        .replaceAll('"', r'\"')
        .replaceAll("'", r"\'")
        .replaceAll('\f', r'\f')
        .replaceAll('\u0000', r'\u0000')
        .replaceAll('\u0001', r'\u0001')
        .replaceAll('\u0002', r'\u0002')
        .replaceAll('\u0003', r'\u0003')
        .replaceAll('\u0004', r'\u0004')
        .replaceAll('\u0005', r'\u0005')
        .replaceAll('\u0006', r'\u0006')
        .replaceAll('\u0007', r'\u0007')
        .replaceAll('\u0008', r'\u0008')
        .replaceAll('\u0009', r'\u0009')
        .replaceAll('\u000A', r'\u000A')
        .replaceAll('\u000B', r'\u000B')
        .replaceAll('\u000C', r'\u000C')
        .replaceAll('\u000D', r'\u000D')
        .replaceAll('\u000E', r'\u000E')
        .replaceAll('\u000F', r'\u000F')
        .replaceAll('\u0010', r'\u0010')
        .replaceAll('\u0011', r'\u0011')
        .replaceAll('\u0012', r'\u0012')
        .replaceAll('\u0013', r'\u0013')
        .replaceAll('\u0014', r'\u0014')
        .replaceAll('\u0015', r'\u0015')
        .replaceAll('\u0016', r'\u0016')
        .replaceAll('\u0017', r'\u0017')
        .replaceAll('\u0018', r'\u0018')
        .replaceAll('\u0019', r'\u0019')
        .replaceAll('\u001A', r'\u001A')
        .replaceAll('\u001B', r'\u001B')
        .replaceAll('\u001C', r'\u001C')
        .replaceAll('\u001D', r'\u001D')
        .replaceAll('\u001E', r'\u001E')
        .replaceAll('\u001F', r'\u001F')
        .replaceAll('\u007F', r'\u007F');
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
    // if (!uri.host.contains(".")) return null;
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

  static String _twoDigits(int n) {
    if (n >= 10) {
      return "$n";
    } else {
      return "0$n";
    }
  }

  static String toFileName(DateTime time) {
    return "${time.year}_${_twoDigits(time.month)}_${_twoDigits(time.day)}"
        "${_twoDigits(time.hour)}-${_twoDigits(time.minute)}-${_twoDigits(time.second)}";
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

  static String toSnakeCase(String input) {
    // Replace all uppercase letters with _letter (lowercase)
    String snakeCase = input.replaceAllMapped(
        RegExp(r'[A-Z]'), (Match match) => '_${match.group(0)!.toLowerCase()}');

    // Remove any leading underscores that might have been added
    snakeCase = snakeCase.startsWith('_') ? snakeCase.substring(1) : snakeCase;

    // Replace spaces and special characters with underscores
    snakeCase = snakeCase.replaceAll(RegExp(r'\s+|[^a-zA-Z0-9]+'), '_');

    return snakeCase;
  }

  static final _domainRegex = RegExp(
      r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
  static bool isDomain(String? url) {
    if (url == null) return false;
    return _domainRegex.hasMatch(url);
  }
  // final r = RegExp(validHostnameRegex, unicode: true);
}

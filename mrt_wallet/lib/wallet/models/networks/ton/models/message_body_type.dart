import 'package:mrt_wallet/wallet/utils/ton/ton.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:ton_dart/ton_dart.dart';

enum TonMessageBodyType {
  comment._("comment"),
  binaryComment._("binary_comment"),
  cell._("cell"),
  none._("none");

  final String name;
  const TonMessageBodyType._(this.name);
  String get helperText {
    switch (this) {
      case TonMessageBodyType.comment:
        return "enter_comment_as_string_or_hex";
      case TonMessageBodyType.binaryComment:
        return "enter_binary_message_as_hex";
      case TonMessageBodyType.cell:
        return "enter_cell_as_hex_or_base64";
      default:
        return "";
    }
  }

  bool isValid(String? v) {
    switch (this) {
      case TonMessageBodyType.binaryComment:
        return StrUtils.isHex(v);
      case TonMessageBodyType.comment:
        return v?.isNotEmpty ?? false;
      case TonMessageBodyType.cell:
        return TonUtils.isValidCell(v);
      default:
        return false;
    }
  }

  Cell? toValue(String value) {
    switch (this) {
      case TonMessageBodyType.binaryComment:
        return TonUtils.toBinaryCommetBody(value);
      case TonMessageBodyType.comment:
        return TonUtils.toComment(value);
      case TonMessageBodyType.cell:
        return TonUtils.toCell(value);
      default:
        return null;
    }
  }

  bool get hasBody => this != TonMessageBodyType.none;
}

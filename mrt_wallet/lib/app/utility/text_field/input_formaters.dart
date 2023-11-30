import 'package:flutter/services.dart';
import 'package:mrt_wallet/app/utility/price/price_utils.dart';

class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newString = newValue.text;
    int? enteredNumber = int.tryParse(newString);
    if (enteredNumber != null) {
      if (enteredNumber < min) {
        newString = "$min";
      } else if (enteredNumber > max) {
        newString = "$max";
      } else {
        newString = "$enteredNumber";
      }
    } else {
      newString = "$min";
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class DecodePriceTextInputFormater extends TextInputFormatter {
  const DecodePriceTextInputFormater({this.max, required this.decimal});
  final BigInt? max;
  final int decimal;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.trim().isEmpty) {
      return newValue;
    }
    final pr = PriceUtils.tryDecodePrice(newValue.text, decimal);
    if (pr != null) {
      if (max == null) return newValue;
      if (pr <= max!) return newValue;
    }
    return oldValue;
  }
}

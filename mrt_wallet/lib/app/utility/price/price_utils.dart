import 'package:blockchain_utils/numbers/big_rational.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class RetionalDecimalConst {
  static BigRational bigR8 = BigRational(BigInt.from(10).pow(8));
  static BigRational bigR18 = BigRational(BigInt.from(10).pow(18));
  static BigRational bigR6 = BigRational(BigInt.from(10).pow(6));
  static BigRational fromDecimalNumber(int decimal) {
    switch (decimal) {
      case 8:
        return bigR8;
      case 18:
        return bigR18;
      case 6:
        return bigR6;
      default:
        return BigRational(BigInt.from(10).pow(decimal));
    }
  }
}

class PriceUtils {
  static T? tryDecodePrice<T>(String price, int decimal) {
    try {
      return decodePrice(price, decimal);
    } catch (e) {
      return null;
    }
  }

  static T decodePrice<T>(String price, int decimal) {
    BigRational dec = BigRational.parseDecimal(price);
    dec = dec * RetionalDecimalConst.fromDecimalNumber(decimal);
    if (decimal == 0 && dec.isDecimal) {
      throw ArgumentError("price should not be decimal with decimal zero");
    }
    switch (T) {
      case BigInt:
        return dec.toBigInt() as T;
      case double:
        return dec.toDouble() as T;
      case NoneDecimalBalance:
        return NoneDecimalBalance(dec.toBigInt(), 8) as T;
      case dynamic:
        return dec.toBigInt() as T;
      default:
        throw ArgumentError(
            "Invalid decode type price only accept bigint, double, and NoneDecimalBalance for decode");
    }
  }

  static String? tryEncodePrice(BigInt? price, int? decimal,
      {int amoutDecimal = 8}) {
    if (price == null || decimal == null) return null;
    try {
      return encodePrice(price, decimal);
    } catch (e) {
      return null;
    }
  }

  static String encodePrice(BigInt price, int decimal, {int amoutDecimal = 8}) {
    BigRational dec =
        BigRational(price) / RetionalDecimalConst.fromDecimalNumber(decimal);
    return dec.toDecimal(digits: amoutDecimal);
  }

  static String priceWithCoinName(String price, String coinAbbr) {
    return "$price $coinAbbr";
  }
}

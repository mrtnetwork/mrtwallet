import 'package:blockchain_utils/blockchain_utils.dart';

BigInt ret(String correctPrice, {double decimal = 1e8, int amoutDecimal = 8}) {
  BigRational dec = BigRational.parseDecimal(correctPrice);
  dec = dec * BigRational.parseDecimal(decimal.toString());
  return dec.toBigInt();
}

void main() {
  // final decimal = -Decimal.parse("10");
  // print("decimal $decimal");
  // print("negate ${Decimal.parse("-10").abs()}");
  // print(
  //     "in decimala ${decimal} ${decimal.toString() == rational.toDecimal(digits: 20)}");
}

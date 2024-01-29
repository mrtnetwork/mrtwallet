// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

BigInt generateRandomBigInt(int bitLength) {
  // Ensure bitLength is greater than 0
  if (bitLength <= 0) {
    throw ArgumentError('bitLength must be greater than 0');
  }

  // Create a Random object
  Random random = Random();

  // Generate random bits
  List<int> randomBits = List.generate(bitLength, (_) => random.nextInt(2));

  // Set the most significant bit to 1 to ensure the generated number is positive
  randomBits[0] = 1;

  // Convert the list of bits to a BigInt
  BigInt randomBigInt = BigInt.from(0);
  for (int bit in randomBits) {
    randomBigInt = (randomBigInt << 1) + BigInt.from(bit);
  }

  return randomBigInt;
}

void main() {}

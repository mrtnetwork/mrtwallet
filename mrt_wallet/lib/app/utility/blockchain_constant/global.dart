import 'package:blockchain_utils/utils/utils.dart';

class BlockchainConstant {
  static const int maxBip32LevelIndex = 5;
  static const int maxByronLegacyBip32LevelIndex = 2;
  static final BigRational maxSupply = BigRational(maxU64);
  static const int minimumKeysLength = 16;
  static const int maxTokenDecimal = 255;
}

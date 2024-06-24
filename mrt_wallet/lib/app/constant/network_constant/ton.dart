import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/app/utility/blockchain_constant/constant.dart';

class TonConst {
  static const int defaultSubWalletId = 698983191;
  static const int minTonMnemonicWords = 8;
  static const int maxTonMnemonicWords = 48;
  static const int defaultTonMnemonicWordsLength = 24;
  static const int deciaml = 9;

  static final BigRational maxTransferQueryId = BlockchainConstant.maxSupply;
}

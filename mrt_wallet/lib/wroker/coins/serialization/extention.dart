import 'package:blockchain_utils/blockchain_utils.dart';

extension QuickCyrptoCoinSerialization on CryptoCoins {
  CborStringValue toCbor() {
    return CborStringValue("${proposal.specName}#$coinName");
  }
}

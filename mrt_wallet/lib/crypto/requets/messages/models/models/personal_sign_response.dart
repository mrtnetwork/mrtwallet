import 'package:blockchain_utils/blockchain_utils.dart';

class CryptoPersonalSignResponse {
  final String signatureHex;
  final List<int> signature;
  CryptoPersonalSignResponse({
    required this.signatureHex,
    required List<int> signature,
  }) : signature = signature.asImmutableBytes;
}

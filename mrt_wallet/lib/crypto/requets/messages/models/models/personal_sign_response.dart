import 'package:blockchain_utils/utils/utils.dart';

class CryptoPersonalSignResponse {
  final String signatureHex;
  final List<int> signature;
  CryptoPersonalSignResponse({
    required this.signatureHex,
    required List<int> signature,
  }) : signature = BytesUtils.toBytes(signature, unmodifiable: true);
}

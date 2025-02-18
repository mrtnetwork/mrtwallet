import 'package:blockchain_utils/signer/signer.dart';

class CryptoConst {
  static const int keccack256Length = 32;
  static const int kecchack256LengthHex = keccack256Length * 2;
  static final fakeEd25519Signature =
      List<int>.filled(CryptoSignerConst.ecdsaSignatureLength, 0);
}

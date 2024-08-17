import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart';

void main() {
  /// key YEjMebqEnMpijojde4DeielUhRAaB/wCxAhlv3YNn2U=
  /// value ZtHEHg+91MkZaEhZ.7r9hTa2Lilf+4FVUPOwIVfTlnOfZ
  /// value jafar
  final nonce = base64Decode("ZtHEHg+91MkZaEhZ");
  final encrypted = base64Decode("7r9hTa2Lilf+4FVUPOwIVfTlnOfZ");
  final gcm =
      GCM(AES(base64Decode("YEjMebqEnMpijojde4DeielUhRAaB/wCxAhlv3YNn2U=")));
  print(StringUtils.decode(gcm.decrypt(nonce, encrypted)!));
}

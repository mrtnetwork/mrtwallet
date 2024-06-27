import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

enum CustomKeyType {
  privateKey,
  extendedKey;

  static CustomKeyType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletException("Invalid CustomKeyType."));
  }

  bool get isPrivateKey => this == CustomKeyType.privateKey;
}

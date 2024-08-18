import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

enum SeedTypes {
  bip39("Bip39"),
  bip39Entropy("Bip39Entropy"),
  byronLegacySeed("ByronLegacySeed"),
  icarus("icarus");

  final String name;
  const SeedTypes(this.name);
  static SeedTypes fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletException("Invalid seed generation type."));
  }
}

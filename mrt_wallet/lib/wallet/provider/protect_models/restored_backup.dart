part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

class WalletRestoreV2 {
  WalletRestoreV2._({
    required this.masterKeys,
    required List<MRTWalletChainBackup> chains,
    required List<ChainAccount> invalidAddresses,
    required this.wallet,
    this.verifiedChecksum,
  })  : chains = chains.immutable,
        invalidAddresses = invalidAddresses.immutable,
        totalAccounts = chains.fold(0, (p, c) => p + c.chain.addresses.length) +
            invalidAddresses.length;
  final WalletMasterKeys masterKeys;
  final List<MRTWalletChainBackup> chains;
  final List<ChainAccount> invalidAddresses;
  final HDWallet wallet;
  final bool? verifiedChecksum;
  final int totalAccounts;
  bool get hasFailedAccount => invalidAddresses.isNotEmpty;
}

import 'package:mrt_wallet/wallet/models/token/chains_tokens/spl_token.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaAccountSPLTokenInfo {
  final SolanaMintAccount mintAccount;
  final SolanaTokenAccount tokenAccount;
  final Metadata? tokenMetadata;
  final SolAddress pubkey;
  final SolAddress tokenOwner;
  const SolanaAccountSPLTokenInfo(
      {required this.mintAccount,
      required this.tokenAccount,
      required this.pubkey,
      required this.tokenOwner,
      this.tokenMetadata});
  SolanaSPLToken get toSplToken {
    return SolanaSPLToken.create(
        balance: tokenAccount.amount,
        token: Token(
            decimal: mintAccount.decimals,
            name: tokenMetadata?.data.name ??
                tokenAccount.mint.address.substring(0, 6),
            symbol: tokenMetadata?.data.symbol ??
                tokenAccount.mint.address.substring(0, 1)),
        mint: tokenAccount.mint,
        tokenAccount: pubkey,
        tokenOwner: tokenOwner);
  }
}

import 'package:mrt_wallet/wallet/models/token/chains_tokens/spl_token.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaAccountSPLTokenInfo {
  final SolAddress mintAddress;
  final BigInt amount;
  final Token token;
  final SolAddress pubkey;
  final SolAddress tokenOwner;
  const SolanaAccountSPLTokenInfo(
      {required this.mintAddress,
      required this.amount,
      required this.pubkey,
      required this.tokenOwner,
      required this.token});
  SolanaSPLToken get toSplToken {
    return SolanaSPLToken.create(
        balance: amount,
        token: token,
        mint: mintAddress,
        tokenAccount: pubkey,
        tokenOwner: tokenOwner);
  }
}

class SolanaTokenInfo {
  final int? chainId;
  final String address;
  final String name;
  final int? decimal;
  final String symbol;
  final String? logoURI;
  factory SolanaTokenInfo.fromJson(Map<String, dynamic> json) {
    return SolanaTokenInfo(
        chainId: json["chainId"],
        address: json["address"],
        name: json["name"],
        logoURI: json["logoURI"],
        symbol: json["symbol"]);
  }
  factory SolanaTokenInfo.fromOnChainMetadata(Metadata metadata) {
    return SolanaTokenInfo(
        chainId: null,
        address: metadata.mint.address,
        name: metadata.data.name,
        logoURI: metadata.data.uri,
        symbol: metadata.data.symbol);
  }
  const SolanaTokenInfo(
      {this.chainId,
      required this.address,
      required this.name,
      this.decimal,
      required this.symbol,
      this.logoURI});
}

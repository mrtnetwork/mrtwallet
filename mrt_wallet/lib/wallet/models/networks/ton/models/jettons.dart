import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/jetton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonAccountJettonResponse {
  final TonAddress tokenAddress;
  final TonAddress owner;
  final TonAddress jettonWalletAddress;
  final BigInt balance;
  final TonJettonToken? jettonToken;
  TonAccountJettonResponse._(
      {required this.tokenAddress,
      required this.balance,
      required this.owner,
      required this.jettonWalletAddress,
      this.jettonToken});
  factory TonAccountJettonResponse(
      {required TonAddress tokenAddress,
      required BigInt balance,
      required TonAddress owner,
      required TonAddress jettonWalletAddress,
      TonJettonToken? jettonToken}) {
    return TonAccountJettonResponse._(
        tokenAddress: tokenAddress,
        balance: balance,
        owner: owner,
        jettonToken: jettonToken,
        jettonWalletAddress: jettonWalletAddress);
  }
  TonAccountJettonResponse copyWith(
      {TonAddress? tokenAddress,
      BigInt? balance,
      TonAddress? owner,
      TonAddress? jettonWalletAddress,
      TonJettonToken? jettonToken}) {
    return TonAccountJettonResponse._(
        tokenAddress: tokenAddress ?? this.tokenAddress,
        balance: balance ?? this.balance,
        owner: owner ?? this.owner,
        jettonToken: jettonToken ?? this.jettonToken,
        jettonWalletAddress: jettonWalletAddress ?? this.jettonWalletAddress);
  }

  @override
  operator ==(other) {
    if (other is! TonAccountJettonResponse) return false;
    return other.balance == balance && other.tokenAddress == tokenAddress;
  }

  @override
  int get hashCode => Object.hash(tokenAddress, balance);

  late final Token token = jettonToken?.token ??
      Token(
          name: tokenAddress.toFriendlyAddress(),
          decimal: 0,
          symbol: tokenAddress.toFriendlyAddress());

  late final IntegerBalance viewBalance =
      IntegerBalance(balance, token.decimal!);
}

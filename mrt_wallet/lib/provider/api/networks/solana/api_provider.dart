import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/solana/solana_address.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/solana/solana_account_tokens_info.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaApiProvider implements NetworkApiProvider<ISolanaAddress> {
  SolanaApiProvider({required this.provider, required this.network});
  final SolanaRPC provider;
  @override
  final APPSolanaNetwork network;
  @override
  ApiProviderTracker<SolanaApiProviderService> get serviceProvider =>
      (provider.rpc as BaseProviderProtocol).provider
          as ApiProviderTracker<SolanaApiProviderService>;

  @override
  Future<void> updateBalance(ISolanaAddress account) async {
    final accountInfo = await getAccountInfo(account.networkAddress);
    if (accountInfo == null) return;
    account.address.updateBalance(accountInfo.lamports);
    await updateAccounts(account);
  }

  Future<SolanaAccountInfo?> getAccountInfo(SolAddress account) async {
    final info =
        await provider.request(SolanaRPCGetAccountInfo(account: account));
    return info;
  }

  Future<BigInt> getRent(int space) async {
    final lamports = await provider
        .request(SolanaRPCGetMinimumBalanceForRentExemption(size: space));
    return lamports;
  }

  Future<BigInt?> getFee(SolanaTransaction transaction) async {
    return await provider.request(SolanaRPCGetFeeForMessage(
        encodedMessage: StringUtils.decode(transaction.message.serialize(),
            type: StringEncoding.base64)));
  }

  Future<SolAddress> getBlockHash() async {
    final blockHash =
        await provider.request(const SolanaRPCGetLatestBlockhash());
    return blockHash.blockhash;
  }

  Future<String> getGenesisHash() async {
    final gnesisHash = await provider.request(SolanaRPCGetGenesisHash());
    return gnesisHash;
  }

  Future<List<ContactInfo>> clusterNodes() async {
    final gnesisHash = await provider.request(SolanaRPCGetClusterNodes());
    return gnesisHash;
  }

  Future<void> updateAccounts(ISolanaAddress address) async {
    for (final i in address.tokens) {
      try {
        final balance = await provider
            .request(SolanaRPCGetTokenAccount(account: i.tokenAccount));
        i.updateBalance(balance?.amount ?? BigInt.zero);
      } catch (e) {
        continue;
      }
    }
  }

  Future<List<SolanaAccountSPLTokenInfo>> getAccountTokens(SolAddress account,
      {SolAddress tokenProgram = SPLTokenProgramConst.tokenProgramId}) async {
    final List<SolanaAccountSPLTokenInfo> tokens = [];
    final tokenAccounts = await provider.request(
        SolanaRPCGetTokenAccountsByOwner(
            account: account,
            programId: tokenProgram,
            encoding: SolanaRPCEncoding.base64));

    for (final i in tokenAccounts) {
      final mint = await provider
          .request(SolanaRPCGetMintAccount(account: i.tokenAccount.mint));
      final metadatPda = MetaplexTokenMetaDataProgramUtils.findMetadataPda(
          mint: i.tokenAccount.mint);
      final tokenMetadata = await provider
          .request(SolanaRPCGetMetadataAccount(account: metadatPda.address));
      tokens.add(SolanaAccountSPLTokenInfo(
          mintAccount: mint!,
          tokenAccount: i.tokenAccount,
          tokenMetadata: tokenMetadata,
          pubkey: i.pubkey,
          tokenOwner: i.account.owner));
    }
    return tokens;
  }
}

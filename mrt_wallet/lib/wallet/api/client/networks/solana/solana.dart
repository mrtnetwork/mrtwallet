import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/solana.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/solana/models/solana_account_tokens_info.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaClient extends NetworkClient<ISolanaAddress, SolanaAPIProvider> {
  SolanaClient({required this.provider, required this.network});
  final SolanaRPC provider;
  @override
  final WalletSolanaNetwork network;
  @override
  BaseServiceProtocol<SolanaAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<SolanaAPIProvider>;

  @override
  Future<void> updateBalance(ISolanaAddress account,
      {bool updateTokens = true}) async {
    final accountInfo = await getAccountInfo(account.networkAddress);
    account.address.updateBalance(accountInfo?.lamports);
    if (updateTokens) {
      await updateAccounts(account);
    }
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
            type: StringEncoding.base64),
        commitment: Commitment.processed));
  }

  Future<SimulateTranasctionResponse> simulate(
      {required SolanaTransaction transaction,
      SolAddress? account,
      bool replaceRecentBlockhash = true,
      bool sigVerify = false}) async {
    return await provider.request(
      SolanaRPCSimulateTransaction(
          encodedTransaction: transaction.serializeString(
              encoding: TransactionSerializeEncoding.base64),
          sigVerify: sigVerify,
          replaceRecentBlockhash: replaceRecentBlockhash,
          encoding: SolanaRPCEncoding.base64,
          commitment: Commitment.processed,
          accounts: account == null
              ? null
              : RPCAccountConfig(
                  addresses: [account], encoding: SolanaRPCEncoding.base64)),
    );
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

  Future<String> genesis() async {
    return await provider.request(SolanaRPCGetGenesisHash());
  }

  Future<String> sendTransaction(SolanaTransaction transaction,
      {int? maxRetries,
      bool skipPreflight = false,
      int? minContextSlot,
      Commitment? commitment,
      SolanaRPCEncoding encoding = SolanaRPCEncoding.base64}) async {
    return await provider.request(SolanaRPCSendTransaction(
        encodedTransaction: transaction.serializeString(
          encoding: encoding == SolanaRPCEncoding.base64
              ? TransactionSerializeEncoding.base64
              : TransactionSerializeEncoding.base58,
        ),
        encoding: encoding,
        skipPreflight: skipPreflight,
        maxRetries: maxRetries,
        commitment: skipPreflight ? Commitment.processed : commitment,
        minContextSlot: minContextSlot == null
            ? null
            : MinContextSlot(slot: minContextSlot)));
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() async => await genesis());
    return result.hasResult && result.result == network.coinParam.genesis;
  }
}

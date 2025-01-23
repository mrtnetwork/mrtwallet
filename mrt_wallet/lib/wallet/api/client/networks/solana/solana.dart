import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/solana.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/solana/models/solana_account_tokens_info.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaClient extends NetworkClient<ISolanaAddress, SolanaAPIProvider>
    with CryptoWokerImpl, HttpImpl {
  SolanaClient({required this.provider, required this.network});
  final SolanaProvider provider;
  @override
  final WalletSolanaNetwork network;
  List<SolanaTokenInfo>? _tokenLists;

  @override
  SolanaHTTPService get service => provider.rpc as SolanaHTTPService;

  @override
  Future<void> updateBalance(
      ISolanaAddress address, APPCHAINACCOUNT<ISolanaAddress> chain,
      {bool updateTokens = true}) async {
    final accountInfo = await getAccountInfo(address.networkAddress);
    chain.updateAddressBalance(
        address: address, updateBalance: accountInfo?.lamports);
    if (updateTokens) {
      await updateAccounts(address);
    }
  }

  Future<SolanaAccountInfo?> getAccountInfo(SolAddress account) async {
    final info =
        await provider.request(SolanaRequestGetAccountInfo(account: account));
    return info;
  }

  Future<SolanaTokenAccount?> getTokenAccount(SolAddress account) async {
    final info =
        await provider.request(SolanaRPCGetTokenAccount(account: account));
    return info;
  }

  Future<BigInt> getRent(int space) async {
    final lamports = await provider
        .request(SolanaRequestGetMinimumBalanceForRentExemption(size: space));
    return lamports;
  }

  Future<BigInt?> getFee(SolanaTransaction transaction) async {
    return await provider.request(SolanaRequestGetFeeForMessage(
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
      SolanaRequestSimulateTransaction(
          encodedTransaction: transaction.serializeString(
              encoding: TransactionSerializeEncoding.base64),
          sigVerify: sigVerify,
          replaceRecentBlockhash: replaceRecentBlockhash,
          encoding: SolanaRequestEncoding.base64,
          commitment: Commitment.processed,
          accounts: account == null
              ? null
              : RPCAccountConfig(
                  addresses: [account],
                  encoding: SolanaRequestEncoding.base64)),
    );
  }

  Future<List<SolanaTokenInfo>> getTokenList() async {
    if (_tokenLists != null) return _tokenLists!;
    final result = await MethodUtils.call(() async {
      final result = await httpGet<Map<String, dynamic>>(
          SolanaConst.tokenListUri,
          responseType: HTTPResponseType.map);
      final Map<String, dynamic> data = result.result;
      final tokenJson = (data["tokens"] as List).cast<Map<String, dynamic>>();
      final List<SolanaTokenInfo> tokenList = [];
      for (final i in tokenJson) {
        if (i["chainId"] != network.coinParam.chainId) continue;
        tokenList.add(SolanaTokenInfo.fromJson(i));
      }
      return tokenList;
    });
    if (result.hasError) {
      assert(false, "should not be failed.");
      return [];
    }
    _tokenLists = result.result;
    return _tokenLists!;
  }

  Future<SolAddress> getBlockHash() async {
    final blockHash =
        await provider.request(const SolanaRequestGetLatestBlockhash());
    return blockHash.blockhash;
  }

  Future<String> getGenesisHash() async {
    final gnesisHash = await provider.request(SolanaRequestGetGenesisHash());
    return gnesisHash;
  }

  Future<List<ContactInfo>> clusterNodes() async {
    final gnesisHash = await provider.request(SolanaRequestGetClusterNodes());
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
        SolanaRequestGetTokenAccountsByOwner(
            account: account,
            programId: tokenProgram,
            encoding: SolanaRequestEncoding.base64));
    if (tokenAccounts.isEmpty) return [];
    for (final i in tokenAccounts) {
      final mint = await provider
          .request(SolanaRPCGetMintAccount(account: i.tokenAccount.mint));
      final splToken =
          await _createSplTokenInfo(mintAccount: mint!, tokenAccount: i);
      tokens.add(splToken);
    }
    return tokens;
  }

  Future<SolanaAccountSPLTokenInfo> _createSplTokenInfo(
      {required SolanaMintAccount mintAccount,
      required TokenAccountResponse tokenAccount}) async {
    final mintAddress = tokenAccount.tokenAccount.mint;
    SolanaTokenInfo? tokenInfo;
    final metadatPda =
        MetaplexTokenMetaDataProgramUtils.findMetadataPda(mint: mintAddress);
    final tokenMetadata = await MethodUtils.call(() async => provider
        .request(SolanaRPCGetMetadataAccount(account: metadatPda.address)));
    if (tokenMetadata.hasResult && tokenMetadata.result != null) {
      tokenInfo = SolanaTokenInfo.fromOnChainMetadata(tokenMetadata.result!);
    } else {
      final metadatas = await getTokenList();
      tokenInfo =
          metadatas.firstWhereOrNull((e) => e.address == mintAddress.address);
    }
    APPImage? image = APPImage.network(tokenInfo?.logoURI);
    final token = Token(
        assetLogo: image,
        decimal: mintAccount.decimals,
        name: tokenInfo?.name ?? mintAddress.address,
        symbol: tokenInfo?.symbol ?? mintAddress.address);
    return SolanaAccountSPLTokenInfo(
        amount: tokenAccount.tokenAccount.amount,
        mintAddress: mintAddress,
        token: token,
        pubkey: tokenAccount.pubkey,
        tokenOwner: tokenAccount.account.owner);
  }

  Future<String> genesis() async {
    return await provider.request(SolanaRequestGetGenesisHash());
  }

  Future<String> sendTransaction(SolanaTransaction transaction,
      {int? maxRetries,
      bool skipPreflight = false,
      int? minContextSlot,
      Commitment? commitment,
      SolanaRequestEncoding encoding = SolanaRequestEncoding.base64}) async {
    return await provider.request(SolanaRequestSendTransaction(
        encodedTransaction: transaction.serializeString(
          encoding: encoding == SolanaRequestEncoding.base64
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

  Future<bool> validateNetworkGenesis() async {
    final result = await genesis();
    return result == network.genesisBlock;
  }

  @override
  Future<bool> onInit() async {
    final result =
        await MethodUtils.call(() async => await validateNetworkGenesis());
    return result.hasResult && result.result;
  }

  @override
  void dispose() {
    super.dispose();
    _tokenLists = null;
  }
}

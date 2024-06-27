import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/models/token/tokens/erc20.dart';
import 'package:mrt_wallet/wallet/models/token/tokens/trc20.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';

class EthereumClient implements NetworkClient<IEthAddress> {
  EthereumClient({required this.provider, required this.network});
  final EVMRPC provider;
  @override
  final WalletNetwork network;
  @override
  APIServiceTracker<EthereumAPIProvider> get serviceProvider =>
      (provider.rpc as BaseServiceProtocol).provider
          as APIServiceTracker<EthereumAPIProvider>;

  @override
  Future<void> updateBalance(IEthAddress account) async {
    final balance = await provider
        .request(RPCGetBalance(address: account.address.toAddress));
    account.address.updateBalance(balance);
    await updateAccountTokensBalance(account);
  }

  Future<FeeHistorical> getHistoricalFee() async {
    final historical = await provider.request(RPCGetFeeHistory(
        blockCount: 10,
        newestBlock: BlockTagOrNumber.latest,
        rewardPercentiles: [30, 60, 99]));
    return historical!.toFee();
  }

  Future<(BigInt, bool)> getNetworkInfo() async {
    final BigInt chainId = await provider.request(RPCGetChainId());
    try {
      final eip = await provider.request(RPCGetFeeHistory(
          blockCount: 25,
          newestBlock: BlockTagOrNumber.pending,
          rewardPercentiles: [25, 50, 90]));
      return (chainId, eip != null);
    } on RPCError {
      return (chainId, false);
    }
  }

  Future<BigInt> gasPrice() async {
    final historical = await provider.request(RPCGetGasPrice());
    return historical;
  }

  Future<BigInt> estimateGasLimit(Map<String, dynamic> estimateDetails) async {
    final estimate =
        await provider.request(RPCEstimateGas(transaction: estimateDetails));
    return estimate;
  }

  Future<int> getAccountNonce(ETHAddress account) async {
    final nonce = await provider
        .request(RPCGetTransactionCount(address: account.address));
    return nonce;
  }

  Future<String> sendRawTransaction(String digest) async {
    final txID =
        await provider.request(RPCSendRawTransaction(transaction: digest));
    return txID;
  }

  Future<Token?> getErc20Details(SolidityAddress contractAddress) async {
    try {
      final symbol = await provider.request(RPCERC20Symbol(contractAddress));
      if (symbol == null) return null;
      final decimal = await provider.request(RPCERC20Decimal(contractAddress));
      if (decimal == null) return null;
      return Token(name: symbol, symbol: symbol, decimal: decimal);
    } on RPCError {
      return null;
    }
  }

  Future<void> updateTokenBalance(
      SolidityAddress account, SolidityToken token) async {
    final balance = await provider
        .request(RPCERC20TokenBalance(token.toHexAddress(), account));
    token.updateBalance(balance);
  }

  Future<void> updateAccountTokensBalance(Bip32AddressCore account) async {
    if (account is! IEthAddress && account is! ITronAddress) return;
    for (final i in account.tokens) {
      try {
        await updateTokenBalance(account.networkAddress, i as SolidityToken);
      } catch (e) {
        continue;
      }
    }
  }

  Future<SolidityToken?> getAccountERC20Token(
      SolidityAddress account, SolidityAddress contractAddress) async {
    final token = await getErc20Details(contractAddress);
    if (token == null) return null;
    final balance = await provider
        .request(RPCERC20TokenBalance(contractAddress.toHex(), account));
    if (contractAddress is TronAddress) {
      return TronTRC20Token.create(
          balance: balance, token: token, contractAddress: contractAddress);
    }
    return ETHERC20Token.create(
        balance: balance,
        token: token,
        contractAddress: contractAddress as ETHAddress);
  }
}

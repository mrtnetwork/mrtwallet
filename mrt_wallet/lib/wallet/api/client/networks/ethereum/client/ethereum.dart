import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/etherum.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/solidity/solidity.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';

class EthereumClient extends NetworkClient<IEthAddress, EthereumAPIProvider> {
  EthereumClient({required this.provider, required this.network});
  final EVMRPC provider;
  @override
  final WalletNetwork network;
  @override
  BaseServiceProtocol<EthereumAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<EthereumAPIProvider>;

  bool get supportSubscribe => service.protocol == ServiceProtocol.websocket;

  void addSubscriptionListener(ONETHSubsribe listener) {
    if (service.protocol != ServiceProtocol.websocket) {
      throw WalletExceptionConst.ethSubscribe;
    }
    (service as EthereumWebsocketService).addSubscriptionListener(listener);
  }

  void removeSubscriptionListener(ONETHSubsribe listener) {
    if (service.protocol != ServiceProtocol.websocket) {
      throw WalletExceptionConst.ethSubscribe;
    }
    (service as EthereumWebsocketService).removeSubscriptionListener(listener);
  }

  Future<String> subscribe({List<dynamic> params = const []}) async {
    if (service.protocol != ServiceProtocol.websocket) {
      throw WalletExceptionConst.ethSubscribe;
    }
    final result =
        await provider.requestDynamic(EthereumMethods.subscribe.value, params);
    return result;
  }

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

  Future<bool> isContract(SolidityAddress address) async {
    final code = await provider.request(RPCGetCode(address: address.toHex()));
    return code != null;
  }

  Future<Token?> getErc20Details(SolidityAddress contractAddress) async {
    try {
      final decimal = await provider.request(RPCERC20Decimal(contractAddress,
          blockNumber: BlockTagOrNumber.latest));
      if (decimal == null) return null;
      String? name;
      String? symbol;

      final symbolQuery = await MethodUtils.call(() async =>
          await provider.request(RPCERC20Symbol(contractAddress,
              blockNumber: BlockTagOrNumber.latest)));
      if (symbolQuery.hasResult) {
        symbol = symbolQuery.result;
      }
      final nameQuery = await MethodUtils.call(() async =>
          await provider.request(RPCERC20Name(contractAddress,
              blockNumber: BlockTagOrNumber.latest)));
      if (nameQuery.hasResult) {
        name = nameQuery.result;
      }
      name ??= symbol;
      symbol ??= name;
      return Token(
          name: name ?? "Unknown",
          symbol: symbol ?? "Unknown",
          decimal: decimal);
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

  Future<void> updateAccountTokensBalance(ChainAccount account) async {
    if (account is! IEthAddress && account is! ITronAddress) return;
    for (final i in account.tokens) {
      try {
        await updateTokenBalance(account.networkAddress, i as SolidityToken);
      } catch (e) {
        continue;
      }
    }
  }

  Future<(ContractABI, SolidityContractInterface)?> detectContractAbi({
    required SolidityAddress contractAddress,
    required SolidityAddress from,
  }) async {
    SolidityContractInterface interface = SolidityContractInterface.none;
    for (final i in SolidityContractInterface.values) {
      try {
        final support = await provider.request(RPCDetectContactInterface(
            interface: i, contractAddress: contractAddress, from: from));
        if (support) {
          interface = i;
          break;
        }
      } on RPCError catch (_) {
        break;
      } catch (_) {}
    }
    final assetPath = interface.getContractAssetPath;
    if (assetPath == null) return null;
    final contractJson = await PlatformUtils.loadAssetText(assetPath);
    return (
      ContractABI.fromJson(StringUtils.toJson<List>(contractJson)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()),
      interface
    );
  }

  Future<EthereumTransactionDataInfo>
      _getTransactionContractInfo<NETWORKADDRESS extends SolidityAddress>(
          {required ContractABI? contract,
          required SolidityAddress contractAddress,
          required SolidityAddress account,
          required APPCHAINNETWORK<NETWORKADDRESS> chain,
          required List<int> data,
          required String dataHex,
          required List<int> selector,
          required SolidityContractInterface? interface}) async {
    if (contract == null || interface == SolidityContractInterface.erc20) {
      final token = await getAccountERC20Token(account, contractAddress);
      if (token != null) {
        if (BytesUtils.bytesEqual(
            selector, SolidityContractUtils.erc20Transfer.selector)) {
          final decodeTransfer = MethodUtils.nullOnException(() {
            final decode = SolidityContractUtils.decodeErc20Transfer(data);
            if (chain.network.type == NetworkType.tron) {
              return (decode.a.toTronAddress(), decode.b);
            }
            return (decode.a.toEthereumAddress(), decode.b);
          });
          if (decodeTransfer != null) {
            return SolidityERC20TransferMethodInfo<NETWORKADDRESS>(
                selector: selector,
                token: token,
                to: chain.getReceiptAddress(decodeTransfer.$1.toString()) ??
                    ReceiptAddress<NETWORKADDRESS>(
                        view: decodeTransfer.$1.toString(),
                        networkAddress: decodeTransfer.$1 as NETWORKADDRESS),
                value: IntegerBalance(decodeTransfer.$2, token.token.decimal!),
                dataHex: dataHex);
          }
        }
        if (contract == null) {
          final contractJson = await PlatformUtils.loadAssetText(
              SolidityContractInterface.erc20.getContractAssetPath!);
          contract = ContractABI.fromJson(StringUtils.toJson<List>(contractJson)
              .map((e) => Map<String, dynamic>.from(e))
              .toList());
        }
      }
    }
    final method = MethodUtils.nullOnException(() {
      final method = contract?.findFunctionFromSelector(selector);
      final decodeInput = method?.decodeInput(data);
      if (decodeInput != null) {
        return SolidityNameAndInputValues(
            selector: selector, inputs: decodeInput, name: method!.name);
      }
      return null;
    });
    return method ??
        SolidityUnknownMethodInfo(selector: selector, dataHex: dataHex);
  }

  Future<EthereumTransactionDataInfo>
      getTransactionContractInfo<NETWORKADDRESS extends SolidityAddress>(
          {required SolidityAddress account,
          required SolidityAddress contractAddress,
          required APPCHAINNETWORK<NETWORKADDRESS> chain,
          required List<int> data}) async {
    final dataHex = BytesUtils.toHexString(data, prefix: "0x");
    final selector = SolidityContractUtils.getSelector(data);
    if (selector == null) {
      return SolidityUnknownMethodInfo(selector: data, dataHex: dataHex);
    }
    final contract = await detectContractAbi(
        contractAddress: contractAddress, from: account);
    return _getTransactionContractInfo<NETWORKADDRESS>(
        contract: contract?.$1,
        contractAddress: contractAddress,
        account: account,
        chain: chain,
        data: data,
        interface: contract?.$2,
        selector: selector,
        dataHex: dataHex);
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

  Future<Web3EthereumTransactionRequestInfos> getWeb3TransactionInfos(
      {required IEthAddress from,
      required Web3EthreumSendTransaction transaction,
      required EthereumChain chain}) async {
    final ReceiptAddress<ETHAddress>? destination = transaction.to != null
        ? chain.getReceiptAddress(transaction.to!.address) ??
            ReceiptAddress<ETHAddress>(
                view: transaction.to!.address, networkAddress: transaction.to!)
        : null;
    bool isSmartContract = false;
    EthereumTransactionDataInfo? contractInfos;
    if (transaction.to != null) {
      final bool isSmartContract = await isContract(transaction.to!);
      if (!isSmartContract) {
        return Web3EthereumTransactionRequestInfos(
            isContract: isSmartContract,
            transaction: transaction,
            destination: destination,
            contractInfo: transaction.data.isEmpty
                ? null
                : UnknownTransactionData.fromBytes(transaction.data));
      }
      contractInfos = await getTransactionContractInfo(
          account: from.networkAddress,
          contractAddress: transaction.to!,
          data: transaction.data,
          chain: chain);
    }
    if (transaction.to == null && transaction.data.isNotEmpty) {
      contractInfos ??= SolidityCreationContract();
    } else if (transaction.data.isNotEmpty) {
      contractInfos ??= UnknownTransactionData.fromBytes(transaction.data);
    }

    return Web3EthereumTransactionRequestInfos(
      isContract: isSmartContract,
      transaction: transaction,
      destination: destination,
      contractInfo: contractInfos,
    );
  }

  Future<BigInt> getChainId() async {
    return await provider.request(RPCGetChainId());
  }

  Future<dynamic> dynamicCall(String method, dynamic params) async {
    return await provider.requestDynamic(method, params);
  }

  @override
  Future<bool> onInit() async {
    if (network.type == NetworkType.ethereum) {
      final result = await MethodUtils.call(() async {
        final BigInt chainId = await provider.request(RPCGetChainId());
        return chainId;
      });
      return result.hasResult &&
          result.result == (network as WalletEthereumNetwork).coinParam.chainId;
    }
    return false;
  }
}

import 'package:blockchain_utils/bip/address/trx_addr.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ethereum/client/ethereum.dart';
import 'package:mrt_wallet/wallet/api/client/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/tron.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/others/others.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/on_chain.dart';

class TronClient extends NetworkClient<ITronAddress, TronAPIProvider>
    with CryptoWokerImpl {
  TronClient(
      {required this.provider,
      required this.solidityProvider,
      required this.network});
  TronChainParameters? _chainParamets;
  final TronProvider provider;
  final EthereumClient solidityProvider;
  @override
  final WalletTronNetwork network;
  @override
  BaseServiceProtocol<TronAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<TronAPIProvider>;

  @override
  Future<void> updateBalance(ITronAddress account) async {
    final tronAccount = await getAccount(account.networkAddress);
    account.address.updateBalance(tronAccount?.balance ?? BigInt.zero);
    account.setTronAccount(tronAccount);
    if (tronAccount != null) {
      await updateAccountResource(account);
    }
    await solidityProvider.updateAccountTokensBalance(account);
  }

  Future<TronAccountInfo?> getAccount(TronAddress account) async {
    final tronAccount =
        await provider.request(TronRequestGetAccountInfo(address: account));
    return tronAccount;
  }

  Future<void> updateIssueBalance(
      TronTRC10Token token, TronAddress account) async {
    final tronAccount =
        await provider.request(TronRequestGetAccountInfo(address: account));
    final tokenBalance =
        tronAccount?.assetV2.firstWhereOrNull((e) => e.key == token.tokenID);
    token.updateBalance(tokenBalance?.value);
  }

  Future<TronAccountResourceInfo> getAccountResource(
      TronAddress account) async {
    return await provider
        .request(TronRequestGetAccountResourceInfo(address: account));
  }

  Future<void> updateAccountResource(ITronAddress account) async {
    final accountResource = await getAccountResource(account.networkAddress);
    account.setAccountResource(accountResource);
  }

  Future<TronChainParameters> getChainParameters() async {
    _chainParamets ??= await provider.request(TronRequestGetChainParameters());
    return _chainParamets!;
  }

  Future<TronBlock> getNowBlock() async {
    final tronBlock = await provider.request(TronRequestGetNowBlock());
    return tronBlock;
  }

  Future<List<TronIssueTRC10Token>> getIssueAssetList() async {
    final tokens = await provider.request(TronRequestListOfIssueTRC10());
    return tokens;
  }

  Future<TronTRC10Token?> getIssueById(String id) async {
    final issue = await provider.request(TronRequestIssueById(id));
    if (issue == null) {
      return null;
    }
    return TronTRC10Token.create(
        balance: BigInt.zero,
        token: Token(
            name: issue.name,
            symbol: issue.abbr ?? issue.name,
            decimal: issue.precision ?? 0),
        tokenID: issue.id);
  }

  Future<ParsedBroadcastTransactionResult> sendTransaction(
      String digest) async {
    final result =
        await provider.request(TronRequestBroadcastHex(transaction: digest));
    return result;
  }

  Future<int> estimateContractEnergy(
      {required TronAddress ownerAddress,
      required TronAddress contractAddress,
      AbiFunctionFragment? fragment,
      required String data}) async {
    final energyRequired = await provider.request(
        TronRequestTriggerTRC20TransferContract(
            ownerAddress: ownerAddress,
            contractAddress: contractAddress,
            data: data,
            fragment: fragment));
    if (!energyRequired.isSuccess) {
      throw ApiProviderException(message: energyRequired.error);
    }
    return energyRequired.energyUsed!;
  }

  Future<int> estimateCreateContractEnergy(
      {required TronAddress ownerAddress, required String byteCode}) async {
    final energyRequired = await provider.request(
        TronRequestCreateContractEstimateEnergy(
            ownerAddress: ownerAddress, data: byteCode));
    if (!energyRequired.isSuccess) {
      throw ApiProviderException(message: energyRequired.error);
    }
    return energyRequired.energyUsed!;
  }

  Future<(MaxDelegatedResourceAmount, MaxDelegatedResourceAmount)>
      getMaxDelegatedEnergyAndBandwidth(ITronAddress address) async {
    final bandwidth = await provider.request(
        TronRequestGetCanDelegatedMaxSizeV2(
            ownerAddress: address.networkAddress,
            type: ResourceCode.bandWidth.value));
    final energy = await provider.request(TronRequestGetCanDelegatedMaxSizeV2(
        ownerAddress: address.networkAddress, type: ResourceCode.energy.value));
    return (energy, bandwidth);
  }

  Future<List<String>> getDelegatedResourceAddresses(
      ITronAddress address) async {
    final delegatedAddresses = await provider.request(
        TronRequestGetAccountDelegatedResourceAddresses(
            value: address.networkAddress));
    return delegatedAddresses;
  }

  Future<DelegatedAccountResourceInfo> getDelegatedResourceInfo(
      TronAddress from, TronAddress to) async {
    final details = await provider.request(
        TronRequestGetDelegatedResourceV2Details(
            fromAddress: from, toAddress: to));
    return details;
  }

  Future<Web3TronTransferInfo> getWeb3TransferContractInfo({
    required TransferContract contract,
    required TronChain chain,
  }) async {
    final destinationAddress = contract.toAddress.toAddress();
    return Web3TronTransferInfo(
        receiptAddress: chain.getReceiptAddress(destinationAddress) ??
            ReceiptAddress(
                view: destinationAddress, networkAddress: contract.toAddress),
        amount: contract.amount);
  }

  Future<Web3TronTransferAssetInfo> getWeb3TransferAssetContractInfo(
      {required TransferAssetContract contract,
      required TronChain chain}) async {
    final destinationAddress = contract.toAddress.toAddress();
    TronTRC10Token? token = await getIssueById(contract.assestId);
    if (token == null) {
      throw Web3RequestExceptionConst.invalidParameters(
          Web3TronExceptionConstant.trc10TokenNotFound);
    }
    await updateIssueBalance(token, contract.ownerAddress);
    return Web3TronTransferAssetInfo(
        token: token,
        receiptAddress: chain.getReceiptAddress(destinationAddress) ??
            ReceiptAddress(
                view: destinationAddress, networkAddress: contract.toAddress),
        amount: contract.amount);
  }

  Future<Web3TronTriggerSmartContract> getWeb3TriggerSmartContract({
    required TriggerSmartContract contract,
    required TronChain chain,
    // required ITronAddress owner,
  }) async {
    Web3TronTransferInfo? transfer;
    Web3TronTransferAssetInfo? transferAssets;
    if (contract.callValue != null) {
      transfer = await getWeb3TransferContractInfo(
          contract: TransferContract(
              ownerAddress: contract.ownerAddress,
              toAddress: contract.contractAddress,
              amount: contract.callValue!),
          chain: chain);
    }
    if (contract.callTokenValue != null) {
      transferAssets = await getWeb3TransferAssetContractInfo(
          chain: chain,
          contract: TransferAssetContract(
              assetName: StringUtils.encode(contract.tokenId!.toString()),
              ownerAddress: contract.ownerAddress,
              toAddress: contract.contractAddress,
              amount: contract.callTokenValue!));
    }
    final data = await solidityProvider.getTransactionContractInfo(
        account: contract.ownerAddress,
        contractAddress: contract.contractAddress,
        chain: chain,
        data: contract.data ?? []);
    final contractAddress = contract.contractAddress;
    return Web3TronTriggerSmartContract(
        value: transfer,
        callValue: transferAssets,
        contractAddress: chain.getReceiptAddress(contractAddress.toAddress()) ??
            ReceiptAddress(
                view: contractAddress.toAddress(),
                networkAddress: contractAddress),
        dataInfo: data);
  }

  Future<Web3TronCreateContractInfo> getWeb3CreateSmartContract(
      {required CreateSmartContract contract,
      required TronChain chain,
      required String txId}) async {
    Web3TronTransferInfo? transfer;
    Web3TronTransferAssetInfo? transferAssets;
    if (contract.newContract.callValue != null) {
      transfer = await getWeb3TransferContractInfo(
          contract: TransferContract(
              ownerAddress: contract.ownerAddress,
              toAddress: contract.newContract.contractAddress ??
                  contract.newContract.originAddress,
              amount: contract.newContract.callValue!),
          chain: chain);
    }
    if (contract.hasTokenTransfer) {
      transferAssets = await getWeb3TransferAssetContractInfo(
          chain: chain,
          contract: TransferAssetContract(
              assetName: StringUtils.encode(contract.tokenId!.toString()),
              ownerAddress: contract.ownerAddress,
              toAddress: contract.newContract.contractAddress ??
                  contract.newContract.originAddress,
              amount: contract.callTokenValue!));
    }
    final contractAddressHash = await crypto
        .generateHash(type: CryptoRequestHashingType.keccack256, dataBytes: [
      ...BytesUtils.fromHexString(txId),
      ...contract.ownerAddress.toBytes(),
    ]);

    return Web3TronCreateContractInfo(
        value: transfer,
        callValue: transferAssets,
        contractAddress: TronAddress.fromBytes([
          ...TrxAddressUtils.prefix,
          ...contractAddressHash.sublist(0, ETHAddress.lengthInBytes)
        ]));
  }

  Future<Web3TronTransactionInfo> getWeb3TransactionInfo(
      {required TransactionRaw transaction, required TronChain chain}) async {
    final type = transaction.type;
    switch (type) {
      case TransactionContractType.transferContract:
        final contract = transaction.getContract<TransferContract>();
        return getWeb3TransferContractInfo(contract: contract, chain: chain);
      case TransactionContractType.transferAssetContract:
        final contract = transaction.getContract<TransferAssetContract>();
        return getWeb3TransferAssetContractInfo(
            contract: contract, chain: chain);
      case TransactionContractType.triggerSmartContract:
        final contract = transaction.getContract<TriggerSmartContract>();
        return getWeb3TriggerSmartContract(contract: contract, chain: chain);
      case TransactionContractType.createSmartContract:
        final contract = transaction.getContract<CreateSmartContract>();
        return getWeb3CreateSmartContract(
            contract: contract, chain: chain, txId: transaction.txID);
      case TransactionContractType.freezeBalanceV2Contract:
        final contract = transaction.getContract<FreezeBalanceV2Contract>();
        return Web3TronFreezeBalanceInfo(
            resource: contract.resource ?? ResourceCode.bandWidth,
            amount: contract.frozenBalance);
      default:
        final contract = transaction.getContract();
        final totalTrxAmount = contract.trxAmount == BigInt.zero
            ? null
            : IntegerBalance(contract.trxAmount, chain.network.coinDecimal);
        return Web3TronUnknowContractInfo(
            contractFields: transaction.getContract().toJson(),
            totalTrxAmount: totalTrxAmount);
    }
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call<String>(() async {
      final block = await provider.request(TronRequestGetBlockByNum(num: 0));
      return block["blockID"];
    });
    return result.hasResult && result.result == network.coinParam.genesis;
  }
}

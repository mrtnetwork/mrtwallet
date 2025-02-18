import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/aptos.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/constant/chain/const.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/aptos/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:on_chain/aptos/aptos.dart';

class AptosClient extends NetworkClient<IAptosAddress, AptosAPIProvider> {
  final AptosProvider provider;
  @override
  final WalletAptosNetwork? network;
  AptosClient({required this.provider, this.network});
  @override
  AptosHTTPService get service => provider.rpc as AptosHTTPService;

  @override
  ProviderIdentifier get serviceIdentifier => AptosProviderIdentifier(
      fullNodeIdentifier: service.provider.identifier,
      graphQlIdentifier: service.graphQlProvider.identifier);

  Future<BigInt> _getAccountBalance(AptosAddress address) async {
    final r = await provider.request(
        AptosRequestExecuteViewFunctionOfaModule<BigInt>.bcs(
            entry: AptosTransactionEntryFunction(
                moduleId:
                    AptosModuleId(address: AptosAddress.one, name: "coin"),
                functionName: "balance",
                typeArgs: [
          AptosTypeTagStruct(AptosStructTag(
              address: AptosAddress.one,
              moduleName: "aptos_coin",
              name: "AptosCoin"))
        ],
                args: [
          address
        ])));
    return r.first;
  }

  @override
  Future<void> updateBalance(
      IAptosAddress address, APPCHAINACCOUNT<IAptosAddress> chain) async {
    final balance = await _getAccountBalance(address.networkAddress);
    chain.updateAddressBalance(address: address, updateBalance: balance);
    final updated = await _updateFtBalance(address, chain);
    final tokens = address.tokens.where((e) => !updated.contains(e.assetType));
    for (final i in tokens) {
      MethodUtils.call(() async {
        final balance = await provider.request(
            AptosRequestGetAccountAssetResources(
                address: address.networkAddress, assetType: i.assetType));
        i.updateBalance(balance);
      });
    }
  }

  Future<List<String>> _updateFtBalance(
      IAptosAddress address, APPCHAINACCOUNT<IAptosAddress> chain) async {
    List<String> updated = [];
    try {
      const limit = 1;
      int offset = 0;
      while (true) {
        final r = await provider.request(
            AptosGraphQLRequestGetCurrentFungibleAssetBalances(
                variables:
                    AptosGraphQLPaginatedVariablesParams(whereCondition: {
          "owner_address": {"_eq": address.networkAddress.address},
          "asset_type": {
            "_in": address.tokens.map((e) => e.assetType).toList(),
            "_nin": updated
          }
        }, limit: limit, offset: offset)));
        for (final i in r) {
          final amount = BigintUtils.tryParse(i.amount);
          if (i.ownerAddress != address.networkAddress.address) {
            final ownerAddress = AptosAddress(i.ownerAddress);
            if (ownerAddress != address.networkAddress) continue;
          }
          final token = address.tokens
              .firstWhereOrNull((e) => e.assetType == i.assetType);
          if (amount == null || token == null) continue;
          token.updateBalance(amount);
          token.setFreeze(i.isFrozen);
          updated.add(i.assetType!);
        }
        if (r.length < limit || offset * limit > ChainConst.maxAccountTokens) {
          break;
        }
        offset++;
      }
      return updated;
    } catch (_) {
      return updated;
    }
  }

  Future<List<AptosFATokens>> getAccountFTTokens(AptosAddress address) async {
    const limit = 50;
    int offset = 0;
    List<AptosFATokens> tokens = [];
    List<String> nIn = [AptosConstants.aptosCoinAssetType];
    while (true) {
      final r = await provider
          .request(AptosGraphQLRequestGetCurrentFungibleAssetBalances(
              variables: AptosGraphQLPaginatedVariablesParams(whereCondition: {
        "owner_address": {"_eq": address.address},
        "asset_type": {"_nin": nIn}
      }, limit: limit, offset: offset)));
      final metadata =
          await provider.request(AptosGraphQLRequestGetFungibleAssetMetadata(
              variables: AptosGraphQLPaginatedVariablesParams(whereCondition: {
        "asset_type": {"_in": r.map((e) => e.assetType).toList()}
      })));

      for (final i in metadata) {
        final token = r.firstWhereOrNull((e) => e.assetType == i.assetType);
        if (token == null ||
            token.assetType == AptosConstants.aptosCoinAssetType) {
          continue;
        }
        final ftToken = AptosFATokens.create(
            balance: BigintUtils.parse(token.amount),
            token: Token(
                name: i.name,
                symbol: i.symbol,
                decimal: i.decimals,
                assetLogo: APPImage.network(i.iconUri)),
            assetType: i.assetType,
            isFreeze: token.isFrozen);
        tokens.add(ftToken);
      }
      if (r.length < limit || offset * limit > ChainConst.maxAccountTokens) {
        break;
      }
      offset++;
      nIn.addAll(r.where((e) => e.assetType != null).cast());
    }

    return tokens;
  }

  Future<BigInt> getAccountSequence(AptosAddress address) async {
    final r = await provider.request(AptosRequestGetAccount(address: address));
    return r.sequenceNumber;
  }

  Future<BigInt> getGasUnitPrice() async {
    final r = await provider.request(AptosRequestEstimateGasPrice());
    return BigInt.from(r.gasEstimate);
  }

  AptosTransactionAuthenticator _buildSimulateAuthenticator({
    AptosAddress? feePayer,
    List<AptosAddress>? secondarySignerAddresses,
  }) {
    if (feePayer == null && secondarySignerAddresses == null) {
      return AptosTransactionAuthenticatorSignleSender(
          AptosAccountAuthenticatorNoAccountAuthenticator());
    } else if (feePayer != null) {
      return AptosTransactionAuthenticatorFeePayer(
          sender: AptosAccountAuthenticatorNoAccountAuthenticator(),
          feePayerAddress: feePayer,
          feePayerAuthenticator:
              AptosAccountAuthenticatorNoAccountAuthenticator(),
          secondarySignerAddressess: secondarySignerAddresses ?? [],
          secondarySigner: secondarySignerAddresses
                  ?.map(
                      (e) => AptosAccountAuthenticatorNoAccountAuthenticator())
                  .toList() ??
              []);
    }
    return AptosTransactionAuthenticatorMultiAgent(
        sender: AptosAccountAuthenticatorNoAccountAuthenticator(),
        secondarySignerAddressess: secondarySignerAddresses ?? [],
        secondarySigner: secondarySignerAddresses
                ?.map((e) => AptosAccountAuthenticatorNoAccountAuthenticator())
                .toList() ??
            []);
  }

  Future<AptosApiUserTransaction> simulateTransaction(
      {required AptosRawTransaction rawTransaction,
      AptosAddress? feePayer,
      List<AptosAddress>? secondarySignerAddresses}) async {
    final authenticator = _buildSimulateAuthenticator(
        feePayer: feePayer, secondarySignerAddresses: secondarySignerAddresses);
    final signedTransaction = AptosSignedTransaction(
        rawTransaction: rawTransaction, authenticator: authenticator);
    final r = await provider.request(AptosRequestSimulateTransaction(
        signedTransactionData: signedTransaction.toBcs(),
        estimateMaxGasAmount: true,
        estimateGasUnitPrice: true));
    return r.first;
  }

  Future<(String, bool)> submitTransaction(
      AptosSignedTransaction signedTx) async {
    final r = await provider.requestDynamic(
        AptosRequestSubmitTransaction(signedTransactionData: signedTx.toBcs()));
    final String? txHash = r["hash"]?.toString();
    return (txHash ?? signedTx.txHash(), txHash != null);
  }

  Future<int> getChainId() async {
    final chainId = await provider.request(AptosRequestGetLedgerInfo());
    return chainId.chainId;
  }

  Future<bool> validateGraphQl() async {
    final chainId = await provider.request(AptosGraphQLRequestChainId());
    return chainId == network?.coinParam.aptosChainType.chainId;
  }

  Future<bool> validateFullNode() async {
    final chainId = await getChainId();
    return chainId == network?.coinParam.aptosChainType.chainId;
  }

  @override
  Future<bool> onInit() async {
    final fullNode = await validateFullNode();
    if (fullNode) return await validateGraphQl();
    return false;
  }

  @override
  NetworkType get networkType => NetworkType.aptos;
}

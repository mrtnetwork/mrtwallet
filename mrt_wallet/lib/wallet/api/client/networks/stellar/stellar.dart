import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/stellar.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/stellar/addresses/stellar.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarClient extends NetworkClient<IStellarAddress, StellarAPIProvider> {
  StellarClient({required this.provider, required this.network});
  final HorizonProvider provider;
  @override
  final WalletStellarNetwork network;
  @override
  BaseServiceProtocol<StellarAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<StellarAPIProvider>;

  @override
  Future<void> updateBalance(IStellarAddress account,
      {bool updateTokens = true}) async {
    await getAccountFromIStellarAddress(account);
  }

  Future<StellarAccountResponse?> getAccount(StellarAddress address) async {
    try {
      return await provider.request(HorizonRequestAccount(address.baseAddress));
    } on HorizonAPIError catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  void _updateAccountTokensBalances(
      {required IStellarAddress account,
      required StellarAccountResponse accountInfo}) {
    final balance = accountInfo.balances
        .whereType<StellarNativeBalanceResponse>()
        .fold(BigInt.zero, (p, c) => p + c.unlockedBalance);
    account.address.updateBalance(balance);
    for (final i in account.tokens) {
      final balance = accountInfo.getAssetByIssueAsset(i);
      if (balance == null) {
        i.updateBalance(BigInt.zero);
      } else {
        i.updateBalance(balance.unlockedBalance);
      }
    }
  }

  StellarReceiptWithActivityStatus _getOrCreateReceiptAddress(
      {required StellarAddress address, required StellarChain chain}) {
    final ReceiptAddress<StellarAddress> receiptAddress =
        chain.getReceiptAddress(address.toString()) ??
            ReceiptAddress<StellarAddress>(
                view: address.toString(), networkAddress: address);
    return StellarReceiptWithActivityStatus(receiptAddress);
  }

  IntegerBalance? _getAssetBalance(
      {required StellarAsset asset,
      required StellarAccountResponse signerAccountInfo}) {
    if (asset.type == AssetType.poolShare) return null;
    if (asset.type == AssetType.native) {
      return IntegerBalance(
          signerAccountInfo.nativeBalance, network.coinDecimal);
    }
    final assetBalances = signerAccountInfo.getAsset(asset);
    if (assetBalances != null) {
      WalletLogging.log(
          "find amount ${assetBalances.unlockedBalance} ${asset.type} ${asset.toJson()}");
      WalletLogging.log("${signerAccountInfo.toJson()}");
      return IntegerBalance(assetBalances.unlockedBalance, network.coinDecimal);
    }
    return null;
  }

  Future<StellarWeb3TransactionDetails> getWeb3TransactionInfo(
      {required Envelope envlope,
      required StellarChain chain,
      required IStellarAddress signer,
      required StellarAccountResponse signerAccountInfo}) async {
    final tx = envlope.tx;
    final IntegerBalance fee = IntegerBalance.zero(network.coinDecimal);
    final StellarTransactionV1 transaction;
    final StellarAddress source;
    StellarWeb3TransactionType type = StellarWeb3TransactionType.v1;
    if (tx.type == EnvelopeType.txFeeBump) {
      final feebumpTx = tx.cast<StellarFeeBumpTransaction>();
      transaction = feebumpTx.innerTx.tx;
      fee.updateBalance(feebumpTx.fee);
      type = StellarWeb3TransactionType.feeBump;
      source = feebumpTx.feeSource.address;
    } else {
      transaction = tx.cast<StellarTransactionV1>();
      fee.updateBalance(BigInt.from(transaction.fee));
      source = transaction.sourceAccount.address;
    }
    StellarSorobanTransactionDetais? soroban;
    if (transaction.sorobanData.sorobanTransactionData != null) {
      soroban = StellarSorobanTransactionDetais(
          sorobanData: transaction.sorobanData.sorobanTransactionData!,
          network: network);
    }
    final memo = StellarMemoDetils(transaction.memo);
    final List<StellarTransactionOperationDetails> baseOperation = [];
    for (final i in tx.operations) {
      final sourceAccount = i.sourceAccount?.address == null
          ? null
          : _getOrCreateReceiptAddress(
              address: i.sourceAccount!.address, chain: chain);
      final OperationBody body = i.body;
      final bool isSigner = signer.networkAddress.baseAddress ==
          (sourceAccount?.address.networkAddress.baseAddress ??
              source.baseAddress);
      WalletLogging.log("is signer $isSigner");
      switch (body.operationType) {
        case OperationType.changeTrust:
          final operation = body.cast<ChangeTrustOperation>();

          /// issueToken:isSigner?signerAccountInfo.getAsset(asset)
          final info = StellarChangeTrustOperation(
              asset: StellarPickedIssueAsset(
                asset: operation.asset,
                network: network,
                issueToken: null,
              ),
              limit: IntegerBalance(operation.limit, network.coinDecimal));
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info, sourceAccount: sourceAccount));
          break;
        case OperationType.payment:
          final operation = body.cast<PaymentOperation>();
          final info = StellarPaymentOperation(
            destination: _getOrCreateReceiptAddress(
                address: operation.destination.address, chain: chain),
            asset: StellarPickedIssueAsset(
                asset: operation.asset,
                network: network,
                issueToken: null,
                tokenBalance: isSigner
                    ? _getAssetBalance(
                        asset: operation.asset,
                        signerAccountInfo: signerAccountInfo)
                    : null),
            amount: IntegerBalance(operation.amount, network.coinDecimal),
          );
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info, sourceAccount: sourceAccount));
          break;
        case OperationType.createAccount:
          final operation = body.cast<CreateAccountOperation>();
          final info = StellarCreateAccountOperation(
            destination: _getOrCreateReceiptAddress(
                address: operation.destination.toAddress(), chain: chain),
            asset: StellarPickedIssueAsset(
                asset: StellarAssetNative(),
                network: network,
                issueToken: null,
                tokenBalance: isSigner
                    ? _getAssetBalance(
                        asset: StellarAssetNative(),
                        signerAccountInfo: signerAccountInfo)
                    : null),
            startingBalance:
                IntegerBalance(operation.startingBalance, network.coinDecimal),
          );
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info));
          break;
        case OperationType.pathPaymentStrictReceive:
          final operation = body.cast<PathPaymentStrictReceiveOperation>();
          final info = StellarPathPaymentStrictReceiveOperation(
              destination: _getOrCreateReceiptAddress(
                  address: operation.destination.address, chain: chain),
              asset: StellarPickedIssueAsset(
                  asset: operation.sendAsset,
                  network: network,
                  issueToken: null,
                  tokenBalance: isSigner
                      ? _getAssetBalance(
                          asset: operation.sendAsset,
                          signerAccountInfo: signerAccountInfo)
                      : null),
              destAsset: StellarPickedIssueAsset(
                  asset: operation.destAsset,
                  network: network,
                  issueToken: null),
              destAmount:
                  IntegerBalance(operation.destAmount, network.coinDecimal),
              sendAmount:
                  IntegerBalance(operation.sendMax, network.coinDecimal),
              paths: operation.path
                  .map((e) => StellarPickedIssueAsset(
                      asset: e, network: network, issueToken: null))
                  .toList());
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info, sourceAccount: sourceAccount));
          break;
        case OperationType.pathPaymentStrictSend:
          final operation = body.cast<PathPaymentStrictSendOperation>();
          final info = StellarPathPaymentStrictSendOperation(
              destination: _getOrCreateReceiptAddress(
                  address: operation.destination.address, chain: chain),
              asset: StellarPickedIssueAsset(
                  asset: operation.sendAsset,
                  network: network,
                  issueToken: null,
                  tokenBalance: isSigner
                      ? _getAssetBalance(
                          asset: operation.sendAsset,
                          signerAccountInfo: signerAccountInfo)
                      : null),
              destAsset: StellarPickedIssueAsset(
                  asset: operation.destAsset,
                  network: network,
                  issueToken: null),
              destMin: IntegerBalance(operation.destMin, network.coinDecimal),
              sendAmount:
                  IntegerBalance(operation.sendAmount, network.coinDecimal),
              paths: operation.path
                  .map((e) => StellarPickedIssueAsset(
                      asset: e, network: network, issueToken: null))
                  .toList());
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info, sourceAccount: sourceAccount));
          break;
        case OperationType.manageBuyOffer:
          final operation = body.cast<ManageBuyOfferOperation>();
          final info = StellarManageBuyOfferOperation(
              asset: StellarPickedIssueAsset(
                  asset: operation.selling, network: network, issueToken: null),
              buying: StellarPickedIssueAsset(
                  asset: operation.buying, network: network, issueToken: null),
              price: operation.price,
              amount: IntegerBalance(operation.buyAmount, network.coinDecimal),
              offerId: operation.offerId,
              value: BigInt.zero);
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info, sourceAccount: sourceAccount));
          break;
        case OperationType.manageSellOffer:
          final operation = body.cast<ManageSellOfferOperation>();
          final info = StellarManageSellOfferOperation(
              asset: StellarPickedIssueAsset(
                  asset: operation.selling, network: network, issueToken: null),
              buying: StellarPickedIssueAsset(
                  asset: operation.buying, network: network, issueToken: null),
              price: operation.price,
              amount: IntegerBalance(operation.amount, network.coinDecimal),
              offerId: operation.offerId);
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, operationInfo: info, sourceAccount: sourceAccount));
          break;
        default:
          baseOperation.add(StellarTransactionOperationDetails(
              operation: i, sourceAccount: sourceAccount));
          break;
      }
    }
    return StellarWeb3TransactionDetails(
        memo: memo,
        fee: fee,
        source: _getOrCreateReceiptAddress(address: source, chain: chain),
        contentStr: StringUtils.fromJson(envlope.toJson(),
            indent: '  ', toStringEncodable: true),
        type: type,
        operations: baseOperation,
        soroban: soroban);
  }

  Future<StellarAccountResponse?> getAccountFromIStellarAddress(
      IStellarAddress account) async {
    try {
      final result = await provider
          .request(HorizonRequestAccount(account.networkAddress.baseAddress));
      _updateAccountTokensBalances(account: account, accountInfo: result);
      return result;
    } on HorizonAPIError catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  Future<StellarAllTransactionResponse> submitTx(String envelopeXdr) async {
    return await provider.request(HorizonRequestSubmitTransaction(envelopeXdr));
  }

  Future<int> getBaseReserve() async {
    final result = await provider.request(const HorizonRequestLedgers());
    return result.first.baseReserveInStroops;
  }

  Future<StellarFeeStatsResponse> feeState() async {
    final result = await provider.request(const HorizonRequestFeeStats());
    return result;
  }

  Future<String> passphrase() async {
    final result = await provider.request(SorobanRequestGetNetwork());
    return result.passphrase;
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() async => await passphrase());
    return result.hasResult && result.result == network.coinParam.passphrase;
  }
}

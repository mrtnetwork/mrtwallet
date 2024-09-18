import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/derivation/bip32.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/tron.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/tron/addresses/tron.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/tron.dart';
import 'package:mrt_wallet/wallet/models/others/others.dart';
import 'package:mrt_wallet/wallet/models/signing/signing.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronTransactionRequestController
    extends Web3TronImpl<Map<String, dynamic>, Web3TronSendTransaction> {
  TronFee? _consumedFee;
  TronFee? get consumedFee => _consumedFee;
  @override
  late final LiveTransactionForm<Web3TronReadOnlyForm<Web3TronSendTransaction>>
      // ignore: overridden_fields
      liveRequest;

  Web3TronTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);

  late final IntegerBalance ownerBalance =
      IntegerBalance.zero(network.coinDecimal);

  late final Web3TronTransactionInfo info;
  late final ReceiptAddress<TronAddress> owner;
  IntegerBalance? _feeLimit;
  IntegerBalance? get feeLimit => _feeLimit;
  String? _memo;
  String? get memo => _memo;

  Transaction get transaction => request.params.transaction;
  TransactionContractType get type => transaction.rawData.type;
  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;

  late (IntegerBalance, Token) remindAmount;

  bool _checkTransaction() {
    final transactionValue = info.totalTrxAmount?.balance ?? BigInt.zero;
    final remindTrx = ownerBalance.balance -
        (transactionValue + consumedFee!.totalBurn.balance);
    remindAmount =
        (IntegerBalance(remindTrx, network.coinDecimal), network.token);
    if (!remindAmount.$1.isNegative) {
      if (info.transferAsset != null) {
        final remindTokenAmounts =
            info.transferAsset!.token.balance.value.balance -
                info.transferAsset!.amount.balance;
        if (remindTokenAmounts.isNegative) {
          remindAmount = (
            IntegerBalance(
                remindTokenAmounts, info.transferAsset!.token.token.decimal!),
            info.transferAsset!.token.token
          );
        }
      }
      if (info.trc20Transfer != null && !remindAmount.$1.isNegative) {
        final remindTokenAmounts =
            info.trc20Transfer!.token.balance.value.balance -
                info.trc20Transfer!.value.balance;
        if (remindTokenAmounts.isNegative) {
          remindAmount = (
            IntegerBalance(
                remindTokenAmounts, info.trc20Transfer!.token.token.decimal!),
            info.trc20Transfer!.token.token
          );
        }
      }
    }

    return !remindAmount.$1.isNegative;
  }

  Future<TronAccountResourceInfo> _initNetworkCondition(
      TransactionContractType type) async {
    final result = await MethodUtils.call(() async {
      final account =
          await apiProvider.getAccount(transaction.rawData.ownerAddress);

      if (account == null) {
        return (null, TronAccountResourceInfo.empty());
      }
      final accountResource = await apiProvider
          .getAccountResource(transaction.rawData.ownerAddress);
      return (account, accountResource);
    });
    if (result.hasError) {
      return TronAccountResourceInfo.empty();
    }
    ownerBalance.updateBalance(result.result.$1?.balance);
    return result.result.$2;
  }

  Future<TronFee> _calcuateFee(
      {required Web3TronTransactionInfo transactionInfo,
      required Transaction transaction,
      required TronAccountResourceInfo resource}) async {
    final chainParameters = await apiProvider.getChainParameters();

    int signer = 1;
    int energy = 0;
    // int? permissionId;
    bool isNewAccount = false;
    final dstAccount = transactionInfo.destination;
    if (transactionInfo.isTransferContract && dstAccount != null) {
      final accountInfo =
          await apiProvider.getAccount(dstAccount.networkAddress);
      isNewAccount = accountInfo == null;
    }
    if (address.multiSigAccount) {
      final multiSigAccount = address as ITronMultisigAddress;
      signer = multiSigAccount.keyDetails.length;
    }
    if (transactionInfo.isSmartContract) {
      final contract = transaction.rawData.getContract<TriggerSmartContract>();
      energy = await apiProvider.estimateContractEnergy(
        ownerAddress: contract.ownerAddress,
        contractAddress: contract.contractAddress,
        data: BytesUtils.toHexString(contract.data ?? []),
      );
    }
    if (transactionInfo.isCreateContract) {
      final contract = transaction.rawData.getContract<CreateSmartContract>();
      energy = await apiProvider.estimateCreateContractEnergy(
          ownerAddress: contract.ownerAddress,
          byteCode: BytesUtils.toHexString(contract.newContract.bytecode));
    }
    return TronFee.calculate(
        raw: transaction.rawData,
        chainParameters: chainParameters,
        resource: resource,
        hasMemo: transaction.rawData.data?.isNotEmpty ?? false,
        signature: signer,
        consumedEnergy: energy,
        isNewAccount: isNewAccount);
  }

  Future<void> _initializeTransaction() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final resource = await _initNetworkCondition(transaction.rawData.type);
    final contractOwner = transaction.rawData.ownerAddress;
    owner = account.getReceiptAddress(contractOwner.toAddress()) ??
        ReceiptAddress<TronAddress>(
            view: contractOwner.toAddress(), networkAddress: contractOwner);
    final transactionInfo = await MethodUtils.call(() async =>
        await apiProvider.getWeb3TransactionInfo(
            transaction: transaction.rawData, chain: account));
    if (address.multiSigAccount) {
      final multiSigAddress = address as ITronMultisigAddress;
      if (transaction.rawData.permissionId() !=
          multiSigAddress.multiSignatureAccount.permissionID) {
        progressKey.error(
            text: "tron_account_permission_not_access_desc".tr,
            backToIdle: null);
        return;
      }
    }

    if (transactionInfo.hasError) {
      progressKey.error(text: transactionInfo.error!.tr, backToIdle: null);
    } else {
      final fee = await MethodUtils.call(() => _calcuateFee(
          transactionInfo: transactionInfo.result,
          transaction: request.params.transaction,
          resource: resource));
      if (fee.hasError) {
        progressKey.error(text: fee.error!.tr, backToIdle: null);
        return;
      }
      info = transactionInfo.result;
      _consumedFee = fee.result;
      if (transaction.rawData.feeLimit != null) {
        _feeLimit =
            IntegerBalance(transaction.rawData.feeLimit!, network.coinDecimal);
      }
      if (transaction.rawData.data?.isNotEmpty ?? false) {
        _memo = StringUtils.tryDecode(transaction.rawData.data) ??
            BytesUtils.toHexString(transaction.rawData.data!);
      }
      liveRequest = LiveTransactionForm(
          validator:
              Web3TronReadOnlyForm<Web3TronSendTransaction>(request: request));
      _trIsReady = _checkTransaction();
      progressKey.idle();
    }
  }

  Future<void> confirmTransaction() async {
    progressKey.process(
        text: "create_send_transaction"
            .tr
            .replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      final WalletSigningRequest<List<List<int>>> request =
          WalletSigningRequest<List<List<int>>>(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final List<int> transactionDigest =
              List<int>.unmodifiable(transaction.rawData.toBuffer());
          if (address.multiSigAccount) {
            final multiSigAddress = address as ITronMultisigAddress;
            final List<List<int>> signerSignatures = [];
            BigInt threshHold = BigInt.zero;
            for (final i in multiSigAddress.multiSignatureAccount.signers) {
              try {
                final signRequest = GlobalSignRequest.tron(
                    digest: transactionDigest, index: i.keyIndex);
                final response = await generateSignature(signRequest);
                signerSignatures.add(response.signature);
                threshHold += i.weight;
                if (threshHold >=
                    multiSigAddress.multiSignatureAccount.threshold) {
                  break;
                }
              } catch (_) {
                continue;
              }
            }
            if (threshHold < multiSigAddress.multiSignatureAccount.threshold) {
              throw WalletExceptionConst.privateKeyIsNotAvailable;
            }
            return signerSignatures;
          }
          final signRequest = GlobalSignRequest.tron(
              digest: transactionDigest,
              index: address.keyIndex as Bip32AddressIndex);
          final response = await generateSignature(signRequest);
          return [response.signature];
        },
      );

      final signature =
          await walletProvider.wallet.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      final tr = Transaction(
          rawData: transaction.rawData, signature: signature.result);
      return await apiProvider.sendTransaction(tr.toHex);
    });
    if (result.hasError) {
      progressKey.error(text: result.error!.tr);
    } else if (result.result.isSuccess) {
      progressKey.responseTx(hash: result.result.txId!, network: network);
      request.completeResponse(result.result.respose);
    } else {
      progressKey.error(text: result.result.error, backToIdle: null);
      request.error(Web3RequestExceptionConst.failedRequest(
          result.result.error!,
          dataJson: result.result.respose));
    }
  }

  @override
  Future<void> readyWeb3() async {
    await super.readyWeb3();
    _initializeTransaction();
  }
}

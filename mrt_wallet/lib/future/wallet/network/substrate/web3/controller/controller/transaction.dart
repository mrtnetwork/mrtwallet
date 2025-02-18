import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/substrate/substrate.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/impl/signer_impl.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/controller/impl/impl.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/models/metadata.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/models/metadata_fields.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateTransactionRequestController extends Web3SubstrateImpl<
    Map<String, dynamic>,
    Web3SubstrateSendTransaction> with SubstrateFeeImpl, SubstrateSignerImpl {
  Web3SubstrateTransactionRequestController({
    required super.walletProvider,
    required super.request,
  }) : super(account: request.chain);
  Web3SubstrateSendTransaction get transaction => request.params;
  SubstrateChainMetadata get metadata => apiProvider.metadata;

  late final ExtrinsicPayloadInfo _extrinsicInfo;
  ExtrinsicPayloadInfo get extrinsicInfo => _extrinsicInfo;

  @override
  Web3SubstrateSendTransactionForm get form =>
      liveRequest.validator as Web3SubstrateSendTransactionForm;

  Future<ExtrinsicPayloadInfo> _init() async {
    try {
      if (transaction.specVersion != metadata.specVersion) {
        throw Web3SubstrateExceptionConstant.invalidTransactionSpecVersion;
      }
      if (!BytesUtils.bytesEqual(
          transaction.genesisHash, metadata.genesisBytes())) {
        throw Web3SubstrateExceptionConstant.invalidTransactionGenesisHash;
      }
      final decode =
          metadata.metadata.decodeCall<Map<String, dynamic>>(transaction.call);
      final era = MortalEra(index: transaction.era[0], era: transaction.era[1]);
      final extrinsic = SubstrateDefaultExtrinsic(
          era: era,
          nonce: transaction.nonce,
          specVersion: metadata.runtimeVersion.specVersion,
          transactionVersion: metadata.runtimeVersion.transactionVersion,
          genesis: transaction.genesisHash,
          mortality: transaction.blockHash,
          tip: transaction.tip,
          metadataHash: transaction.metadataHash,
          assetId: transaction.assetId);
      final extraFields = extrinsic.encode(
          fields: metadata.extrinsic.extrinsicPayloadValidators,
          metadata: metadata.metadata);
      final List<int> serializedExtrinsic =
          [...transaction.call, ...extraFields].asImmutableBytes;
      return ExtrinsicPayloadInfo(
          serializedExtrinsic: serializedExtrinsic,
          method: transaction.call,
          payloadInfo: decode,
          extrinsic: extrinsic);
    } on Web3RequestExceptionConst {
      rethrow;
    } catch (e) {
      throw Web3SubstrateExceptionConstant.transactionSerializationFailed;
    }
  }

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final r = await MethodUtils.call(() => _init());
    if (r.hasError) {
      progressKey.errorResponse(error: r.exception);
      request.error(Web3RequestExceptionConst.fromException(r.exception!));
      return;
    }
    _extrinsicInfo = r.result;
    progressKey.idle();
    estimateFee();
  }

  Future<ExtrinsicInfo> _buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature}) async {
    List<int> signature;
    if (onGenerateSignature == null) {
      signature = SubstrateUtils.createFakeSignature(address.coin.conf.type);
    } else {
      signature = await onGenerateSignature(_extrinsicInfo.payloadBytes);
    }
    return metadata.createExtrinsic(
        signature: signature,
        address: address.networkAddress,
        algorithm: address.keyIndex.currencyCoin.conf.type,
        payload: _extrinsicInfo);
  }

  @override
  Future<ExtrinsicInfo> buildEstimateTransaction() async {
    final extrinsic = await _buildAndSignTransaction();
    return extrinsic;
  }

  @override
  Future<ExtrinsicInfo> buildAndSignTransaction({
    ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
    required ISubstrateAddress address,
    List<String> memos = const [],
  }) async {
    return await _buildAndSignTransaction(
        onGenerateSignature: onGenerateSignature);
  }

  Future<void> signAndSendTransaction() async {
    progressKey.process(
        text: "create_send_transaction"
            .tr
            .replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      return await signTransaction(address: address, network: network);
    });

    if (result.hasError) {
      progressKey.error(error: result.exception, showBackButton: true);
    } else {
      request.completeResponse(Web3SubstrateSendTransactionResponse(
              signature: result.result.signature!,
              signedTransaction: result.result.serialize())
          .toJson());
      progressKey.response(text: 'transaction_signed'.tr);
    }
  }
}

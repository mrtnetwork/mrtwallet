import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/transaction/controller/impl/memo_impl.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/core/cosmos.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

typedef ONUPDATECOSMOSGASLIMIT = Future<BigRational?> Function(
    BigRational gasLimit);
typedef ONCHANGEFEETOKEN = Future<CW20Token?> Function(
    List<CW20Token> tokens, WalletCosmosNetwork network);
typedef ONCHANGEFEEAMOUNT = Future<BigInt?> Function(Token token, BigInt? max);

class Web3CosmosSendTransactionForm
    extends CosmosWeb3Form<Web3CosmosSignTransaction> {
  Web3CosmosSendTransactionForm({required this.request});
  @override
  Web3CosmosRequest<Web3CosmosSignTransactionResponse,
      Web3CosmosSignTransaction> request;
  BigInt? _accountNumber;
  bool get showSimulate => _txBody != null;
  CosmosWeb3SimulateInfos? _simulateTxContent;
  CosmosWeb3SimulateInfos? get simulateContent => _simulateTxContent;
  StreamWidgetStatus _status = StreamWidgetStatus.progress;
  StreamWidgetStatus get status => _status;
  final GlobalKey<StreamWidgetState> simulateProgressKey = GlobalKey();
  final Cancelable _cancelable = Cancelable();
  String? _simulateError;
  String? get simulateError => _simulateError;
  AuthInfo? _authInfo;
  List<CosmosWeb3MessagesInfo> _messagesInfos = [];
  List<CosmosWeb3MessagesInfo> get messagesInfos => _messagesInfos;
  TXBody? _txBody;
  List<ReceiptAddress>? _signers;
  List<ReceiptAddress>? get signer => _signers;
  bool get isThorChain =>
      network.coinParam.networkType == CosmosNetworkTypes.thorAndForked;
  CosmosTransactionRequirment? _txRequirment;
  CosmosWeb3TransactionFeeInfo? _fee;
  CosmosWeb3TransactionFeeInfo get fee => _fee!;
  List<CW20Token> get feeTokens => _txRequirment!.feeTokens;
  bool get hasMultipleFeeToken => _txRequirment!.hasMultipleFeeToken;
  String? _memo;
  String? get memo => _memo;
  bool get hasMemo => _memo != null;
  SignDoc? _finalDirectTx;
  AminoTx? _finalAminoTx;

  Future<void> changeGasLimit(ONUPDATECOSMOSGASLIMIT onTap) async {
    final gasLimit = await onTap(fee.gasLimitAsBigRational);
    if (gasLimit == null) return;
    fee.updateGasLimit(gasLimit.toBigInt());
    onChanged?.call();
  }

  Future<void> changeFeeToken(
      {required CosmosWeb3TransactionFeeToken token,
      required ONCHANGEFEETOKEN onTap}) async {
    final updateToken = await onTap(feeTokens, network);
    if (updateToken == null || updateToken == token.token) return;
    final fees = _fee!.fees.clone();
    if (!fees.contains(token)) return;
    fees[fees.indexOf(token)] = CosmosWeb3TransactionFeeToken(
        token: updateToken, feeAmount: BigInt.zero);
    _fee = CosmosWeb3TransactionFeeInfo(fees: fees, gasLimit: _fee!.gasLimit);
    onChanged?.call();
  }

  Future<void> ChangeFeeAmount(
      {required CosmosWeb3TransactionFeeToken token,
      required ONCHANGEFEEAMOUNT onTap}) async {
    final amount = await onTap(token.token.token, null);
    if (amount == null) return;
    token.feeAmount.updateBalance(amount);
    onChanged?.call();
  }

  Future<void> changeMemo(OnAddCosmosMemo onTap) async {
    _memo = await onTap(memo);
    onChanged?.call();
  }

  CosmosWeb3TransactionFeeInfo _buildDefaultFee(
      {required CW20Token feeToken,
      required BigInt? gasLimit,
      required CosmosBaseAddress? granter,
      required CosmosBaseAddress? payer,
      bool isSimulate = false}) {
    if (gasLimit == null) {
      return CosmosWeb3TransactionFeeInfo(fees: [
        CosmosWeb3TransactionFeeToken(token: feeToken, feeAmount: BigInt.zero)
      ], gasLimit: BigInt.zero, isDefaultFee: true);
    }
    if (isThorChain) {
      BigInt fee = _txRequirment!.fixedNativeGas!;
      if (_messagesInfos.length > 1) {
        fee = fee * BigInt.from(_messagesInfos.length);
      }
      return CosmosWeb3TransactionFeeInfo(fees: [
        CosmosWeb3TransactionFeeToken(token: feeToken, feeAmount: fee)
      ], gasLimit: gasLimit);
    }
    BigRational gasPrice = CosmosConst.avarageGasPrice;
    if (network.coinParam.networkType.isEthermint) {
      gasPrice = _txRequirment!.ethermintTxFee!;
    } else {
      final avarageFee =
          network.coinParam.getFeeToken(denom: feeToken.denom).getFee();
      gasPrice = BigRational.parseDecimal(avarageFee.price);
    }
    BigRational gp;
    if (isSimulate) {
      gp = (BigRational(gasLimit) * CosmosConst.feeMultiplier);
    } else {
      gp = BigRational(gasLimit);
    }
    final fee = gp * gasPrice;
    return CosmosWeb3TransactionFeeInfo(fees: [
      CosmosWeb3TransactionFeeToken(token: feeToken, feeAmount: fee.toBigInt())
    ], gasLimit: gp.toBigInt());
  }

  Future<void> _initializeFee(Fee fee) async {
    final CosmosTransactionRequirment txRequirment = _txRequirment!;
    List<CW20Token> feeTokens = txRequirment.feeTokens.clone();

    for (final i in fee.amount) {
      final token = feeTokens.firstWhereOrNull((e) => e.denom == i.denom);
      if (token == null) {
        try {
          final tokenMetadata = await client.getTokenMetadata(i.denom);
          feeTokens.add(tokenMetadata);
        } on RPCError catch (e) {
          if (e.errorCode == CosmosConst.accountNotFoundErrorCode) {
            throw Web3CosmosExceptionConstant.feeCoinNotFound;
          }
          throw Web3RequestExceptionConst.fromException(e);
        } catch (e) {
          throw Web3RequestExceptionConst.fromException(e);
        }
      }
    }
    _txRequirment = txRequirment.copyWith(feeTokens: feeTokens);
    if (fee.amount.isEmpty) {
      final feeDenom = network.coinParam.getFeeToken();
      final feeToken = feeTokens.firstWhere((e) => e.denom == feeDenom.denom);
      _fee = _buildDefaultFee(
          feeToken: feeToken,
          gasLimit: fee.gasLimit,
          payer: fee.granter,
          granter: fee.payer);
    } else {
      _fee = CosmosWeb3TransactionFeeInfo(
          fees: fee.amount.map((e) {
            final feeToken = feeTokens.firstWhere((i) => i.denom == e.denom);
            return CosmosWeb3TransactionFeeToken(
                token: feeToken, feeAmount: e.amount);
          }).toList(),
          gasLimit: fee.gasLimit ?? BigInt.zero,
          granter: fee.granter,
          payer: fee.payer);
    }
  }

  Future<void> simulateTx() async {
    if (!showSimulate || status == StreamWidgetStatus.idle) return;
    _status = StreamWidgetStatus.progress;
    _cancelable.cancel();
    _simulateError = null;
    simulateProgressKey.process();
    onChanged?.call();
    try {
      final r = await MethodUtils.call(() async {
        final tx = Tx(
            body: _txBody!,
            authInfo: _authInfo!,
            signatures: [CryptoConst.fakeEd25519Signature]);
        return client.simulateTransaction(tx.toBuffer(),
            txMessages: tx.body.messages);
      }, cancelable: _cancelable);
      if (r.isCancel) return;
      if (r.hasError) {
        _simulateError = r.error?.tr;
        if (r.hasResult) {
          _simulateTxContent = r.result;
        }
        _status = StreamWidgetStatus.error;
        simulateProgressKey.error();
        return;
      }
      if (_fee!.isDefaultFee) {
        _fee = _buildDefaultFee(
            feeToken: _fee!.fees[0].token,
            gasLimit: r.result.gasUsed,
            granter: _fee!.granter,
            payer: _fee!.payer,
            isSimulate: true);
      }
      _simulateError = "transaction_simulation_success".tr;
      _simulateTxContent = r.result;

      _status = StreamWidgetStatus.idle;
      simulateProgressKey.idle();
    } finally {
      onChanged?.call();
    }
  }

  Future<void> _initAminoTransaction(
      {required Web3CosmosSignTransactionAminoParams params,
      required BigInt? timeoutHeight}) async {
    if (params.tx.messages.whereType<UnknownAminoService>().isEmpty) {
      _txBody = TXBody(
          messages: params.tx.messages,
          memo: params.tx.memo,
          timeoutHeight: timeoutHeight);
    }
    if (params.tx.memo.isNotEmpty) {
      _memo = params.tx.memo;
    }

    _messagesInfos = params.tx.messages
        .map((e) => CosmosWeb3MessagesInfo(
            content: StringUtils.fromJson(e.toJson(),
                indent: '', toStringEncodable: true),
            typeUrl: e.typeUrl.aminoType!,
            value: e.toBase64))
        .toImutableList;
    _authInfo = AuthInfo(signerInfos: [
      address.signerInfo.copyWith(
          sequence: params.tx.sequence,
          modeInfo:
              const ModeInfo(ModeInfoSignle(SignMode.signModeLegacyAminoJson)))
    ], fee: params.tx.fee);
  }

  Future<void> _initDirectTransaction({
    required Web3CosmosSignTransactionDirectParams params,
    required BigInt? timeoutHeight,
  }) async {
    _accountNumber =
        params.accountNumber ?? _txRequirment!.account?.accountNumber;
    _txBody = TXBody.deserialize(params.bodyBytes);
    _memo = _txBody!.memo;
    final messages = _txBody!.messages.cast<AnyBytesMessage>();
    _messagesInfos = messages.map((e) {
      final service = MethodUtils.nullOnException(() =>
          ServiceMessage.deserialize(
              typeUrl: e.typeUrl.typeUrl, bytes: e.value));
      return CosmosWeb3MessagesInfo(
          content: service == null
              ? null
              : StringUtils.fromJson(service.toJson(),
                  indent: '', toStringEncodable: true),
          typeUrl: e.typeUrl.typeUrl,
          value: service?.toBase64 ?? e.toBase64);
    }).toImutableList;
    if (params.authInfos != null) {
      _authInfo = AuthInfo.deserialize(params.authInfos!);
    } else {
      _authInfo = AuthInfo(signerInfos: [
        address.signerInfo.copyWith(
            sequence: _txRequirment?.account?.sequence,
            modeInfo: const ModeInfo(ModeInfoSignle(SignMode.signModeDirect)))
      ], fee: Fee(amount: []));
    }
  }

  Web3CosmosSignTransactionResponse buildResponse(List<int> signature) {
    switch (request.params.method) {
      case Web3CosmosRequestMethods.signTransactionDirect:
        final signDoc = _finalDirectTx!;
        return Web3CosmosSignTransactionDirectSignResponse(
            bodyBytes: signDoc.bodyBytes,
            authInfoBytes: signDoc.authInfoBytes,
            signature: signature,
            chainId: network.coinParam.chainId,
            accountNumber: signDoc.accountNumber,
            publicKey: address.toCosmosPublicKey().toAny());
      case Web3CosmosRequestMethods.signTransactionAmino:
        return Web3CosmosSignTransactionAminoSignResponse(
            signature: signature,
            tx: _finalAminoTx!,
            publicKey: address.toCosmosPublicKey().toAny());
      default:
        throw Web3RequestExceptionConst.invalidRequest;
    }
  }

  List<int> _buildSigningDirectDigest() {
    final tx = _txBody!;
    final TXBody finalTx;
    if (tx.memo == memo) {
      finalTx = _txBody!;
    } else {
      finalTx = TXBody(
          messages: tx.messages,
          extensionOptions: tx.extensionOptions,
          memo: memo,
          nonCriticalExtensionOptions: tx.nonCriticalExtensionOptions,
          unordered: tx.unordered,
          messagesJson: tx.messagesJson,
          timeoutHeight: tx.timeoutHeight);
    }
    final auth = _authInfo!.copyWith(fee: _fee!.toTransactionFee());
    _finalDirectTx = SignDoc(
        bodyBytes: finalTx.toBuffer(),
        authInfoBytes: auth.toBuffer(),
        chainId: network.coinParam.chainId,
        accountNumber: _accountNumber ?? BigInt.zero);
    return _finalDirectTx!.toBuffer();
  }

  List<int> _buildSigningAminoDigest() {
    final params =
        request.params.transaction as Web3CosmosSignTransactionAminoParams;
    final aminoTx =
        params.tx.copyWith(fee: _fee!.toTransactionFee(), memo: memo ?? '');
    _finalAminoTx = aminoTx;
    return _finalAminoTx!.toBuffer();
  }

  List<int> _buildFinalTx() {
    switch (request.params.method) {
      case Web3CosmosRequestMethods.signTransactionDirect:
        return _buildSigningDirectDigest();
      case Web3CosmosRequestMethods.signTransactionAmino:
        return _buildSigningAminoDigest();
      default:
        throw Web3RequestExceptionConst.invalidRequest;
    }
  }

  void signTransaction() {
    final txBytes = _buildFinalTx();
    onCompleteForm?.call(txBytes);
  }

  @override
  Future<void> initForm(
      {required CosmosChain account, required ICosmosAddress? address}) async {
    await super.initForm(account: account, address: address);
    _txRequirment = await client.getTransactionRequirment(
        address: this.address, account: account);
    switch (request.params.method) {
      case Web3CosmosRequestMethods.signTransactionAmino:
        await _initAminoTransaction(
            params: request.params.transaction
                as Web3CosmosSignTransactionAminoParams,
            timeoutHeight: request.params.timeoutHeight);
        break;
      case Web3CosmosRequestMethods.signTransactionDirect:
        await _initDirectTransaction(
            params: request.params.transaction
                as Web3CosmosSignTransactionDirectParams,
            timeoutHeight: request.params.timeoutHeight);
        break;
      default:
    }
    await _initializeFee(_authInfo!.fee);
    if (showSimulate) {
      MethodUtils.after(() => simulateTx(),
          duration: APPConst.oneSecoundDuration);
    } else {
      _status = StreamWidgetStatus.idle;
    }
  }
}

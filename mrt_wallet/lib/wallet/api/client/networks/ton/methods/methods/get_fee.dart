import 'package:mrt_wallet/wallet/models/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonRquestGetFee
    extends TonApiRequestParam<TonTransactionFeeDetails, dynamic> {
  final Message message;
  final TonAddress address;
  final TonApiType api;
  final MsgForwardPricesResponse forwardPrice;
  TonRquestGetFee(
      {required this.message,
      required this.address,
      required this.forwardPrice,
      required this.api});
  TonApiRequestParam? _request;
  TonApiRequestParam _getRequest() {
    if (!api.isTonCenter) {
      return TonApiEmulateMessageToTrace(
          boc: beginCell().store(message).endCell().toBase64(),
          ignoreSignatureCheck: true);
    }
    return TonCenterEstimateFee(
        address: address.toString(),
        body: message.body.toBase64(),
        initCode: message.init?.code?.toBase64() ?? "",
        initData: message.init?.data?.toBase64() ?? "");
  }

  @override
  TonRequestInfo toRequest(int v) {
    _request = _getRequest();
    return _request!.toRequest(v);
  }

  @override
  String get method => throw UnimplementedError();

  @override
  TonTransactionFeeDetails onResonse(json) {
    final externalMessageFee = TonFeeUtils.computeExternalMessageFees(
        forwardPrice, message.serialize());
    if (api.isTonCenter) {
      final result = (_request as TonCenterEstimateFee).onResonse(json);
      return TonTransactionFeeDetails(
          actionPhase: result.sourceFees.inFwdFee +
              result.sourceFees.fwdFee +
              externalMessageFee,
          storageFee: result.sourceFees.storageFee,
          gasFee: result.sourceFees.gasFee,
          success: true);
    }
    final result = (_request as TonApiEmulateMessageToTrace).onResonse(json);

    return TonTransactionFeeDetails(
        actionPhase: ((result.transaction.actionPhase?.fwdFees ?? BigInt.zero) +
            externalMessageFee),
        gasFee: result.transaction.computePhase?.gasFees ?? BigInt.zero,
        storageFee:
            result.transaction.storagePhase?.feesCollected ?? BigInt.zero,
        success: result.transaction.success,
        resultDescription:
            result.transaction.actionPhase?.resultCodeDescription,
        internalMessages: result.children.map(
          (e) {
            final bool success =
                e.transaction.actionPhase?.success ?? e.transaction.success;
            String? errorMessage;
            if (!success) {
              errorMessage = e.transaction.actionPhase?.resultCodeDescription ??
                  e.transaction.computePhase?.exitCodeDescription ??
                  e.transaction.computePhase?.exitCode?.toString();
            }
            return TonEmulatedMessage(
                destination: e.transaction.inMsg!.destination?.address,
                actionPhase: result.internalActionFees + e.internalActionFees,
                gasFee: result.internalGasFees + e.internalGasFees,
                storageFee:
                    result.internalStorageFeees + e.internalStorageFeees,
                success: success,
                resultDescription: errorMessage);
          },
        ).toList());
  }
}

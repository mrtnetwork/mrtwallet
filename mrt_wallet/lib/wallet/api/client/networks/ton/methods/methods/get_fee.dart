import 'package:mrt_wallet/wallet/models/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonRquestGetFee extends TonApiRequest<TonTransactionFeeDetails, dynamic> {
  final Message message;
  final TonAddress address;
  final TonApiType api;
  final MsgForwardPricesResponse forwardPrice;
  TonRquestGetFee(
      {required this.message,
      required this.address,
      required this.forwardPrice,
      required this.api});
  TonApiRequest? _request;
  TonApiRequest _getRequest() {
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
  TonRequestDetails buildRequest(int v) {
    _request = _getRequest();
    return _request!.buildRequest(v);
  }

  @override
  String get method => throw UnimplementedError();

  @override
  TonTransactionFeeDetails onResonse(result) {
    final externalMessageFee = TonFeeUtils.computeExternalMessageFees(
        forwardPrice, message.serialize());
    if (api.isTonCenter) {
      final r = (_request as TonCenterEstimateFee).onResonse(result);
      return TonTransactionFeeDetails(
          actionPhase:
              r.sourceFees.inFwdFee + r.sourceFees.fwdFee + externalMessageFee,
          storageFee: r.sourceFees.storageFee,
          gasFee: r.sourceFees.gasFee,
          success: true);
    }
    final r = (_request as TonApiEmulateMessageToTrace).onResonse(result);

    return TonTransactionFeeDetails(
        actionPhase: ((r.transaction.actionPhase?.fwdFees ?? BigInt.zero) +
            externalMessageFee),
        gasFee: r.transaction.computePhase?.gasFees ?? BigInt.zero,
        storageFee: r.transaction.storagePhase?.feesCollected ?? BigInt.zero,
        success: r.transaction.success,
        resultDescription: r.transaction.actionPhase?.resultCodeDescription,
        internalMessages: r.children.map(
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
                actionPhase: r.internalActionFees + e.internalActionFees,
                gasFee: r.internalGasFees + e.internalGasFees,
                storageFee: r.internalStorageFeees + e.internalStorageFeees,
                success: success,
                resultDescription: errorMessage);
          },
        ).toList());
  }
}

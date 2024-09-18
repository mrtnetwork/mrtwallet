import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:ton_dart/ton_dart.dart';

enum TonFeeStatus { estimate, progress, error, idle }

mixin TonFeeImpl {
  ITonAddress get address;
  TonClient get apiProvider;
  Future<Message> buildTransaction({bool fakeSignature = false});
  void onChange();
  WalletTonNetwork get network;

  TonTransactionFeeDetails _feeDetails = TonTransactionFeeDetails.nonEstimate();
  TonTransactionFeeDetails get feeDetails => _feeDetails;
  BigInt get fee => _feeDetails.fee.balance;
  bool get hasFee => _feeDetails.isEstimated;
  MsgForwardPricesResponse? _networkForwardPrices;
  final Cancelable _cancelable = Cancelable();
  StreamWidgetStatus _feeStatus = StreamWidgetStatus.idle;
  StreamWidgetStatus get feeStatus => _feeStatus;
  String? _feeError;
  String? get feeError => _feeError;

  Future<MsgForwardPricesResponse> _forwardPriceConfig() async {
    _networkForwardPrices ??= await apiProvider.getMsgFrowardPricesConfing();
    return _networkForwardPrices!;
  }

  Future<TonTransactionFeeDetails> _estimateFee() async {
    final message = await buildTransaction(fakeSignature: true);
    final feeConfig = await _forwardPriceConfig();
    final estimate = await apiProvider.getTransactionFee(
        address: address.networkAddress,
        message: message,
        forwardPrice: feeConfig);
    return estimate;
  }

  Future<void> estimateFee() async {
    _cancelable.cancel();
    _feeError = null;
    _feeStatus = StreamWidgetStatus.progress;
    _feeDetails = TonTransactionFeeDetails.nonEstimate();
    onChange();
    final estimate = await MethodUtils.call(() async => await _estimateFee());
    if (estimate.hasError) {
      if (!estimate.isCancel) {
        _feeStatus = StreamWidgetStatus.error;
        _feeError = "estimate_fee_error_desc";
      }
    } else {
      _feeStatus = StreamWidgetStatus.success;
      _feeDetails = estimate.result;
    }
    onChange();
  }

  void onTapErrorEstimate() {
    if (_feeError == null) return;
    estimateFee();
  }
}

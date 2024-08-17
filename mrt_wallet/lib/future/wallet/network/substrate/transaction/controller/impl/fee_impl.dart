import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/stream_bottun.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

import 'signer_impl.dart';
import 'transaction.dart';

mixin SubstrateFeeImpl on SubstrateSignerImpl, SubstrateTransactiomImpl {
  late SubstrateFeeInfos _feeInfo = SubstrateFeeInfos.zero(network);
  SubstrateFeeInfos get feeInfo => _feeInfo;
  IntegerBalance get fee => _feeInfo.total;
  String? _feeError;
  final Cancelable _cancelabe = Cancelable();
  StreamWidgetStatus _feeStatus = StreamWidgetStatus.idle;

  StreamWidgetStatus get feeStatus => _feeStatus;

  bool get hasFee => _feeInfo.calculated;
  String? get feeError => _feeError;

  Future<void> estimateFee() async {
    _cancelabe.cancel();
    _feeInfo = SubstrateFeeInfos.zero(network);
    _feeError = null;
    _feeStatus = StreamWidgetStatus.progress;
    validator.validator.setupFee(BigInt.zero);
    final result = await MethodUtils.call(() async {
      final extrinsic = await buildEstimateTransaction();
      return await apiProvider.estimateFee(extrinsic);
    });
    if (result.isCancel) return;
    if (result.hasError) {
      _feeError = result.error;
      _feeStatus = StreamWidgetStatus.error;
    } else {
      final feeInfo = result.result;
      validator.validator.setupFee(feeInfo.total.balance);
      if (!feeInfo.calculated) {
        _feeError = "estimate_fee_error_desc";
        _feeStatus = StreamWidgetStatus.error;
        return;
      }
      _feeInfo = feeInfo;
      _feeStatus = StreamWidgetStatus.success;
    }
    notify();
  }
}

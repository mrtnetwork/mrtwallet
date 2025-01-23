import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/stream_bottun.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

mixin SubstrateFeeImpl on StateController {
  WalletSubstrateNetwork get network;
  SubstrateClient get apiProvider;
  Future<ExtrinsicInfo> buildEstimateTransaction();
  late SubstrateFeeInfos _feeInfo = SubstrateFeeInfos.zero(network);
  SubstrateFeeInfos get feeInfo => _feeInfo;
  IntegerBalance get fee => _feeInfo.total;
  String? _feeError;
  final Cancelable _cancelabe = Cancelable();
  final Live<StreamWidgetStatus> _feeStatus = Live(StreamWidgetStatus.idle);

  StreamWidgetStatus get feeStatus => _feeStatus.value;

  bool get hasFee => _feeInfo.calculated;
  String? get feeError => _feeError;

  Future<void> estimateFee({ExtrinsicInfo? extrinsic}) async {
    _cancelabe.cancel();
    _feeInfo = SubstrateFeeInfos.zero(network);
    _feeError = null;
    _feeStatus.value = StreamWidgetStatus.progress;
    final result = await MethodUtils.call(() async {
      extrinsic ??= await buildEstimateTransaction();
      return await apiProvider.estimateFee(
          extrinsic: extrinsic!.serialize(encodeLength: false),
          network: network);
    });
    if (result.isCancel) return;
    if (result.hasError) {
      _feeError = result.error;
      _feeStatus.value = StreamWidgetStatus.error;
    } else {
      final feeInfo = result.result;

      if (!feeInfo.calculated) {
        _feeError = "estimate_fee_error_desc";
        _feeStatus.value = StreamWidgetStatus.error;
        return;
      }
      _feeInfo = feeInfo;
      _feeStatus.value = StreamWidgetStatus.success;
    }
  }

  @override
  void close() {
    super.close();
    _feeStatus.dispose();
    _cancelabe.cancel();
  }
}

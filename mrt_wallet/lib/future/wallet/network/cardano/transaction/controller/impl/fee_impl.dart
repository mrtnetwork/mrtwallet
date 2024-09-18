import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:on_chain/ada/ada.dart';
import 'transaction.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

enum CardanoFeeRateType {
  basic,
  manually;

  bool get isManually => this == manually;
}

mixin CardanoTransactionFeeImpl on CardanoTransactionImpl {
  ADAEpochParametersResponse? _protocolParams;
  late final IntegerBalance _feeRate =
      IntegerBalance.zero(network.coinParam.decimal);
  late final IntegerBalance _networkRequiredFee =
      IntegerBalance.zero(network.coinParam.decimal);
  CardanoFeeRateType _feeRateType = CardanoFeeRateType.basic;
  String? _feeError;

  @override
  ADAEpochParametersResponse get protocolParams => _protocolParams!;

  String? get feeError => _feeError;
  CardanoFeeRateType get feeRateType => _feeRateType;
  bool get hasFee => !transactionFee.isZero;
  IntegerBalance get networkRequiredFee => _networkRequiredFee;
  @override
  IntegerBalance get transactionFee => _feeRate;

  @override
  Future<void> calculateFee() async {
    super.calculateFee();
    final builder = buildTransaction(transactionFee.balance);
    final size = builder.estimateSize(
        onChangeAddress: changeADAOutput.address.networkAddress);
    final calcFee = _protocolParams!.calculateFee(size);

    _networkRequiredFee.updateBalance(calcFee);
    if (feeRateType.isManually) {
      _validateFee();
      onCalculateAmount();
      return;
    }
    _feeRate.updateBalance(calcFee);
    onCalculateAmount();
  }

  Future<void> initProtocolParameters() async {
    if (_protocolParams != null) return;
    progressKey.progressText("retrieving_network_condition".tr);
    final params = await MethodUtils.call(() async {
      final result = await providers.latestEpochProtocolParameters();
      return result;
    });
    if (params.hasError) {
      progressKey.errorText(params.error!.tr, backToIdle: false);
    } else {
      _protocolParams = params.result;
      progressKey.success();
    }
  }

  void setupFee(BigInt? newFee) {
    if (newFee == null) {
      if (_feeRateType.isManually) {
        _feeRateType = CardanoFeeRateType.basic;
        _feeRate.updateBalance(_networkRequiredFee.balance);
      }
    } else {
      _feeRate.updateBalance(newFee);
      _feeRateType = CardanoFeeRateType.manually;
    }
    _validateFee();
    onCalculateAmount();
  }

  void _validateFee() {
    if (_feeRateType.isManually) {
      if (_feeRate.balance < _networkRequiredFee.balance) {
        _feeError = "transaction_fee_warning".tr;
      } else {
        _feeError = null;
      }
    } else {
      _feeError = null;
    }
  }

  @override
  void ready() {
    super.ready();
    initProtocolParameters();
  }
}

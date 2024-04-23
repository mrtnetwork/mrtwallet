import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/progress.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';
import 'package:on_chain/ada/ada.dart';
import 'transaction.dart';

enum CardanoFeeRateType {
  basic,
  manually;

  bool get isManually => this == manually;
}

mixin CardanoTransactionFeeImpl on CardanoTransactionImpl {
  ADAEpochParametersResponse? _protocolParams;
  late final NoneDecimalBalance _feeRate =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  late final NoneDecimalBalance _networkRequiredFee =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  CardanoFeeRateType _feeRateType = CardanoFeeRateType.basic;
  String? _feeError;

  @override
  int get coinsPerUtxoSize => _protocolParams!.coinsPerUtxoSize;
  String? get feeError => _feeError;
  CardanoFeeRateType get feeRateType => _feeRateType;
  bool get hasFee => !transactionFee.isZero;
  NoneDecimalBalance get networkRequiredFee => _networkRequiredFee;
  @override
  NoneDecimalBalance get transactionFee => _feeRate;

  @override
  Future<void> calculateFee() async {
    final builder = ADATransactionBuilder(
        outputs: [
          ...receivers.map((e) => e.toOutput()).toList(),
          if (remindAmount.largerThanZero) changeADAOutput.toOutput(),
          if (changeAssetOutput.hasAssets) changeAssetOutput.toOutput()
        ],
        utxos: selectedUtxos.map((e) => e.utxo.toUtxoResponse()).toList(),
        metadata: transactionMemo);
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
    final params = await MethodCaller.call(() async {
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

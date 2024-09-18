import 'dart:async';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/utils/ethereum/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

enum EIP1559FeeSpeed {
  slow("slow"),
  normal("normal"),
  high("high"),
  customFee("custom_fee");

  final String value;
  const EIP1559FeeSpeed(this.value);
}

mixin ETHTransactionFeeImpl on EthTransactionImpl {
  EthereumInitFee? _initFee;
  EthereumInitFee? get initFee => null;
  StreamSubscription<(BigInt?, FeeHistorical?)>? _perdiocFetch;
  bool _updatingGas = false;
  bool _gasFetched = false;
  int? _gasLimit;
  bool get gasInited => _gasFetched;
  bool get updatingGas => _updatingGas;

  late final bool eip1559;
  EIP1559FeeSpeed _speed = EIP1559FeeSpeed.normal;
  EIP1559FeeSpeed get feeSpeed => _speed;
  late final Map<EIP1559FeeSpeed, EthereumFee?> _fees = _buildNetworkFee();

  Map<EIP1559FeeSpeed, EthereumFee?> _buildNetworkFee() {
    if (eip1559) {
      return {
        EIP1559FeeSpeed.slow: null,
        EIP1559FeeSpeed.normal: null,
        EIP1559FeeSpeed.high: null,
        EIP1559FeeSpeed.customFee: null,
      };
    }
    return {
      EIP1559FeeSpeed.normal: null,
      EIP1559FeeSpeed.customFee: null,
    };
  }

  Map<EIP1559FeeSpeed, EthereumFee?> get fees => _fees;
  EthereumFee? get currentEIP1559Fee => fees[_speed];
  String? _estimateError;
  String? get estimateError => _estimateError;

  void onFeeChanged();
  Future<(BigInt?, FeeHistorical?)?> fetchGasPrice() async {
    try {
      if (eip1559) {
        final fee = await apiProvider.getHistoricalFee();
        return (null, fee);
      } else {
        final gasPrice = await apiProvider.gasPrice();
        return (gasPrice, null);
      }
    } catch (e) {
      return null;
    }
  }

  void _calculateEip(FeeHistorical fee) {
    _fees[EIP1559FeeSpeed.slow] = EthereumFee.eip1559(
        _gasLimit ?? EthereumUtils.baseGasLimit, fee.slow, fee.baseFee);
    _fees[EIP1559FeeSpeed.normal] = EthereumFee.eip1559(
        _gasLimit ?? EthereumUtils.baseGasLimit, fee.normal, fee.baseFee);
    _fees[EIP1559FeeSpeed.high] = EthereumFee.eip1559(
        _gasLimit ?? EthereumUtils.baseGasLimit, fee.high, fee.baseFee);
  }

  void _calculateNonEip(BigInt gasPrice) {
    _fees[EIP1559FeeSpeed.normal] = EthereumFee.legacy(
      _gasLimit ?? EthereumUtils.baseGasLimit,
      gasPrice,
    );
  }

  Map<EIP1559FeeSpeed, EthereumFee?>? _updateFessGasLimit(int gasLimit) {
    if (_fees[EIP1559FeeSpeed.normal] == null) return null;
    Map<EIP1559FeeSpeed, EthereumFee?> updatedFees = {};
    final maxGas = BigInt.from(gasLimit);
    for (final i in fees.entries) {
      if (i.value == null) continue;
      updatedFees[i.key] = i.value!.copyWith(
        gasLimit: gasLimit,
        fee: IntegerBalance(
            (i.value!.maxFeePerGas ?? i.value!.gasPrice!) * maxGas,
            EthereumUtils.decimal),
      );
    }
    return updatedFees;
  }

  bool _gasIsReady() {
    return _gasLimit != null && _fees[EIP1559FeeSpeed.normal] != null;
  }

  void _onGasFetched((BigInt?, FeeHistorical?) gas) {
    if (eip1559) {
      _calculateEip(gas.$2!);
    } else {
      _calculateNonEip(gas.$1!);
    }

    _gasFetched = _gasIsReady();
    if (_gasFetched) {
      if (_initFee?.hasFee ?? false) {
        final fee = _initFee!.toFee(
            gasLimit: _gasLimit!, feeHistorical: gas.$2, gasPrice: gas.$1);
        if (fee != null) {
          setFee(EIP1559FeeSpeed.customFee, customFee: fee);
        }
        _initFee = null;
        return;
      }
    }
    onFeeChanged();
  }

  void _initPredioc() {
    stopGasEstimate();
    _perdiocFetch = _prediocFetchGasStream().listen(_onGasFetched);
  }

  Stream<(BigInt?, FeeHistorical?)> _prediocFetchGasStream() async* {
    while (!deleted) {
      if (!_updatingGas) {
        _updatingGas = true;
        onFeeChanged();
      }
      final gas = await fetchGasPrice();
      if (gas == null) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }
      _updatingGas = false;
      yield gas;
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  void stopGasEstimate() {
    _perdiocFetch?.cancel();
    _perdiocFetch = null;
  }

  Cancelable<dynamic>? _gasLimitCanclable;

  Future<void> estimateGasLimit({Map<String, dynamic>? estimateDetails}) async {
    _gasLimitCanclable?.cancel();
    _gasLimit = null;
    _estimateError = null;
    _gasFetched = _gasIsReady();

    onFeeChanged();
    final estimate = await MethodUtils.call(() async {
      final gasLimit = await apiProvider.estimateGasLimit(estimateDetails!);
      final updatedFess = _updateFessGasLimit(gasLimit.toInt());
      return (updatedFess, gasLimit.toInt());
    }, cancelable: _gasLimitCanclable);
    if (!estimate.hasError) {
      if (estimate.result.$1 != null) {
        fees.addAll(estimate.result.$1!);
      }
      _gasLimit = estimate.result.$2;
    } else {
      _estimateError = estimate.error?.tr;
    }
    _gasFetched = _gasIsReady();

    onFeeChanged();
  }

  void setFee(EIP1559FeeSpeed? speed, {EthereumFee? customFee}) {
    if (speed == null) return;
    if (speed == EIP1559FeeSpeed.customFee && customFee == null) return;
    if (speed == EIP1559FeeSpeed.customFee) {
      fees[EIP1559FeeSpeed.customFee] = customFee!;
    } else if (_speed == speed) {
      return;
    }
    _speed = speed;
    onFeeChanged();
  }

  void startGasListening() {
    _initFee = initFee;
    final bool networkSupportEip = network.coinParam.supportEIP1559;
    if (networkSupportEip) {
      if (initFee?.isLegacyFeeMetrics ?? false) {
        eip1559 = false;
      } else {
        eip1559 = true;
      }
    } else {
      eip1559 = false;
    }
    _initPredioc();
  }

  @override
  void close() {
    stopGasEstimate();
    super.close();
  }
}

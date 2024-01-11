import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/impl/transaction.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/api/api_provider.dart';

mixin BitcoinTransactionFeeImpl on BitcoinTransactionImpl {
  int? _trSize;
  int get trSize => _trSize!;
  BitcoinFeeRateType? _feeRateType = BitcoinFeeRateType.medium;

  BitcoinFeeRate? _networkFeeRate;
  BitcoinFeeRate get feeRate => _networkFeeRate!;
  late final NoneDecimalBalance _feeRate =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  @override
  NoneDecimalBalance get transactionFee => _feeRate;
  BitcoinFeeRateType? get feeRateType => _feeRateType;

  late Map<String, NoneDecimalBalance> _fees;
  Map<String, NoneDecimalBalance> get fees => _fees;

  Map<String, NoneDecimalBalance> _buildFeeRate() {
    return {
      BitcoinFeeRateType.medium.name: NoneDecimalBalance(
          feeRate.getEstimate(trSize, feeRateType: BitcoinFeeRateType.medium),
          network.coinParam.decimal),
      BitcoinFeeRateType.low.name: NoneDecimalBalance(
          feeRate.getEstimate(trSize, feeRateType: BitcoinFeeRateType.low),
          network.coinParam.decimal),
      BitcoinFeeRateType.high.name: NoneDecimalBalance(
          feeRate.getEstimate(trSize, feeRateType: BitcoinFeeRateType.high),
          network.coinParam.decimal),
    };
  }

  @override
  void setFee(BitcoinFeeRateType? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _feeRateType = feeType;
    if (_feeRateType == null) {
      _feeRate.updateBalance(customFee!);
    } else {
      _feeRate.updateBalance(
          _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
    }
  }

  Future<BitcoinFeeRate> _getFeeRate() async {
    if (network.value == 1) {
      final BitcoinApiProvider blockCypherApi =
          chainAccount.providerFromService(ApiProviderService.blockCypher);
      return blockCypherApi.provider.getNetworkFeeRate();
    }
    return apiProvider.provider.getNetworkFeeRate();
  }

  Future<(int, BitcoinFeeRate)> _calculateFee({
    required List<BitcoinUtxoWithBalance> utxos,
    required Map<String, BitcoinOutputWithBalance> receivers,
  }) async {
    _feeRateType ??= BitcoinFeeRateType.medium;
    final transactionSize = BitcoinTransactionBuilder.estimateTransactionSize(
        utxos: utxos
            .map((e) => UtxoWithAddress(utxo: e.utxo, ownerDetails: e.address))
            .toList(),
        memo: memo,
        enableRBF: true,
        outputs: receivers.values.map((e) => e.address.networkAddress).toList(),
        network: network.coinParam.transacationNetwork);
    BitcoinFeeRate? networkFee = _networkFeeRate;
    if (networkFee == null) {
      networkFee = await _getFeeRate();
    } else {
      await MethodCaller.wait();
    }
    return (transactionSize, networkFee);
  }

  Future<void> calculateFee(
      {required Map<String, BitcoinOutputWithBalance> receivers,
      required List<BitcoinUtxoWithBalance> utxos}) async {
    _feeRateType ??= BitcoinFeeRateType.medium;
    final result = await _calculateFee(receivers: receivers, utxos: utxos);
    _trSize = result.$1;
    _networkFeeRate ??= result.$2;
    _feeRate.updateBalance(
        _networkFeeRate!.getEstimate(_trSize!, feeRateType: _feeRateType!));
    onCalculateAmount();
    _fees = _buildFeeRate();
  }
}

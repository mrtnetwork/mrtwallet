import 'package:mrt_wallet/app/utility/blockchin_utils/ripple/ripple_utils.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:xrpl_dart/xrpl_dart.dart';

mixin RippleFeeImpl on RippleTransactionImpl {
  @override
  Map<String, NoneDecimalBalance> get fees => _fees;
  XRPLTransactionType get transactionType;
  String? _fulfillment;
  int _multiSigners = 0;
  void updateFee([String? fulFillment]) {
    if (fulFillment == _fulfillment) return;
    _fulfillment = fulFillment;
    _fees = _buildFees();
    setFee(feeType?.name);
  }

  Map<String, NoneDecimalBalance> _buildFees() {
    return {
      XrplFeeType.open.name: NoneDecimalBalance(
          RippleUtils.calculateFee(
              _xrpLedger!.getFeeType(type: XrplFeeType.open), transactionType,
              fulfillment: _fulfillment, multiSigners: _multiSigners),
          network.coinParam.decimal),
      XrplFeeType.minimum.name: NoneDecimalBalance(
          RippleUtils.calculateFee(
              _xrpLedger!.getFeeType(type: XrplFeeType.minimum),
              transactionType,
              fulfillment: _fulfillment,
              multiSigners: _multiSigners),
          network.coinParam.decimal),
      XrplFeeType.dynamic.name: NoneDecimalBalance(
          RippleUtils.calculateFee(
              _xrpLedger!.getFeeType(type: XrplFeeType.dynamic),
              transactionType,
              fulfillment: _fulfillment,
              multiSigners: _multiSigners),
          network.coinParam.decimal)
    };
  }

  late Map<String, NoneDecimalBalance> _fees;
  @override
  late final NoneDecimalBalance fee =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  @override
  XrplFeeType? get feeType => _feeType;
  LedgerInfo? _xrpLedger;
  XrplFeeType? _feeType = XrplFeeType.open;

  int getBaseFee(XrplFeeType feeType) {
    return _xrpLedger!.getFeeType(type: feeType);
  }

  @override
  void setFee(String? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _feeType = feeType == null
        ? null
        : XrplFeeType.values.firstWhere((element) => element.name == feeType);
    if (_feeType == null) {
      fee.updateBalance(customFee!);
    } else {
      fee.updateBalance(RippleUtils.calculateFee(
          _xrpLedger!.getFeeType(type: _feeType!), transactionType,
          fulfillment: _fulfillment, multiSigners: _multiSigners));
    }
  }

  int _checkSignerLength() {
    if (!address.multiSigAccount) return 0;
    final IXRPMultisigAddress multiSigAddress = address as IXRPMultisigAddress;
    if (multiSigAddress.multiSignatureAccount.isRegular) return 0;
    return multiSigAddress.multiSignatureAccount.signers.length;
  }

  Future<void> fetchFee() async {
    _xrpLedger ??= await apiProvider.provider.request(RPCFee());
    _multiSigners = _checkSignerLength();
    fee.updateBalance(RippleUtils.calculateFee(
        _xrpLedger!.getFeeType(type: _feeType!), transactionType,
        multiSigners: _multiSigners));
    _fees = _buildFees();
  }
}

import 'package:ton_dart/ton_dart.dart';

class _TonRquestGetFeeConst {
  static const int masterChainConfigId = 24;
  static const int workChainConfigId = 25;
}

class TonRquestGetMsgForwardPricesConfig
    extends TonApiRequestParam<MsgForwardPricesResponse, dynamic> {
  final TonApiType api;
  final bool isMasterChan;
  TonRquestGetMsgForwardPricesConfig(this.api, {this.isMasterChan = true});
  TonApiRequestParam? _request;
  TonApiRequestParam _getRequest() {
    if (!api.isTonCenter) {
      return TonApiGetBlockchainConfig();
    }
    final int conifgId = isMasterChan
        ? _TonRquestGetFeeConst.masterChainConfigId
        : _TonRquestGetFeeConst.workChainConfigId;
    return TonCenterGetConfigParam(configId: conifgId);
  }

  @override
  TonRequestInfo toRequest(int v) {
    _request = _getRequest();
    return _request!.toRequest(v);
  }

  @override
  String get method => throw UnimplementedError();

  /// BlockchainConfig24
  @override
  MsgForwardPricesResponse onResonse(json) {
    if (api.isTonCenter) {
      final result = (_request as TonCenterGetConfigParam).onResonse(json);
      final slice = TonHelper.toCell(result["config"]?["bytes"]).beginParse();
      final config = BlockchainConfig24.derserialize(slice);
      return config.msgForwardPrices;
    }
    final result = (_request as TonApiGetBlockchainConfig).onResonse(json);
    if (isMasterChan) return result.r24!.msgForwardPrices;
    return result.r25!.msgForwardPrices;
  }
}

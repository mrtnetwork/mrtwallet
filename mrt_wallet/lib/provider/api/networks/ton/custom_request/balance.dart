import 'package:ton_dart/ton_dart.dart';

class TonRquestGetBalance extends TonApiRequestParam<BigInt, dynamic> {
  final TonAddress address;
  final TonApiType api;
  TonRquestGetBalance({required this.address, required this.api});
  TonApiRequestParam? _request;
  TonApiRequestParam _getRequest() {
    if (!api.isTonCenter) return TonApiGetAccount(address.toString());
    return TonCenterGetAddressBalance(address.toString());
  }

  @override
  TonRequestInfo toRequest(int v) {
    _request = _getRequest();
    return _request!.toRequest(v);
  }

  @override
  String get method => throw UnimplementedError();

  @override
  BigInt onResonse(json) {
    if (api.isTonCenter) {
      return (_request as TonCenterGetAddressBalance).onResonse(json);
    }
    return (_request as TonApiGetAccount).onResonse(json).balance;
  }
}

import 'package:mrt_wallet/models/wallet_models/network/custom/tron/issue_token.dart';
import 'package:on_chain/tron/provider/core/request.dart';
import 'package:on_chain/tron/provider/methods/request_methods.dart';

class TronRequestListOfIssueTRC10
    extends TVMRequestParam<List<TronIssueTRC10Token>, Map<String, dynamic>> {
  TronRequestListOfIssueTRC10();

  @override
  TronHTTPMethods get method => TronHTTPMethods.getassetissuelist;

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  List<TronIssueTRC10Token> onResonse(Map<String, dynamic> result) {
    return (result["assetIssue"] as List).map((e) {
      return TronIssueTRC10Token.fromJson(e);
    }).toList();
  }
}

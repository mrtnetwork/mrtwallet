import 'package:mrt_wallet/wallet/models/networks/tron/models/issue_token.dart';
import 'package:on_chain/tron/src/provider/provider.dart';

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

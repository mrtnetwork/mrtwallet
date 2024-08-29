import 'package:mrt_wallet/wallet/models/networks/tron/models/issue_token.dart';
import 'package:on_chain/tron/src/provider/core/request.dart';
import 'package:on_chain/tron/src/provider/methods/request_methods.dart';

/// Query the list of all the TRC10 tokens.
/// [developers.tron.network](https://developers.tron.network/reference/getassetissuelist).
class TronRequestIssueById
    extends TVMRequestParam<TronIssueTRC10Token?, Map<String, dynamic>> {
  TronRequestIssueById(this.id);
  final String id;

  /// wallet/getassetissuelist
  @override
  TronHTTPMethods get method => TronHTTPMethods.getassetissuebyid;

  @override
  Map<String, dynamic> toJson() {
    return {"value": id};
  }

  @override
  String toString() {
    return "TronRequestGetAssetIssueList{${toJson()}}";
  }

  @override
  TronIssueTRC10Token? onResonse(Map<String, dynamic> result) {
    if (result.isEmpty) return null;
    return TronIssueTRC10Token.fromJson(result);
  }
}

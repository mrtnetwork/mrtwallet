import 'package:mrt_wallet/models/wallet_models/network/custom/ripple/nft.dart';
import 'package:xrp_dart/xrp_dart.dart';

class XRPRPCAccountNFTs extends XRPLedgerRequest<List<XRPNFToken>> {
  XRPRPCAccountNFTs({
    required this.account,
    this.limit,
    this.marker,
    XRPLLedgerIndex? ledgerIndex = XRPLLedgerIndex.validated,
  });
  @override
  String get method => XRPRequestMethod.accountNfts;

  final String account;
  final int? limit;

  final dynamic marker;

  @override
  Map<String, dynamic> toJson() {
    return {"account": account, "limit": limit, "marker": marker};
  }

  @override
  List<XRPNFToken> onResonse(Map<String, dynamic> result) {
    if (result["account_nfts"] == null) return [];
    return (result["account_nfts"] as List)
        .map((e) => XRPNFToken.fromJson(e))
        .toList();
  }
}

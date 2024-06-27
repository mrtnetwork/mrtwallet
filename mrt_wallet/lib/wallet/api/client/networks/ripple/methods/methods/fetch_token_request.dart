import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class XRPRPCFetchTokens extends XRPLedgerRequest<List<XRPIssueToken>> {
  XRPRPCFetchTokens({
    required this.account,
    this.hotWallet,
    this.strict = false,
    XRPLLedgerIndex? ledgerIndex = XRPLLedgerIndex.validated,
  });
  @override
  String get method => XRPRequestMethod.gatewayBalances;

  final String account;
  final bool strict;

  /// should be string or list String
  final dynamic hotWallet;
  @override
  String? get validate {
    if (hotWallet != null) {
      if (hotWallet is! String && hotWallet is! List<String>) {
        return "hotWallet variable should be string or list String";
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "account": XRPAddressUtils.ensureClassicAddress(account),
      "strict": strict,
      "hotWallet": hotWallet
    };
  }

  @override
  List<XRPIssueToken> onResonse(Map<String, dynamic> result) {
    if (result["assets"] == null) return List.empty();
    final Map<String, dynamic> assets = (result["assets"] as Map).cast();
    final issuers = assets.keys.toList();
    final List<Map<String, dynamic>> tokens = [];
    for (final i in issuers) {
      final List<Map<String, dynamic>> currencies = (assets[i] as List).cast();
      for (final c in currencies) {
        tokens.add(c..addAll({"issuer": i}));
      }
    }
    return tokens.map((e) => XRPIssueToken.fromJson(e)).toList();
  }
}

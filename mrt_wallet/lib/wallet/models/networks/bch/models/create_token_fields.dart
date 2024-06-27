import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/models/networks/bitcoin/models/memo.dart';
import 'package:mrt_wallet/wallet/models/networks/bch/models/cash_token.dart';
import 'package:mrt_wallet/wallet/models/networks/bch/models/cash_token_bcmr.dart';

class BCMRWithCategory extends BCMR {
  BCMRWithCategory(
      {required this.categoryId, required super.uris, required super.hash});
  final String categoryId;

  @override
  String toString() {
    return "$hash ${uris.map((e) => e).join(" ")}";
  }
}

class CreateCashTokenInfo {
  CreateCashTokenInfo({required this.token, required this.bcmr});
  factory CreateCashTokenInfo.withBcmrs(
      {required CashToken token, required List<CashTokenBCMR> bcmrs}) {
    final bchCashToken = BCHCashToken(cashToken: token);
    if (bcmrs.isNotEmpty) {
      final uris = bcmrs.map((e) => e.uri).toList();
      final hash = bcmrs.first.hash;
      final script =
          BCMRWithCategory(categoryId: token.category, uris: uris, hash: hash);
      return CreateCashTokenInfo(
          token: bchCashToken,
          bcmr: BitcoinMemo.fromScript(script, script.toString()));
    }
    return CreateCashTokenInfo(token: bchCashToken, bcmr: null);
  }
  final BCHCashToken token;
  final BitcoinMemo? bcmr;
}

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/networks/bch/models/cash_token_bcmr.dart';

class BCHUtils {
  static final BigRational maximumTokenCashTotalSupply =
      BigRational(BigInt.parse("9223372036854775807"));
  static final BigRational minimumTokenCashTotalSupply = BigRational.one;
  static const String hintIPFSUri =
      "bafkreihfrxykireezlcp2jstp7cjwx5nl7of3nuul3qnubxygwvwcjun44";
  static const int maxBCHOpReturnSize = 233;
  static const int maxCommitment = 40;
  static final BigInt minimumSatoshiTokenOutput = BigInt.from(900);
  static final BigInt minimumOutput = BigInt.from(900);
  static const int decimal = 8;

  static Future<CashTokenBCMR> getBCMR(String uri) async {
    final MethodResult<String> result = await HttpUtils.get<String>(uri);
    final Map<String, dynamic>? inJson =
        MethodUtils.nullOnException(() => StringUtils.toJson(result.result));
    if (inJson == null) {
      throw const ApiProviderException(message: "invalid_json_response");
    }
    final hash = BytesUtils.toHexString(
        QuickCrypto.sha256Hash(StringUtils.encode(result.result)));
    return CashTokenBCMR(
        hash: hash, uri: _cleanUpBCMRUri(uri), content: inJson);
  }

  static Script toBCMIScript(List<CashTokenBCMR> bcmr) {
    assert(bcmr.isNotEmpty, "should be add at least one bcmr");
    return Script(script: [
      "OP_RETURN",
      bcmr.first.hash,
      ...bcmr.map((e) => e.uri).toList()
    ]);
  }

  static String _cleanUpBCMRUri(String uri) {
    if (uri.startsWith("https://ipfs.io/ipfs/")) {
      return "ipfs://${uri.replaceFirst("https://ipfs.io/ipfs/", "")}";
    }
    final parse = Uri.parse(uri);
    if (uri.endsWith("/.well-known/bitcoin-cash-metadata-registry.json")) {
      final subdomains = parse.host.split(".");
      if (subdomains.length > 2) {
        return "${parse.host}/";
      }
      return parse.host;
    }

    return uri;
  }

  static bool commitmentValidate(String? v) {
    if (v == null) return true;
    if (StringUtils.toBytes(v).length <= maxCommitment) {
      return true;
    }
    return false;
  }

  static CashToken createCashToken(
      {String? category,
      BigInt? amount,
      String? commitment,
      int? bitfield,
      CashTokenCapability? capability}) {
    return CashToken(
        category: category ?? "0" * 64,
        bitfield: bitfield ??
            CashTokenUtils.buildBitfield(
                hasAmount: amount != null,
                hasCommitmentLength: capability != null && commitment != null,
                capability: capability,
                hasNFT: capability != null),
        commitment: commitment == null ? null : StringUtils.toBytes(commitment),
        amount: amount);
  }
}

import 'package:blockchain_utils/utils/string/string.dart';
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/models/wallet_models/external/external.dart';

void main() async {
  const uri =
      "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd";
  final g = await http.get(Uri.parse(uri));
  final Map<String, dynamic> decode = StringUtils.toJson(g.body);
  print("data $decode");
  final Map<String, CoingeckoCoinInfo> a = decode.map(
    (key, value) => MapEntry(key, CoingeckoCoinInfo.fromJson(value, key)),
  );
  print(a["solana"]?.getPrice(Currency.USD));
}

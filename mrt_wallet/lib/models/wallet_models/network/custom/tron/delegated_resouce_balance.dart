import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/tron/tron_utils.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:on_chain/on_chain.dart';

class MaxDelegatedResourceAmount {
  MaxDelegatedResourceAmount._(this.amoumt, this.resourceCode);
  factory MaxDelegatedResourceAmount.fromJson(
      Map<String, dynamic> json, int resourceId) {
    final resource = ResourceCode.fromValue(resourceId);
    return MaxDelegatedResourceAmount._(
        NoneDecimalBalance(
            BigintUtils.tryParse(json["max_size"]) ?? BigInt.zero,
            TronUtils.decimal),
        resource);
  }
  final NoneDecimalBalance amoumt;
  final ResourceCode resourceCode;

  @override
  String toString() {
    return "MaxDelegatedResourceAmount{amount: $amoumt, resource: $resourceCode}";
  }
}

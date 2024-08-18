import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/crypto/utils/tron/tron.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:on_chain/on_chain.dart';

class MaxDelegatedResourceAmount {
  MaxDelegatedResourceAmount._(this.amoumt, this.resourceCode);
  factory MaxDelegatedResourceAmount.fromJson(
      Map<String, dynamic> json, int resourceId) {
    final resource = ResourceCode.fromValue(resourceId);
    return MaxDelegatedResourceAmount._(
        IntegerBalance(BigintUtils.tryParse(json["max_size"]) ?? BigInt.zero,
            TronUtils.decimal),
        resource);
  }
  final IntegerBalance amoumt;
  final ResourceCode resourceCode;

  @override
  String toString() {
    return "MaxDelegatedResourceAmount{amount: $amoumt, resource: $resourceCode}";
  }
}

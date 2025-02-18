import 'package:mrt_wallet/wallet/web3/networks/sui/params/models/transaction.dart';
import 'package:test/test.dart';

import 'test_vectors/ts_sdk_transactions.dart';

void main() {
  _test();
}

void _test() {
  test("Sui parsing ts-sdk transaction scheme.", () {
    final v1 = Web3SuiTransactionDataV2.fromJson(suiTsSdkV1e2);
    final v2 = Web3SuiTransactionDataV2.fromJson(suiTsSdkV2e2);
    expect(v1.toJson(), v2.toJson());
  });
  test("Sui parsing ts-sdk transaction scheme.", () {
    final v1 = Web3SuiTransactionDataV2.fromJson(suiTsSdkV1);
    final v2 = Web3SuiTransactionDataV2.fromJson(suiTsSdkV2);
    expect(v1.toJson(), v2.toJson());
  });
}

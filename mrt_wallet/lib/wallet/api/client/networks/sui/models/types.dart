import 'package:blockchain_utils/helper/helper.dart';
import 'package:on_chain/sui/src/address/address/address.dart';
import 'package:on_chain/sui/src/rpc/models/types/types.dart';

class SuiCachedAccountCoins {
  final List<SuiApiCoinResponse> coinData;
  final DateTime created;
  SuiCachedAccountCoins(List<SuiApiCoinResponse> coinData)
      : coinData = coinData.immutable,
        created = DateTime.now().add(const Duration(minutes: 1));
  bool get isValue => created.isAfter(DateTime.now());
}

class SuiObjectResponse {
  final SuiAddress objectId;
  final String digest;
  final BigInt version;
  final BigInt? initialVersion;
  const SuiObjectResponse(
      {required this.objectId,
      required this.digest,
      required this.version,
      required this.initialVersion});
}

class SuiExcuteTransactionData {
  final String? digest;
  final String? rawTransactionData;
  final String? error;
  final Map<String, dynamic> effects;
  const SuiExcuteTransactionData(
      {required this.digest,
      required this.rawTransactionData,
      required this.error,
      required this.effects});
}

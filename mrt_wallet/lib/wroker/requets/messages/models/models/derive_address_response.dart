import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

class CryptoDeriveAddressResponse<NETWORKADDRESS> {
  final NewAccountParams<NETWORKADDRESS> accountParams;
  final List<int> publicKey;
  CryptoDeriveAddressResponse(
      {required this.accountParams, required List<int> publicKey})
      : publicKey = BytesUtils.toBytes(publicKey, unmodifiable: true);

  ChainAccount toAccount(WalletNetwork network) {
    return accountParams.toAccount(network, publicKey);
  }
}

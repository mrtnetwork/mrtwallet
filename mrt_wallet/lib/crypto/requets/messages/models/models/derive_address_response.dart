import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

class CryptoDeriveAddressResponse<NETWORKADDRESS> {
  final NewAccountParams<NETWORKADDRESS> accountParams;
  final CryptoPublicKeyData publicKey;

  CryptoDeriveAddressResponse(
      {required this.accountParams, required this.publicKey});

  ChainAccount toAccount(WalletNetwork network) {
    return accountParams.toAccount(network, publicKey);
  }
}

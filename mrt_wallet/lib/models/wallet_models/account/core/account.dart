import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class NetworkAccountCore with CborSerializable {
  abstract final AppNetworkImpl network;
  abstract final List<CryptoAddress> addresses;
  abstract final CryptoAddress address;
  AddressDerivationIndex nextDrive(CryptoCoins coin);
  void removeAccount(CryptoAddress address);
  bool get haveAddress;
  void addNewAddress(List<int> publicKey, NewAccountParams accountParams);
  void switchAccount(CryptoAddress address);
}

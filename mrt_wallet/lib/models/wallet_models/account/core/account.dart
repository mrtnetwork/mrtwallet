import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/contact/contact.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

abstract class NetworkAccountCore<N, T, X> with CborSerializable {
  abstract final AppNetworkImpl network;
  abstract final List<CryptoAccountAddress<N, T, X>> addresses;
  abstract final List<ContactCore<X>> contacts;
  void addContact(ContactCore<X> newContact);
  void removeContact(ContactCore<X> contact);
  CryptoAccountAddress? getAddress(String address);
  ContactCore<X>? getContact(String address);
  ReceiptAddress<X>? getReceiptAddress(String address);
  abstract final CryptoAccountAddress address;
  AddressDerivationIndex nextDrive(CryptoCoins coin);
  void removeAccount(CryptoAccountAddress<N, T, X> address);
  bool get haveAddress;
  void addNewAddress(List<int> publicKey, NewAccountParams accountParams);
  void switchAccount(CryptoAccountAddress<N, T, X> address);
}

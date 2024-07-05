import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wroker/worker.dart';

abstract class NetworkAccountCore<T, X> with CborSerializable {
  abstract final WalletNetwork network;
  abstract final List<CryptoAddress<T, X>> addresses;
  abstract final List<ContactCore<X>> contacts;
  abstract final Live<BalanceCore<BigInt>> totalBalance;
  void refreshTotalBalance();
  void addContact(ContactCore<X> newContact);
  void removeContact(ContactCore<X> contact);
  CryptoAddress? getAddress(String address);
  ContactCore<X>? getContact(String address);
  ReceiptAddress<X>? getReceiptAddress(String address);
  abstract final CryptoAddress address;
  Bip32AddressIndex nextDerive(CryptoCoins coin,
      {SeedTypes seedGeneration = SeedTypes.bip39});
  void removeAccount(CryptoAddress<T, X> address);
  bool get haveAddress;
  CryptoAddress<T, X> addNewAddress(
      List<int> publicKey, NewAccountParams accountParams);
  void switchAccount(CryptoAddress<T, X> address);
  List<TokenCore> tokens();
}

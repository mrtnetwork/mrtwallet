import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/address.dart';
import 'package:mrt_wallet/wallet/models/account/account/core/account.dart';
import 'package:mrt_wallet/wallet/models/contact/contact.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/wroker/worker.dart';

class Bip32NetworkAccount<T, X> implements NetworkAccountCore<T, X> {
  Bip32NetworkAccount._(
      {required this.network,
      required this.totalBalance,
      List<CryptoAddress> addresses = const [],
      List<ContactCore> contacts = const [],
      required int addressIndex})
      : _addresses = List.unmodifiable(addresses),
        _addressIndex = addressIndex,
        _contacts = List.unmodifiable(contacts);
  Bip32NetworkAccount<T, X> copyWith(
      {WalletNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<CryptoAddress>? addresses,
      List<ContactCore>? contacts,
      int? addressIndex}) {
    return Bip32NetworkAccount._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? this._addressIndex,
        addresses: addresses ?? this._addresses,
        contacts: contacts ?? this._contacts);
  }

  factory Bip32NetworkAccount.setup(WalletNetwork network) {
    return Bip32NetworkAccount._(
        network: network,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)));
  }
  factory Bip32NetworkAccount.fromHex(String cborHex, WalletNetwork network) {
    return Bip32NetworkAccount.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(cborHex));
  }
  factory Bip32NetworkAccount.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.iAccount);
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final toAccounts =
        accounts.map((e) => CryptoAddress.fromCbor(network, e)).toList();
    int addressIndex = 0;
    final String? currentAddress = cbor.elementAt(2);
    if (currentAddress != null) {
      final index = MethodUtils.nullOnException(() => toAccounts.indexWhere(
              (element) => element.address.toAddress == currentAddress)) ??
          0;
      if (index > 0) {
        addressIndex = index;
      }
    }
    List<ContactCore> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) => ContactCore.fromCborBytesOrObject(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return Bip32NetworkAccount._(
        network: network,
        addresses: toAccounts.cast(),
        addressIndex: addressIndex,
        contacts: contacts,
        totalBalance: Live(IntegerBalance(
            totalBalance ?? BigInt.zero, network.coinParam.token.decimal!)))
      ..refreshTotalBalance();
  }

  @override
  final WalletNetwork network;
  List<CryptoAddress<T, X>> _addresses;

  @override
  List<CryptoAddress<T, X>> get addresses => _addresses;

  @override
  bool get haveAddress => addresses.isNotEmpty;
  List<ContactCore<X>> _contacts;
  @override
  List<ContactCore<X>> get contacts => _contacts;
  int _addressIndex;
  @override
  final Live<IntegerBalance> totalBalance;
  @override
  CryptoAddress get address => addresses.elementAt(_addressIndex);

  @override
  Bip32AddressIndex nextDerive(CryptoCoins coin,
      {SeedTypes seedGeneration = SeedTypes.bip39}) {
    return BipDerivationUtils.generateAccountNextKeyIndex(
        coin: coin, addresses: addresses, seedGenerationType: seedGeneration);
  }

  @override
  CryptoAddress<T, X> addNewAddress(
      List<int> publicKey, NewAccountParams accountParams) {
    if (!network.coins.contains(accountParams.coin)) {
      throw WalletExceptionConst.invalidCoin;
    }
    final CryptoAddress newAddress =
        accountParams.toAccount(network, publicKey);
    if (newAddress is! CryptoAddress<T, X>) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final any = addresses.any((element) => element.isEqual(newAddress));
    if (any) {
      throw WalletExceptionConst.addressAlreadyExist;
    }

    _addresses = List.unmodifiable([newAddress, ..._addresses]);
    return newAddress;
  }

  @override
  void switchAccount(CryptoAddress<T, X> address) {
    final index = addresses.indexOf(address);
    if (index < 0 || index == _addressIndex) return;
    _addressIndex = index;
  }

  @override
  void removeAccount(CryptoAddress address) {
    if (!addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    final currentAccounts = List<CryptoAddress<T, X>>.from(_addresses);
    currentAccounts.remove(address);
    _addressIndex = 0;
    _addresses = currentAccounts;
  }

  @override
  CborTagValue toCbor() {
    String? currentAddress;
    if (_addresses.isNotEmpty) {
      currentAddress = address.address.toAddress;
    }
    return CborTagValue(
        CborListValue.fixedLength([
          network.value,
          CborListValue.fixedLength(addresses.map((e) => e.toCbor()).toList()),
          currentAddress ?? const CborNullValue(),
          CborListValue.fixedLength(contacts.map((e) => e.toCbor()).toList()),
          totalBalance.value.balance
        ]),
        CborTagsConst.iAccount);
  }

  @override
  CryptoAddress? getAddress(String address) {
    return MethodUtils.nullOnException(() => _addresses
        .firstWhere((element) => element.address.toAddress == address));
  }

  @override
  ContactCore<X>? getContact(String address) {
    return MethodUtils.nullOnException(() {
      return _contacts.firstWhere((element) {
        return element.address == address;
      });
    });
  }

  @override
  void addContact(ContactCore newContact) {
    final validate = MethodUtils.nullOnException(() {
      if (newContact.name.length < 3) return null;
      return ContactCore.newContact(
          network: network,
          address: newContact.addressObject,
          name: newContact.name);
    });
    if (validate == null || validate.address != newContact.address) {
      throw WalletExceptionConst.invalidContactDetails;
    }
    final exist = getContact(newContact.address);
    if (exist != null) {
      throw WalletExceptionConst.contactExists;
    }
    _contacts = List.unmodifiable([newContact, ..._contacts]);
  }

  @override
  void removeContact(ContactCore contact) {
    final findContact = getContact(contact.address);
    if (findContact == null) return;
    final newContacts =
        _contacts.where((element) => element != findContact).toList();
    _contacts = List.unmodifiable(newContacts);
  }

  @override
  ReceiptAddress<X>? getReceiptAddress(String address) {
    final isAccount = getAddress(address);
    if (isAccount != null) {
      return ReceiptAddress<X>(
          account: isAccount,
          view: isAccount.address.toAddress,
          type: isAccount.type,
          networkAddress: isAccount.networkAddress);
    }
    final contact = getContact(address);
    if (contact != null) {
      return ReceiptAddress<X>(
          contact: contact,
          view: contact.address,
          type: contact.type,
          networkAddress: contact.addressObject);
    }
    return null;
  }

  @override
  void refreshTotalBalance() {
    Map<String, BigInt> total = {
      for (final i in addresses)
        i.orginalAddress: i.address.balance.value.balance
    };
    final totalBalances = total.values
        .fold(BigInt.zero, (previousValue, element) => previousValue + element);
    totalBalance.value.updateBalance(totalBalances);
  }

  @override
  List<TokenCore> tokens() {
    return addresses.map((e) => e.tokens).expand((e) => e).toList();
  }
}

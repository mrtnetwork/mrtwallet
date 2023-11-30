import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class Bip32NetworkAccount implements NetworkAccountCore {
  factory Bip32NetworkAccount.setup(AppNetworkImpl network) {
    return Bip32NetworkAccount._(network: network, addressIndex: 0);
  }
  Bip32NetworkAccount._(
      {required this.network,
      List<Bip32AddressCore> addresses = const [],
      required int addressIndex})
      : _addresses = List.unmodifiable(addresses),
        _addressIndex = addressIndex;
  factory Bip32NetworkAccount.fromHex(String cborHex) {
    return Bip32NetworkAccount.fromCborBytesOrObject(
        bytes: BytesUtils.fromHexString(cborHex));
  }
  factory Bip32NetworkAccount.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.iAccount);
      final network = AppBitcoinNetwork.fromValue(cbor.value[0].value);
      final CborListValue accounts = cbor.value[1];
      final toAccounts = accounts.value
          .map((e) => IBitcoinAddress.fromCborBytesOrObject(obj: e))
          .toList();

      int? addressIndex;
      if (cbor.value[2] is CborStringValue) {
        try {
          final String addr = cbor.value[2].value;
          final index = toAccounts
              .indexWhere((element) => element.address.toAddress == addr);
          if (index >= 0) {
            addressIndex = index;
          }
          // ignore: empty_catches
        } on StateError {}
      }

      return Bip32NetworkAccount._(
          network: network,
          addresses: toAccounts,
          addressIndex: addressIndex ?? 0);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  @override
  final AppNetworkImpl network;
  List<Bip32AddressCore> _addresses;

  @override
  List<Bip32AddressCore> get addresses => _addresses;

  @override
  bool get haveAddress => addresses.isNotEmpty;

  @override
  Bip32AddressIndex nextDrive(CryptoCoins coin) {
    final List<Bip32AddressIndex> addressIndex = addresses
        .map((e) => e.keyIndex)
        .whereType<Bip32AddressIndex>()
        .toList();
    final int purposeIndex = (coin.proposal as BipProposal).purpose.index;
    final int coinIndex = Bip32KeyIndex.hardenIndex(coin.conf.coinIdx).index;
    for (int i = 0; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = Bip32AddressIndex(
          purpose: purposeIndex,
          coin: coinIndex,
          accountLevel: 0,
          changeLevel: 0,
          addressIndex: i);
      if (!addressIndex.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }

  @override
  void addNewAddress(List<int> publicKey, NewAccountParams accountParams) {
    if (accountParams is! BitcoinNewAddressParams) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (!network.coins.contains(accountParams.coin)) {
      throw WalletExceptionConst.invalidCoin;
    }
    IBitcoinAddress newAddress;
    if (accountParams.isMultiSig) {
      accountParams as BitcoinMultiSigNewAddressParams;
      newAddress = IBitcoinMultiSigAddress.newAccount(
          bitcoinAddressType: accountParams.bitcoinAddressType,
          coin: accountParams.coin,
          multiSignatureAddress: accountParams.multiSignatureAddress,
          network: network as AppBitcoinNetwork);
    } else {
      newAddress = IBitcoinAddress.newAccount(
          accountParams: accountParams,
          publicKey: publicKey,
          network: network as AppBitcoinNetwork);
    }
    if (addresses.contains(newAddress)) {
      throw WalletExceptionConst.addressAlreadyExist;
    }
    _addresses = List.unmodifiable([newAddress, ..._addresses]);
  }

  int _addressIndex;
  @override
  CryptoAddress get address => addresses.elementAt(_addressIndex);

  @override
  void switchAccount(CryptoAddress address) {
    if (address is! Bip32AddressCore) return;
    final index = addresses.indexOf(address);
    if (index < 0 || index == _addressIndex) return;
    _addressIndex = index;
  }

  @override
  void removeAccount(CryptoAddress address) {
    if (address is! Bip32AddressCore) return;
    if (!addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    final currentAccounts = List<Bip32AddressCore>.from(_addresses);
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
          currentAddress ?? const CborNullValue()
        ]),
        WalletModelCborTagsConst.iAccount);
  }
}

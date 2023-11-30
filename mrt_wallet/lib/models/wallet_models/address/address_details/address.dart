import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';

import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class CryptoAddressDetails implements CryptoAddressDetailsCore {
  CryptoAddressDetails(
      {required this.address,
      required CurrencyBalance balance,
      DateTime? updated})
      : _updated = updated ?? DateTime.now(),
        balance = Live<CurrencyBalance>(balance);

  factory CryptoAddressDetails.fromCborBytesOrObject(int currencyDecimal,
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.address);
      final String address = cbor.value[0].value;
      final BigInt balance = cbor.value[1].value;
      final DateTime updated = cbor.value[2].value;
      return CryptoAddressDetails(
          address: address,
          balance: CurrencyBalance(balance, currencyDecimal),
          updated: updated);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  final String address;

  @override
  final Live<CurrencyBalance> balance;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [address, balance.value.balance, CborEpochIntValue(updated)]),
        WalletModelCborTagsConst.address);
  }

  @override
  String get toAddress {
    return address;
  }

  @override
  String get viewBalance => balance.toString();

  DateTime _updated;

  @override
  DateTime get updated => _updated;

  @override
  void updateBalance(BigInt updateBalance) {
    balance.value.updateBalance(updateBalance);
    balance.notify();
  }
}

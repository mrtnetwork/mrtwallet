import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class IntegerAddressBalance implements AddressBalanceCore<BigInt> {
  IntegerAddressBalance(
      {required this.address,
      required IntegerBalance balance,
      DateTime? updated})
      : _updated = updated ?? DateTime.now(),
        balance = Live<IntegerBalance>(balance);

  factory IntegerAddressBalance.fromCborBytesOrObject(int currencyDecimal,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.address);
    final String address = cbor.elementAt(0);
    final BigInt balance = cbor.elementAt(1);
    final DateTime updated = cbor.elementAt(2);
    return IntegerAddressBalance(
        address: address,
        balance: IntegerBalance(balance, currencyDecimal),
        updated: updated);
  }

  final String address;

  @override
  final Live<IntegerBalance> balance;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [address, balance.value.balance, CborEpochIntValue(updated)]),
        CborTagsConst.address);
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
  void updateBalance([BigInt? updateBalance]) {
    balance.value.updateBalance(updateBalance);
    if (updateBalance != null) {
      balance.notify();
    }
  }
}

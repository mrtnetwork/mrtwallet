import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class NoneDecimalNetworkAddressDetails
    implements NetworkAddressDetailsCore<BigInt> {
  NoneDecimalNetworkAddressDetails(
      {required this.address,
      required NoneDecimalBalance balance,
      DateTime? updated})
      : _updated = updated ?? DateTime.now(),
        balance = Live<NoneDecimalBalance>(balance);

  factory NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
      int currencyDecimal,
      {List<int>? bytes,
      CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.address);
    final String address = cbor.elementAt(0);
    final BigInt balance = cbor.elementAt(1);
    final DateTime updated = cbor.elementAt(2);
    return NoneDecimalNetworkAddressDetails(
        address: address,
        balance: NoneDecimalBalance(balance, currencyDecimal),
        updated: updated);
  }

  final String address;

  @override
  final Live<NoneDecimalBalance> balance;

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
  void updateBalance([BigInt? updateBalance]) {
    balance.value.updateBalance(updateBalance);
    if (updateBalance != null) {
      balance.notify();
    }
  }
}

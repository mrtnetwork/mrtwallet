import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart';

class TonContact with Equatable implements ContactCore<TonAddress> {
  TonContact._(
      {required this.addressObject, required this.created, required this.name});
  factory TonContact.newContact(
      {required TonAddress address, required String name}) {
    return TonContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory TonContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.tonContact);
      final String address = cbor.elementAt(0);
      final DateTime created = cbor.elementAt(1);
      final String name = cbor.elementAt(2);
      final TonAddress solanaAddress = TonAddress(address);

      return TonContact._(
          addressObject: solanaAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final TonAddress addressObject;
  @override
  String get address => addressObject.toString();
  @override
  final DateTime created;
  @override
  final String name;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address, CborEpochIntValue(created), name]),
        CborTagsConst.tonContact);
  }

  @override
  List get variabels => [address, name];

  @override
  String get type => addressObject.type.name;
}

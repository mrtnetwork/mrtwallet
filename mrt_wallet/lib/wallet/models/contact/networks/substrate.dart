import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateContact with Equatable implements ContactCore<SubstrateAddress> {
  SubstrateContact._(
      {required this.addressObject, required this.created, required this.name});
  factory SubstrateContact.newContact(
      {required SubstrateAddress address, required String name}) {
    return SubstrateContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory SubstrateContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.substrateContact);
    final String address = cbor.elementAt(0);
    final DateTime created = cbor.elementAt(1);
    final String name = cbor.elementAt(2);
    final SubstrateAddress cardanoAddr = SubstrateAddress(address);
    return SubstrateContact._(
        addressObject: cardanoAddr, created: created, name: name);
  }

  @override
  final SubstrateAddress addressObject;
  @override
  String get address => addressObject.address;
  @override
  final DateTime created;
  @override
  final String name;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address, CborEpochIntValue(created), name]),
        CborTagsConst.substrateContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}

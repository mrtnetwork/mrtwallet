import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarContact with Equatable implements ContactCore<StellarAddress> {
  StellarContact._(
      {required this.addressObject, required this.created, required this.name});
  factory StellarContact.newContact(
      {required StellarAddress address, required String name}) {
    return StellarContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory StellarContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.stellarContact);
      final String address = cbor.elementAt(0);
      final DateTime created = cbor.elementAt(1);
      final String name = cbor.elementAt(2);
      final StellarAddress solanaAddress =
          StellarAddress.fromBase32Addr(address);

      return StellarContact._(
          addressObject: solanaAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final StellarAddress addressObject;
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
        CborTagsConst.stellarContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}

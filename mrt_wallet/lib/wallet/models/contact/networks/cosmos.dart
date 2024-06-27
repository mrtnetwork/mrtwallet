import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CosmosContact with Equatable implements ContactCore<CosmosBaseAddress> {
  CosmosContact._(
      {required this.addressObject, required this.created, required this.name});
  factory CosmosContact.newContact(
      {required CosmosBaseAddress address, required String name}) {
    return CosmosContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory CosmosContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.cosmosContact);
      final String address = cbor.elementAt(0);
      final DateTime created = cbor.elementAt(1);
      final String name = cbor.elementAt(2);
      final CosmosBaseAddress cardanoAddr = CosmosBaseAddress(address);

      return CosmosContact._(
          addressObject: cardanoAddr, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final CosmosBaseAddress addressObject;
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
        CborTagsConst.cosmosContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaContact with Equatable implements ContactCore<SolAddress> {
  SolanaContact._(
      {required this.addressObject, required this.created, required this.name});
  factory SolanaContact.newContact(
      {required SolAddress address, required String name}) {
    return SolanaContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory SolanaContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.solanaContact);
      final String address = cbor.elementAt(0);
      final DateTime created = cbor.elementAt(1);
      final String name = cbor.elementAt(2);
      final SolAddress solanaAddress = SolAddress(address);

      return SolanaContact._(
          addressObject: solanaAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final SolAddress addressObject;
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
        CborTagsConst.solanaContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}

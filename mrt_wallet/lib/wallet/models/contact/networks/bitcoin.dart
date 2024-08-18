import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/crypto/utils/address/utils.dart';

class BitcoinContact with Equatable implements ContactCore<BitcoinBaseAddress> {
  BitcoinContact._(
      {required this.addressObject,
      required this.address,
      required this.created,
      required this.name});
  factory BitcoinContact.newContact(
      {required BitcoinBaseAddress address,
      required WalletBitcoinNetwork network,
      required String name}) {
    return BitcoinContact._(
      addressObject: address,
      address: address.toAddress(network.coinParam.transacationNetwork),
      created: DateTime.now(),
      name: name,
    );
  }
  factory BitcoinContact.fromCborBytesOrObject(WalletBitcoinNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.bitcoinContact);
      final String address = cbor.elementAt(0);
      final BitcoinAddressType type =
          BitcoinAddressType.fromValue(cbor.elementAt(1));
      final DateTime created = cbor.elementAt(2);
      final String name = cbor.elementAt(3);
      final bitcoinAddress = BlockchainAddressUtils.toBitcoinAddressFromType(
          bitcoinAddress: address, addressType: type, network: network);
      if (bitcoinAddress.toAddress(network.coinParam.transacationNetwork) !=
          address) {
        throw WalletExceptionConst.invalidContactDetails;
      }
      return BitcoinContact._(
          addressObject: bitcoinAddress,
          address: address,
          created: created,
          name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final BitcoinBaseAddress addressObject;
  @override
  final String address;
  @override
  final DateTime created;
  @override
  final String name;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          address,
          addressObject.type.value,
          CborEpochIntValue(created),
          name
        ]),
        CborTagsConst.bitcoinContact);
  }

  @override
  List get variabels => [address, name];

  @override
  late final String type = addressObject.type.value;
}

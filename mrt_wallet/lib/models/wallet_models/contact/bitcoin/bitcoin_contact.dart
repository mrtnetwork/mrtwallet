import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/blockchain_addr_utils.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/contact/contract_core.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class BitcoinContact with Equatable implements ContactCore {
  BitcoinContact._(
      {required this.addressObject,
      required this.address,
      required this.created,
      required this.name});
  factory BitcoinContact.newContact(
      {required BitcoinAddress address,
      required AppBitcoinNetwork network,
      required String name}) {
    return BitcoinContact._(
      addressObject: address,
      address: address.toAddress(network.coinParam.transacationNetwork),
      created: DateTime.now(),
      name: name,
    );
  }
  factory BitcoinContact.fromCborBytesOrObject(AppBitcoinNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.bitcoinContact);
      final String address = cbor.getIndex(0);
      final BitcoinAddressType type =
          BitcoinAddressType.fromValue(cbor.getIndex(1));
      final DateTime created = cbor.getIndex(2);
      final String name = cbor.getIndex(3);
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
  final BitcoinAddress addressObject;
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
        WalletModelCborTagsConst.bitcoinContact);
  }

  @override
  List get variabels => [address, name];

  @override
  late final String type = addressObject.type.value;
}

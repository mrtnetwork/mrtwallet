import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/cardano.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/xrp.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/ton.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/tron.dart';
import 'package:mrt_wallet/wallet/models/network/core/network.dart';

abstract class ContactCore<T> with CborSerializable {
  abstract final T addressObject;
  abstract final String address;
  abstract final String name;
  abstract final DateTime created;
  abstract final String? type;
  static ContactCore fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    if (network is WalletBitcoinNetwork) {
      return BitcoinContact.fromCborBytesOrObject(network,
          bytes: bytes, obj: obj);
    } else if (network is WalletEthereumNetwork) {
      return EthereumContract.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is WalletTronNetwork) {
      return TronContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is WalletSolanaNetwork) {
      return SolanaContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is WalletCardanoNetwork) {
      return CardanoContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is WalletCosmosNetwork) {
      return CosmosContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is WalletTonNetwork) {
      return TonContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    }
    return RippleContact.fromCborBytesOrObject(network as WalletXRPNetwork,
        bytes: bytes, obj: obj);
  }

  static ContactCore newContact<T>(
      {required WalletNetwork network,
      required dynamic address,
      required String name}) {
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
        return BitcoinContact.newContact(
            address: address, network: network.toNetwork(), name: name);
      case NetworkType.ethereum:
        return EthereumContract.newContact(address: address, name: name);
      case NetworkType.tron:
        return TronContact.newContact(address: address, name: name);
      case NetworkType.cardano:
        return CardanoContact.newContact(address: address, name: name);
      case NetworkType.cosmos:
        return CosmosContact.newContact(address: address, name: name);
      case NetworkType.solana:
        return SolanaContact.newContact(address: address, name: name);
      case NetworkType.ton:
        return TonContact.newContact(address: address, name: name);
      default:
        return RippleContact.newContact(
            address: address, network: network.toNetwork(), name: name);
    }
  }
}

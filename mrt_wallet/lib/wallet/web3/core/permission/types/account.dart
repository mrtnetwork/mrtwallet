import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/derivation/core/derivation.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/models/account.dart';

abstract class Web3ChainAccount<NETWORKADDRESS>
    with CborSerializable, Equatable {
  int get id;
  final AddressDerivationIndex keyIndex;
  final NETWORKADDRESS address;
  bool _defaultAddress;
  bool get defaultAddress => _defaultAddress;
  String get addressStr;
  Web3ChainAccount({
    required this.keyIndex,
    required this.address,
    required bool defaultAddress,
  }) : _defaultAddress = defaultAddress;

  void changeDefault(bool defaultAddress) {
    _defaultAddress = defaultAddress;
  }
}

abstract class Web3ChainAuthenticated with CborSerializable {
  NetworkType get networkType;
  const Web3ChainAuthenticated();
  factory Web3ChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(object: object, cborBytes: bytes, hex: hex);
    final type = NetworkType.fromTag(tag.tags);
    return switch (type) {
      NetworkType.solana =>
        Web3SolanaChainAuthenticated.deserialize(object: tag),
      NetworkType.ethereum =>
        Web3EthereumChainAuthenticated.deserialize(object: tag),
      NetworkType.ton => Web3TonChainAuthenticated.deserialize(object: tag),
      NetworkType.tron => Web3TronChainAuthenticated.deserialize(object: tag),
      NetworkType.stellar =>
        Web3StellarChainAuthenticated.deserialize(object: tag),
      NetworkType.substrate =>
        Web3SubstrateChainAuthenticated.deserialize(object: tag),
      NetworkType.aptos => Web3AptosChainAuthenticated.deserialize(object: tag),
      NetworkType.sui => Web3SuiChainAuthenticated.deserialize(object: tag),
      _ => throw WalletExceptionConst.invalidData(
          messsage: "unsuported web3 network")
    };
  }

  T cast<T extends Web3ChainAuthenticated>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/network/params/solana.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaChainAccount extends Web3ChainAccount<SolAddress> {
  final SolanaNetworkType genesis;
  Web3SolanaChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.genesis,
  });
  factory Web3SolanaChainAccount.fromChainAccount(
      {required ISolanaAddress address,
      required SolanaNetworkType genesis,
      required bool isDefault}) {
    return Web3SolanaChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        genesis: genesis,
        defaultAddress: isDefault);
  }

  factory Web3SolanaChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3SolanaAccount);
    return Web3SolanaChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: SolAddress(values.elementAt(1)),
        genesis: SolanaNetworkType.fromValue(values.elementAt(2)),
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.address,
          genesis.value,
          defaultAddress
        ]),
        CborTagsConst.web3SolanaAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  List get variabels => [keyIndex, addressStr, genesis];
}

class Web3SolanaChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3SolanaChainAccount> accounts;
  final WalletSolanaNetwork network;
  final String? serviceIdentifier;
  Web3SolanaChainAuthenticated(
      {required List<Web3SolanaChainAccount> accounts,
      required this.network,
      required this.serviceIdentifier})
      : accounts = accounts.immutable;

  factory Web3SolanaChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.solana.tag);
    return Web3SolanaChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3SolanaChainAccount.deserialize(object: e))
            .toList(),
        network: WalletSolanaNetwork.fromCborBytesOrObject(
            obj: values.getCborTag(1)),
        serviceIdentifier: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          network.toCbor(),
          serviceIdentifier
        ]),
        networkType.tag);
  }

  @override
  NetworkType get networkType => NetworkType.solana;
}

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/params/solana.dart'
    show SolanaNetworkType;
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaChainAccount extends Web3ChainAccount<SolAddress> {
  @override
  final int id;
  final SolanaNetworkType network;
  Web3SolanaChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.id,
    required this.network,
  });
  @override
  Web3SolanaChainAccount clone({
    AddressDerivationIndex? keyIndex,
    SolAddress? address,
    bool? defaultAddress,
    int? id,
    List<int>? publicKey,
    SolanaNetworkType? network,
  }) {
    return Web3SolanaChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        network: network ?? this.network);
  }

  factory Web3SolanaChainAccount.fromChainAccount(
      {required ISolanaAddress address,
      required int id,
      required SolanaNetworkType network,
      required bool isDefault}) {
    return Web3SolanaChainAccount(
        keyIndex: address.keyIndex,
        network: network,
        address: address.networkAddress,
        id: id,
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
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        network: SolanaNetworkType.fromValue(values.elementAs(4)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.address,
          id,
          defaultAddress,
          network.value
        ]),
        CborTagsConst.web3SolanaAccount);
  }

  @override
  String get addressStr => address.address;
}

class Web3SolanaChainAuthenticated
    extends Web3ChainAuthenticated<Web3SolanaChainAccount> {
  @override
  final List<Web3ChainDefaultIdnetifier> networks;
  @override
  final Web3ChainDefaultIdnetifier currentNetwork;
  Web3SolanaChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3ChainDefaultIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.solana);

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
      networks: values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => Web3ChainDefaultIdnetifier.deserialize(object: e))
          .toList(),
      currentNetwork: Web3ChainDefaultIdnetifier.deserialize(
          object: values.elementAs<CborTagValue>(2)),
    );
  }
}

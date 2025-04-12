import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/networks/ton/models/account_context.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonChainAccount extends Web3ChainAccount<TonAddress> {
  @override
  final int id;
  final TonAccountContext accountContext;
  final List<int> publicKey;
  final TonChain network;
  String get identifier {
    switch (network) {
      case TonChain.testnet:
        return "ton:testnet";
      case TonChain.mainnet:
        return "ton:mainnet";
      default:
        throw UnimplementedError("Invalid ton network.");
    }
  }

  Web3TonChainAccount._({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.id,
    required List<int> publicKey,
    required this.accountContext,
    required this.network,
  }) : publicKey = publicKey.asImmutableBytes;
  @override
  Web3TonChainAccount clone({
    AddressDerivationIndex? keyIndex,
    TonAddress? address,
    bool? defaultAddress,
    int? id,
    List<int>? publicKey,
    TonChain? network,
    TonAccountContext? accountContext,
  }) {
    return Web3TonChainAccount._(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        publicKey: publicKey ?? this.publicKey,
        network: network ?? this.network,
        accountContext: accountContext ?? this.accountContext);
  }

  factory Web3TonChainAccount.fromChainAccount(
      {required ITonAddress address,
      required int id,
      required bool isDefault,
      required TonChain network}) {
    return Web3TonChainAccount._(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        accountContext: address.context,
        publicKey: address.publicKey,
        network: network);
  }

  factory Web3TonChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3TonAccount);
    return Web3TonChainAccount._(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: TonAddress(values.elementAs(1)),
        id: values.elementAs(2),
        defaultAddress: values.elementAs(3),
        accountContext: TonAccountContext.deserialize(
            object: values.elementAs<CborTagValue>(4)),
        publicKey: values.elementAs(5),
        network: TonChain.fromWorkchain(values.elementAs(6)));
  }
  VersionedWalletContract toWalletContract(TonChain chain) {
    return accountContext.toWalletContract(publicKey: publicKey, chain: chain);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toFriendlyAddress(),
          id,
          defaultAddress,
          accountContext.toCbor(),
          CborBytesValue(publicKey),
          network.workchain
        ]),
        CborTagsConst.web3TonAccount);
  }

  @override
  String get addressStr => address.toFriendlyAddress();

  List<int> get accountState =>
      toWalletContract(network).state!.initialState().serialize().toBoc();
}

class Web3TonChainAuthenticated
    extends Web3ChainAuthenticated<Web3TonChainAccount> {
  @override
  final List<Web3ChainDefaultIdnetifier> networks;
  @override
  final Web3ChainDefaultIdnetifier currentNetwork;
  Web3TonChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3ChainDefaultIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.ton);

  factory Web3TonChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object, cborBytes: bytes, hex: hex, tags: NetworkType.ton.tag);
    return Web3TonChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3TonChainAccount.deserialize(object: e))
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

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/ton/models/account_context.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonChainAccount extends Web3ChainAccount<TonAddress> {
  final int workChain;
  final TonAccountContext accountContext;
  final List<int> publicKey;
  Web3TonChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.workChain,
    required List<int> publicKey,
    required this.accountContext,
  }) : publicKey = publicKey.asImmutableBytes;
  factory Web3TonChainAccount.fromChainAccount(
      {required ITonAddress address,
      required int workChain,
      required bool isDefault}) {
    return Web3TonChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        workChain: workChain,
        defaultAddress: isDefault,
        accountContext: address.context,
        publicKey: address.publicKey);
  }

  factory Web3TonChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3TonAccount);
    return Web3TonChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: TonAddress(values.elementAt(1)),
        workChain: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        accountContext:
            TonAccountContext.deserialize(object: values.elementAs(4)),
        publicKey: values.elementAs(5));
  }
  VersionedWalletContract toWalletContract() {
    return accountContext.toWalletContract(
        publicKey: publicKey, chain: TonChain.fromWorkchain(workChain));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toFriendlyAddress(),
          workChain,
          defaultAddress,
          accountContext.toCbor(),
          CborBytesValue(publicKey)
        ]),
        CborTagsConst.web3TonAccount);
  }

  @override
  String get addressStr => address.toFriendlyAddress();

  @override
  List get variabels => [keyIndex, addressStr, workChain];
}

class Web3TonChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3TonChainAccount> accounts;
  final WalletTonNetwork network;
  final String? serviceIdentifier;
  Web3TonChainAuthenticated(
      {required this.accounts,
      required this.network,
      required this.serviceIdentifier});
  factory Web3TonChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object, cborBytes: bytes, hex: hex, tags: NetworkType.ton.tag);
    return Web3TonChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3TonChainAccount.deserialize(object: e))
            .toList(),
        network:
            WalletTonNetwork.fromCborBytesOrObject(obj: values.getCborTag(1)),
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
  NetworkType get networkType => NetworkType.ton;
}

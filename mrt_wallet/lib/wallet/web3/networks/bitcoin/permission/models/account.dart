import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class Web3BitcoinChainAccount extends Web3ChainAccount<BitcoinBaseAddress> {
  @override
  final int id;
  final BitcoinAddressType type;
  final String addressProgram;
  final BasedUtxoNetwork network;
  final List<int> publicKey;
  final String? witnessScript;
  final String? redeemScript;

  Web3BitcoinChainAccount._(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.addressProgram,
      required this.type,
      required this.network,
      required this.witnessScript,
      required this.redeemScript,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;

  @override
  Web3BitcoinChainAccount clone(
      {AddressDerivationIndex? keyIndex,
      BitcoinBaseAddress? address,
      bool? defaultAddress,
      int? id,
      int? signingScheme,
      String? witnessScript,
      String? redeemScript,
      BasedUtxoNetwork? network,
      String? addressProgram,
      List<int>? publicKey,
      BitcoinAddressType? type}) {
    return Web3BitcoinChainAccount._(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        network: network ?? this.network,
        publicKey: publicKey ?? this.publicKey,
        witnessScript: witnessScript ?? this.witnessScript,
        redeemScript: redeemScript ?? this.redeemScript,
        addressProgram: addressProgram ?? this.addressProgram,
        type: type ?? this.type);
  }

  factory Web3BitcoinChainAccount.fromChainAccount(
      {required IBitcoinAddress address,
      required bool isDefault,
      required WalletBitcoinNetwork network}) {
    return Web3BitcoinChainAccount._(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: network.value,
        defaultAddress: isDefault,
        type: address.networkAddress.type,
        addressProgram: address.networkAddress.addressProgram,
        network: network.coinParam.transacationNetwork,
        publicKey: [],
        witnessScript: address.witnessScript()?.toHex(),
        redeemScript: address.redeemScript()?.toHex());
  }

  factory Web3BitcoinChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3BitcoinAccount);
    final type = BitcoinAddressType.fromValue(values.elementAs(4));
    final String program = values.elementAt(1);
    return Web3BitcoinChainAccount._(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        addressProgram: program,
        type: type,
        address:
            BitcoinBaseAddress.fromProgram(addressProgram: program, type: type),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        network: BasedUtxoNetwork.fromName(values.elementAs(5)),
        publicKey: values.elementAs(6),
        witnessScript: values.elementAs(7),
        redeemScript: values.elementAs(8));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.addressProgram,
          id,
          defaultAddress,
          type.value,
          network.value,
          CborBytesValue(publicKey),
          witnessScript,
          redeemScript
        ]),
        CborTagsConst.web3BitcoinAccount);
  }

  @override
  String get addressStr => address.toAddress(network);
}

class Web3BitcoinChainAuthenticated
    extends Web3ChainAuthenticated<Web3BitcoinChainAccount> {
  @override
  final List<Web3ChainDefaultIdnetifier> networks;
  @override
  final Web3ChainDefaultIdnetifier currentNetwork;
  Web3BitcoinChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3ChainDefaultIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.bitcoinAndForked);

  factory Web3BitcoinChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.bitcoinAndForked.tag);
    return Web3BitcoinChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3BitcoinChainAccount.deserialize(object: e))
            .toList(),
        networks: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => Web3ChainDefaultIdnetifier.deserialize(object: e))
            .toList(),
        currentNetwork: Web3ChainDefaultIdnetifier.deserialize(
            object: values.elementAs<CborTagValue>(2)));
  }

  @override
  NetworkType get networkType => NetworkType.bitcoinAndForked;
}

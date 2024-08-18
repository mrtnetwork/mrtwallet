import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:bitcoin_base/bitcoin_base.dart'
    show BitcoinAddressType, BitcoinCashAddress, BitcoinCashNetwork;
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/crypto/utils/address/utils.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class IBitcoinCashAddress extends IBitcoinAddress {
  IBitcoinCashAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.publicKey,
      required super.networkAddress,
      required super.address,
      required super.addressType,
      required super.network,
      super.accountName})
      : super();

  factory IBitcoinCashAddress.newAccount(
      {required BitcoinCashNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletNetwork network}) {
    network as WalletBitcoinCashNetwork;
    final transactionNetwork =
        network.coinParam.transacationNetwork as BitcoinCashNetwork;
    final bitcoinAddress = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey, accountParams.coin, accountParams.bitcoinAddressType);

    final addressDetauls = AccountBalance(
        address: bitcoinAddress.toAddress(transactionNetwork),
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return IBitcoinCashAddress._(
        coin: accountParams.coin,
        publicKey: publicKey,
        address: addressDetauls,
        keyIndex: accountParams.deriveIndex,
        networkAddress: bitcoinAddress,
        addressType: accountParams.bitcoinAddressType,
        network: network.value);
  }
  factory IBitcoinCashAddress.fromCbsorHex(WalletNetwork network, String hex) {
    return IBitcoinCashAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinCashAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    network as WalletBitcoinCashNetwork;
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.bitcoinCashMultiSigAccount)) {
      return IBitcoinCashMultiSigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }
    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.bitcoinCashAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.elementAt(3);
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAt(5));
    final bitcoinAddress = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey, coin, bitcoinAddressType);
    if (bitcoinAddress.toAddress(network.coinParam.transacationNetwork) !=
        address.toAddress) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final String? name = cbor.elementAt(7);
    return IBitcoinCashAddress._(
      coin: coin,
      publicKey: publicKey,
      address: address,
      keyIndex: keyIndex,
      networkAddress: bitcoinAddress,
      addressType: bitcoinAddressType,
      network: network.value,
      accountName: name,
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          addressType.value,
          network,
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.bitcoinCashAccount);
  }

  @override
  String get type => addressType.value;

  @override
  String get orginalAddress => networkAddress.addressProgram;

  @override
  bool isEqual(ChainAccount other) {
    return orginalAddress == other.orginalAddress;
  }

  @override
  NewAccountParams toAccountParams() {
    return BitcoinCashNewAddressParams(
        deriveIndex: keyIndex, bitcoinAddressType: addressType, coin: coin);
  }
}

class IBitcoinCashMultiSigAddress extends IBitcoinCashAddress
    with BitcoinMultiSigBase
    implements MultiSigCryptoAccountAddress {
  factory IBitcoinCashMultiSigAddress.newAccount(
      {required WalletBitcoinNetwork network,
      required BitcoinCashMultiSigNewAddressParams accountParam}) {
    try {
      final transactionNetwork =
          network.coinParam.transacationNetwork as BitcoinCashNetwork;
      final toBitcoinAddress = accountParam.multiSignatureAddress.fromType(
          network: network.coinParam.transacationNetwork,
          addressType: accountParam.bitcoinAddressType);
      final bitcoinCashAddress = BitcoinCashAddress.fromBaseAddress(
          toBitcoinAddress,
          network: transactionNetwork);
      final addressDetauls = AccountBalance(
          address: bitcoinCashAddress.toAddress(transactionNetwork),
          balance: IntegerBalance.zero(network.coinParam.decimal));

      return IBitcoinCashMultiSigAddress._(
        coin: accountParam.coin,
        address: addressDetauls,
        multiSignatureAddress: accountParam.multiSignatureAddress,
        networkAddress: toBitcoinAddress,
        addressType: accountParam.bitcoinAddressType,
        network: network.value,
        keyIndex: const MultiSigAddressIndex(),
      );
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  factory IBitcoinCashMultiSigAddress.fromCborHex(
      WalletNetwork network, String hex) {
    return IBitcoinCashMultiSigAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory IBitcoinCashMultiSigAddress.fromCborBytesOrObject(
      WalletNetwork network,
      {List<int>? bytes,
      CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.bitcoinCashMultiSigAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;
    final BitcoinMultiSignatureAddress multiSignatureAddress =
        BitcoinMultiSignatureAddress.fromCborBytesOrObject(
            obj: cbor.getCborTag(2));
    final int networkId = cbor.elementAt(5);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(3));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAt(4));
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(6));
    final bitcoinAddress = BlockchainAddressUtils.toBitcoinAddress(
        address.toAddress,
        (network as WalletBitcoinNetwork).coinParam.transacationNetwork,
        p2shAddressType: bitcoinAddressType);
    if (bitcoinAddressType != bitcoinAddress.type) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final String? name = cbor.elementAt(7);
    return IBitcoinCashMultiSigAddress._(
        coin: coin,
        address: address,
        networkAddress: bitcoinAddress,
        addressType: bitcoinAddressType,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        keyIndex: keyIndex,
        accountName: name);
  }
  IBitcoinCashMultiSigAddress._(
      {required super.coin,
      required super.networkAddress,
      required super.address,
      required super.addressType,
      required this.multiSignatureAddress,
      required super.network,
      required super.keyIndex,
      String? accountName})
      : super._(publicKey: const [], accountName: accountName);

  @override
  List<int> get publicKey => throw UnimplementedError();

  @override
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          addressType.value,
          network,
          keyIndex.toCbor(),
          accountName ?? const CborNullValue()
        ]),
        CborTagsConst.bitcoinCashMultiSigAccount);
  }

  @override
  bool get multiSigAccount => true;
  @override
  List get variabels => [
        addressType,
        keyIndex,
        network,
        multiSignatureAddress.multiSigScript.toHex()
      ];

  @override
  List<String> get signers =>
      multiSignatureAddress.signers.map((e) => e.publicKey).toList();

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAddress.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  String get orginalAddress => networkAddress.addressProgram;

  @override
  NewAccountParams toAccountParams() {
    return BitcoinCashMultiSigNewAddressParams(
        multiSignatureAddress: multiSignatureAddress,
        bitcoinAddressType: addressType,
        coin: coin);
  }
}

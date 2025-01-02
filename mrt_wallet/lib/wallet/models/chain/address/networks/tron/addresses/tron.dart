import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/tron.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';

import 'package:mrt_wallet/wallet/models/chain/address/creation_params/new_address.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'multisig.dart';

class ITronAddress extends ChainAccount<TronAddress, TronToken, NFTCore>
    with Equatable {
  ITronAddress._(
      {required this.keyIndex,
      required this.coin,
      required List<int> publicKey,
      required this.address,
      required this.network,
      required this.networkAddress,
      required List<TronToken> tokens,
      required List<NFTCore> nfts,
      String? accountName,
      TronAccountInfo? accountInfo,
      TronAccountResourceInfo? resource})
      : publicKey = List.unmodifiable(publicKey),
        _tokens = tokens.immutable,
        _nfts = List.unmodifiable(nfts),
        _accountName = accountName,
        _account = Live(accountInfo),
        _accountResource = Live(resource);

  factory ITronAddress.newAccount(
      {required TronNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletNetwork network}) {
    final tronAddress = TronAddress.fromPublicKey(publicKey);
    final addressDetauls = AccountBalance(
        address: tronAddress.toAddress(),
        balance: IntegerBalance.zero(network.coinParam.decimal));
    return ITronAddress._(
      coin: accountParams.coin,
      publicKey: publicKey,
      address: addressDetauls,
      keyIndex: accountParams.deriveIndex,
      networkAddress: tronAddress,
      network: network.value,
      tokens: const [],
      // trc20Token: const [],
      nfts: const [],
    );
  }
  factory ITronAddress.fromCbsorHex(String hex, WalletNetwork network) {
    return ITronAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ITronAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.tronMultisigAccount)) {
      return ITronMultisigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.tronAccount);
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

    final TronAddress ethAddress = TronAddress(cbor.elementAt(5));

    final List<TronToken> tokens = [
      ...cbor
          .elementAsListOf<CborTagValue>(7)
          .map((e) => TronToken.deserialize(object: e)),
      ...cbor
              .elementAs<CborListValue?>(8)
              ?.value
              .map((e) => TronToken.deserialize(object: e)) ??
          []
    ];
    final String? accountName = cbor.elementAt(10);
    final account = cbor.getCborTag(11);
    final resource = cbor.getCborTag(12);
    return ITronAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: ethAddress,
        network: networkId,
        tokens: tokens,
        nfts: [],
        accountName: accountName,
        accountInfo: account == null
            ? null
            : TronAccountInfo.fromCborBytesOrObject(obj: account),
        resource: resource == null
            ? null
            : TronAccountResourceInfo.fromCborBytesOrObject(obj: resource));
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final AccountBalance address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          networkAddress.toAddress(),
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborNullValue(),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          _account.value?.toCbor(),
          _accountResource.value?.toCbor()
        ]),
        CborTagsConst.tronAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  final TronAddress networkAddress;

  @override
  String? get type => null;

  List<TronToken> _tokens;
  @override
  List<TronToken> get tokens => _tokens;
  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TronToken newToken) {
    if (_tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    _tokens = [newToken, ..._tokens].imutable;
  }

  @override
  void updateToken(TronToken token, Token updatedToken) {
    List<TronToken> existTokens = List<TronToken>.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    existTokens = [token.updateToken(updatedToken), ...existTokens];
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void removeToken(TronToken token) {
    final existTokens = List.from(_tokens);
    existTokens.removeWhere((element) => element == token);
    _tokens = List.unmodifiable(existTokens);
  }

  @override
  void addNFT(NFTCore newNft) {}

  @override
  void removeNFT(NFTCore nft) {}

  @override
  bool get multiSigAccount => false;

  String? _accountName;
  @override
  String? get accountName => _accountName ?? accountInfo?.accountName;

  @override
  void setAccountName(String? name) {
    _accountName = name;
  }

  final Live<TronAccountResourceInfo?> _accountResource;
  TronAccountResourceInfo? get accountResource => _accountResource.value;

  Live<TronAccountResourceInfo?> get liveAccountResource => _accountResource;
  final Live<TronAccountInfo?> _account;
  TronAccountInfo? get accountInfo => _account.value;
  Live<TronAccountInfo?> get liveTronAccount => _account;
  void setAccountResource(TronAccountResourceInfo? accResource) {
    _accountResource.value = accResource;
  }

  void setTronAccount(TronAccountInfo? tronAcc) {
    _account.value = tronAcc;
    if (tronAcc != null) {
      for (final i in tronAcc.assetV2) {
        final token = MethodUtils.nullOnException(
            () => _tokens.firstWhere((element) => element.issuer == i.key));
        token?.updateBalance(i.value);
      }
    }
  }

  @override
  String get orginalAddress => networkAddress.toAddress();

  @override
  bool isEqual(ChainAccount other) {
    return multiSigAccount == other.multiSigAccount &&
        orginalAddress == other.orginalAddress;
  }

  @override
  TronNewAddressParams toAccountParams() {
    return TronNewAddressParams(deriveIndex: keyIndex, coin: coin);
  }
}

class ITronMultisigAddress extends ITronAddress
    implements MultiSigCryptoAccountAddress {
  ITronMultisigAddress._(
      {required super.address,
      required super.network,
      required super.coin,
      required super.networkAddress,
      required super.nfts,
      required super.tokens,
      required super.accountInfo,
      required super.resource,
      required this.multiSignatureAccount,
      super.accountName})
      : super._(keyIndex: const MultiSigAddressIndex(), publicKey: const []);

  factory ITronMultisigAddress.newAccount(
      {required TronMultisigNewAddressParams accountParams,
      required WalletTronNetwork network}) {
    final addressDetauls = AccountBalance(
        address: accountParams.masterAddress.toString(),
        balance: IntegerBalance.zero(network.coinParam.decimal));

    return ITronMultisigAddress._(
        coin: accountParams.coin,
        multiSignatureAccount: accountParams.multiSigAccount,
        address: addressDetauls,
        networkAddress: accountParams.masterAddress,
        network: network.value,
        tokens: const [],
        accountInfo: null,
        resource: null,
        accountName: null,
        nfts: const []);
  }

  factory ITronMultisigAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, CborTagsConst.tronMultisigAccount);
    final CoinProposal proposal = CoinProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.elementAt(1), proposal)!;

    final TronMultiSignatureAddress multiSignatureAddress =
        TronMultiSignatureAddress.fromCborBytesOrObject(
            obj: cbor.getCborTag(3));
    final networkId = cbor.elementAt(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final AccountBalance address = AccountBalance.fromCborBytesOrObject(
        network.coinParam.decimal,
        obj: cbor.getCborTag(4));

    final TronAddress ethAddress = TronAddress(cbor.elementAt(5));

    final List<TronToken> tokens = [
      ...cbor
          .elementAsListOf<CborTagValue>(7)
          .map((e) => TronToken.deserialize(object: e)),
      ...cbor
              .elementAs<CborListValue?>(8)
              ?.value
              .map((e) => TronToken.deserialize(object: e)) ??
          []
    ];

    final String? accountName = cbor.elementAt(10);
    final account = cbor.getCborTag(11);
    final resource = cbor.getCborTag(12);
    return ITronMultisigAddress._(
        coin: coin,
        multiSignatureAccount: multiSignatureAddress,
        address: address,
        networkAddress: ethAddress,
        network: networkId,
        tokens: tokens,
        nfts: [],
        accountName: accountName,
        accountInfo: account == null
            ? null
            : TronAccountInfo.fromCborBytesOrObject(obj: account),
        resource: resource == null
            ? null
            : TronAccountResourceInfo.fromCborBytesOrObject(obj: resource));
  }
  final TronMultiSignatureAddress multiSignatureAccount;
  @override
  List<int> get publicKey => throw UnimplementedError();

  @override
  List get variabels {
    return [keyIndex, network, multiSignatureAccount];
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          const CborNullValue(),
          multiSignatureAccount.toCbor(),
          address.toCbor(),
          networkAddress.toAddress(),
          network,
          CborListValue.fixedLength(_tokens.map((e) => e.toCbor()).toList()),
          CborNullValue(),
          CborListValue.fixedLength(_nfts.map((e) => e.toCbor()).toList()),
          accountName ?? const CborNullValue(),
          _account.value?.toCbor(),
          _accountResource.value?.toCbor()
        ]),
        CborTagsConst.tronMultisigAccount);
  }

  @override
  bool get multiSigAccount => true;

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAccount.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();
  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  TronMultisigNewAddressParams toAccountParams() {
    return TronMultisigNewAddressParams(
        coin: coin,
        masterAddress: networkAddress,
        multiSigAccount: multiSignatureAccount);
  }
}

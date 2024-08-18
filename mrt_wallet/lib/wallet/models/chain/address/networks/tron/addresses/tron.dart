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
      required List<TronTRC20Token> trc20Token,
      required List<TronTRC10Token> trc10Token,
      required List<NFTCore> nfts,
      String? accountName,
      TronAccountInfo? accountInfo,
      TronAccountResourceInfo? resource})
      : publicKey = List.unmodifiable(publicKey),
        _trc10Tokens = List<TronTRC10Token>.unmodifiable(trc10Token),
        _trc20Token = List<TronTRC20Token>.unmodifiable(trc20Token),
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
      trc10Token: const [],
      trc20Token: const [],
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

    final List<TronTRC20Token> trc20Tokens = (cbor.elementAt(7) as List?)
            ?.map((e) => TronTRC20Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC20Token>[];

    final List<TronTRC10Token> trc10Tokens = (cbor.elementAt(8) as List?)
            ?.map((e) => TronTRC10Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC10Token>[];

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
        trc20Token: trc20Tokens,
        trc10Token: trc10Tokens,
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
          CborListValue.fixedLength(
              _trc20Token.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              _trc10Tokens.map((e) => e.toCbor()).toList()),
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

  List<TronTRC20Token> _trc20Token;
  @override
  List<TronTRC20Token> get tokens => _trc20Token;
  List<TronTRC10Token> _trc10Tokens;
  List<TronTRC10Token> get trc10Tokens => _trc10Tokens;
  List<NFTCore> _nfts;
  @override
  List<NFTCore> get nfts => _nfts;

  @override
  void addToken(TronToken newToken) {
    if (_trc20Token.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    if (_trc10Tokens.contains(newToken)) {
      throw WalletExceptionConst.tokenAlreadyExist;
    }
    if (newToken is TronTRC20Token) {
      _trc20Token = List.unmodifiable([newToken, ..._trc20Token]);
    } else {
      _trc10Tokens = List.unmodifiable([newToken, ..._trc10Tokens]);
    }
  }

  @override
  void updateToken(TronToken token, Token updatedToken) {
    if (tokens.contains(token)) {
      token as TronTRC20Token;
      List<TronTRC20Token> existTokens = List<TronTRC20Token>.from(_trc20Token);
      existTokens.removeWhere((element) => element == token);
      existTokens = [token.updateToken(updatedToken), ...existTokens];
      _trc20Token = List.unmodifiable(existTokens);
    } else if (_trc10Tokens.contains(token)) {
      token as TronTRC10Token;
      List<TronTRC10Token> existTokens =
          List<TronTRC10Token>.from(_trc10Tokens);
      existTokens.removeWhere((element) => element == token);
      existTokens = [token.updateToken(updatedToken), ...existTokens];
      _trc10Tokens = List.unmodifiable(existTokens);
    }
  }

  @override
  void removeToken(TronToken token) {
    if (tokens.contains(token)) {
      final existTokens = List.from(_trc20Token);
      existTokens.removeWhere((element) => element == token);
      _trc20Token = List.unmodifiable(existTokens);
    } else if (_trc10Tokens.contains(token)) {
      final existTokens = List.from(_trc10Tokens);
      existTokens.removeWhere((element) => element == token);
      _trc10Tokens = List.unmodifiable(existTokens);
    }
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
        final token = MethodUtils.nullOnException(() =>
            _trc10Tokens.firstWhere((element) => element.tokenID == i.key));
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
      required super.trc10Token,
      required super.trc20Token,
      required super.accountInfo,
      required super.resource,
      required this.multiSignatureAccount,
      String? accountName})
      : super._(
            keyIndex: const MultiSigAddressIndex(),
            publicKey: const [],
            accountName: accountName);

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
        trc10Token: const [],
        trc20Token: const [],
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

    final List<TronTRC20Token> trc20Tokens = (cbor.elementAt(7) as List?)
            ?.map((e) => TronTRC20Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC20Token>[];

    final List<TronTRC10Token> trc10Tokens = (cbor.elementAt(8) as List?)
            ?.map((e) => TronTRC10Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC10Token>[];

    final String? accountName = cbor.elementAt(10);
    final account = cbor.getCborTag(11);
    final resource = cbor.getCborTag(12);
    return ITronMultisigAddress._(
        coin: coin,
        multiSignatureAccount: multiSignatureAddress,
        address: address,
        networkAddress: ethAddress,
        network: networkId,
        trc20Token: trc20Tokens,
        trc10Token: trc10Tokens,
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
          CborListValue.fixedLength(
              _trc20Token.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              _trc10Tokens.map((e) => e.toCbor()).toList()),
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

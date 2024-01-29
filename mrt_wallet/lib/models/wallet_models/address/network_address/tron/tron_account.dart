import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/on_chain.dart';

class ITronAddress
    with Equatable
    implements Bip32AddressCore<BigInt, TronAddress> {
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
      {required TronNewAddressParam accountParams,
      required List<int> publicKey,
      required AppNetworkImpl network}) {
    final tronAddress = TronAddress.fromPublicKey(publicKey);
    final addressDetauls = NoneDecimalNetworkAddressDetails(
        address: tronAddress.toAddress(),
        balance: NoneDecimalBalance.zero(network.coinParam.decimal));
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
  factory ITronAddress.fromCbsorHex(String hex, AppNetworkImpl network) {
    return ITronAddress.fromCborBytesOrObject(network,
        bytes: BytesUtils.fromHexString(hex));
  }
  factory ITronAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.tronMultisigAccount)) {
      return ITronMultisigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, WalletModelCborTagsConst.tronAccount);
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.getIndex(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.getIndex(1), proposal)!;
    final keyIndex =
        AddressDerivationIndex.fromCborBytesOrObject(obj: cbor.getCborTag(2));
    final List<int> publicKey = cbor.getIndex(3);
    final networkId = cbor.getIndex(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final NoneDecimalNetworkAddressDetails address =
        NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
            network.coinParam.decimal,
            obj: cbor.getCborTag(4));

    final TronAddress ethAddress = TronAddress(cbor.getIndex(5));

    final List<TronTRC20Token> trc20Tokens = (cbor.getIndex(7) as List?)
            ?.map((e) => TronTRC20Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC20Token>[];

    final List<TronTRC10Token> trc10Tokens = (cbor.getIndex(8) as List?)
            ?.map((e) => TronTRC10Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC10Token>[];

    final String? accountName = cbor.getIndex(10);
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
  final NetworkAddressDetailsCore<BigInt> address;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex keyIndex;

  @override
  final int network;

  @override
  final List<int> publicKey;

  @override
  List<String> get signers => [BytesUtils.toHexString(publicKey)];

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
        WalletModelCborTagsConst.tronAccount);
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
  void addToken(TokenCore<BigInt> newToken) {
    if (newToken is! TronTRC20Token && newToken is! TronTRC10Token) {
      throw WalletExceptionConst.invalidArgruments(
          "ETHERC20Token", "${newToken.runtimeType}");
    }
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
  void removeToken(TokenCore<BigInt> token) {
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
        final token = MethodCaller.nullOnException(() =>
            _trc10Tokens.firstWhere((element) => element.tokenID == i.key));
        token?.updateBalance(i.value);
      }
    }
  }

  @override
  String get orginalAddress => networkAddress.toAddress();
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
      {required TronMultisigNewAddressParam accountParams,
      required APPTVMNetwork network}) {
    final addressDetauls = NoneDecimalNetworkAddressDetails(
        address: accountParams.masterAddress.toString(),
        balance: NoneDecimalBalance.zero(network.coinParam.decimal));

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
  factory ITronMultisigAddress.fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    final CborListValue cbor = CborSerializable.decodeCborTags(
        null, toCborTag, WalletModelCborTagsConst.tronMultisigAccount);
    final CryptoProposal proposal = CryptoProposal.fromName(cbor.getIndex(0));
    final CryptoCoins coin = CryptoCoins.getCoin(cbor.getIndex(1), proposal)!;

    final TronMultiSignatureAddress multiSignatureAddress =
        TronMultiSignatureAddress.fromCborBytesOrObject(
            obj: cbor.getCborTag(3));
    final networkId = cbor.getIndex(6);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final NoneDecimalNetworkAddressDetails address =
        NoneDecimalNetworkAddressDetails.fromCborBytesOrObject(
            network.coinParam.decimal,
            obj: cbor.getCborTag(4));

    final TronAddress ethAddress = TronAddress(cbor.getIndex(5));

    final List<TronTRC20Token> trc20Tokens = (cbor.getIndex(7) as List?)
            ?.map((e) => TronTRC20Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC20Token>[];

    final List<TronTRC10Token> trc10Tokens = (cbor.getIndex(8) as List?)
            ?.map((e) => TronTRC10Token.fromCborBytesOrObject(obj: e))
            .toList() ??
        <TronTRC10Token>[];

    final String? accountName = cbor.getIndex(10);
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
  List<String> get signers =>
      multiSignatureAccount.signers.map((e) => e.publicKey).toList();
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
        WalletModelCborTagsConst.tronMultisigAccount);
  }

  @override
  bool get multiSigAccount => true;

  @override
  List<(String, AddressDerivationIndex)> get keyDetails =>
      multiSignatureAccount.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();
}
